// SPDX-License-Identifier: MIT


// 
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// 
pragma solidity ^0.8.8;




interface IERC721Metadata {
    
    
    function name() external view returns (string memory tokenName);

    
    
    function symbol() external view returns (string memory tokenSymbol);

    
    
    
    
    function tokenURI(uint256 tokenId) external view returns (string memory uri);
}

// 
pragma solidity ^0.8.8;







abstract contract ForwarderRegistryContextBase {
    IForwarderRegistry internal immutable _forwarderRegistry;

    constructor(IForwarderRegistry forwarderRegistry) {
        _forwarderRegistry = forwarderRegistry;
    }

    
    function _msgSender() internal view virtual returns (address) {
        // Optimised path in case of an EOA-initiated direct tx to the contract or a call from a contract not complying with EIP-2771
        // solhint-disable-next-line avoid-tx-origin
        if (msg.sender == tx.origin || msg.data.length < 24) {
            return msg.sender;
        }

        address sender = ERC2771Calldata.msgSender();

        // Return the EIP-2771 calldata-appended sender address if the message was forwarded by the ForwarderRegistry or an approved forwarder
        if (msg.sender == address(_forwarderRegistry) || _forwarderRegistry.isApprovedForwarder(sender, msg.sender)) {
            return sender;
        }

        return msg.sender;
    }

    
    function _msgData() internal view virtual returns (bytes calldata) {
        // Optimised path in case of an EOA-initiated direct tx to the contract or a call from a contract not complying with EIP-2771
        // solhint-disable-next-line avoid-tx-origin
        if (msg.sender == tx.origin || msg.data.length < 24) {
            return msg.data;
        }

        // Return the EIP-2771 calldata (minus the appended sender) if the message was forwarded by the ForwarderRegistry or an approved forwarder
        if (msg.sender == address(_forwarderRegistry) || _forwarderRegistry.isApprovedForwarder(ERC2771Calldata.msgSender(), msg.sender)) {
            return ERC2771Calldata.msgData();
        }

        return msg.data;
    }
}

// 
pragma solidity ^0.8.8;













abstract contract ERC721MetadataPerTokenBase is Context, IERC721Metadata {
    using ERC721Storage for ERC721Storage.Layout;
    using ERC721ContractMetadataStorage for ERC721ContractMetadataStorage.Layout;
    using TokenMetadataPerTokenStorage for TokenMetadataPerTokenStorage.Layout;
    using AccessControlStorage for AccessControlStorage.Layout;

    // prevent variable name clash with public ERC721Mintable(Once)Base.MINTER_ROLE
    bytes32 private constant _MINTER_ROLE = "minter";

    
    
    
    
    function setTokenURI(uint256 tokenId, string calldata uri) external {
        AccessControlStorage.layout().enforceHasRole(_MINTER_ROLE, _msgSender());
        TokenMetadataPerTokenStorage.layout().setTokenURI(tokenId, uri);
    }

    
    
    
    
    function batchSetTokenURI(uint256[] calldata tokenIds, string[] calldata uris) external {
        AccessControlStorage.layout().enforceHasRole(_MINTER_ROLE, _msgSender());
        TokenMetadataPerTokenStorage.layout().batchSetTokenURI(tokenIds, uris);
    }

    
    function name() external view override returns (string memory tokenName) {
        return ERC721ContractMetadataStorage.layout().name();
    }

    
    function symbol() external view override returns (string memory tokenSymbol) {
        return ERC721ContractMetadataStorage.layout().symbol();
    }

    
    function tokenURI(uint256 tokenId) external view override returns (string memory uri) {
        ERC721Storage.layout().ownerOf(tokenId); // reverts if the token does not exist
        return TokenMetadataPerTokenStorage.layout().tokenMetadataURI(tokenId);
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        
        assembly {
            r.slot := slot
        }
    }
}

// 
pragma solidity ^0.8.8;



library AccessControlStorage {
    using Bytes32 for bytes32;
    using AccessControlStorage for AccessControlStorage.Layout;

    struct Layout {
        mapping(bytes32 => mapping(address => bool)) roles;
    }

    bytes32 internal constant LAYOUT_STORAGE_SLOT = bytes32(uint256(keccak256("animoca.core.access.AccessControl.storage")) - 1);

    event RoleGranted(bytes32 role, address account, address operator);
    event RoleRevoked(bytes32 role, address account, address operator);

    
    
    
    
    
    
    function grantRole(Layout storage s, bytes32 role, address account, address operator) internal {
        if (!s.hasRole(role, account)) {
            s.roles[role][account] = true;
            emit RoleGranted(role, account, operator);
        }
    }

    
    
    
    
    
    
    function revokeRole(Layout storage s, bytes32 role, address account, address operator) internal {
        if (s.hasRole(role, account)) {
            s.roles[role][account] = false;
            emit RoleRevoked(role, account, operator);
        }
    }

    
    
    
    
    
    function renounceRole(Layout storage s, address sender, bytes32 role) internal {
        s.enforceHasRole(role, sender);
        s.roles[role][sender] = false;
        emit RoleRevoked(role, sender, sender);
    }

    
    
    
    
    function hasRole(Layout storage s, bytes32 role, address account) internal view returns (bool) {
        return s.roles[role][account];
    }

    
    
    
    
    function enforceHasRole(Layout storage s, bytes32 role, address account) internal view {
        if (!s.hasRole(role, account)) {
            revert(string(abi.encodePacked("AccessControl: missing '", role.toASCIIString(), "' role")));
        }
    }

    function layout() internal pure returns (Layout storage s) {
        bytes32 position = LAYOUT_STORAGE_SLOT;
        assembly {
            s.slot := position
        }
    }
}

// 
pragma solidity ^0.8.8;




interface IERC165 {
    
    
    
    
    function supportsInterface(bytes4 interfaceId) external view returns (bool supported);
}

// 
pragma solidity ^0.8.8;



library InterfaceDetectionStorage {
    struct Layout {
        mapping(bytes4 => bool) supportedInterfaces;
    }

    bytes32 internal constant LAYOUT_STORAGE_SLOT = bytes32(uint256(keccak256("animoca.core.introspection.InterfaceDetection.storage")) - 1);

    bytes4 internal constant ILLEGAL_INTERFACE_ID = 0xffffffff;

    
    
    
    
    function setSupportedInterface(Layout storage s, bytes4 interfaceId, bool supported) internal {
        require(interfaceId != ILLEGAL_INTERFACE_ID, "InterfaceDetection: wrong value");
        s.supportedInterfaces[interfaceId] = supported;
    }

    
    
    
    
    function supportsInterface(Layout storage s, bytes4 interfaceId) internal view returns (bool supported) {
        if (interfaceId == ILLEGAL_INTERFACE_ID) {
            return false;
        }
        if (interfaceId == type(IERC165).interfaceId) {
            return true;
        }
        return s.supportedInterfaces[interfaceId];
    }

    function layout() internal pure returns (Layout storage s) {
        bytes32 position = LAYOUT_STORAGE_SLOT;
        assembly {
            s.slot := position
        }
    }
}

// 
pragma solidity ^0.8.8;



interface IForwarderRegistry {
    
    
    
    
    function isApprovedForwarder(address sender, address forwarder) external view returns (bool isApproved);
}

// 
pragma solidity ^0.8.8;



library ERC2771Calldata {
    
    function msgSender() internal pure returns (address sender) {
        assembly {
            sender := shr(96, calldataload(sub(calldatasize(), 20)))
        }
    }

    
    function msgData() internal pure returns (bytes calldata data) {
        unchecked {
            return msg.data[:msg.data.length - 20];
        }
    }
}

// 
pragma solidity ^0.8.8;




library ProxyAdminStorage {
    using ProxyAdminStorage for ProxyAdminStorage.Layout;

    struct Layout {
        address admin;
    }

    // bytes32 public constant PROXYADMIN_STORAGE_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
    bytes32 internal constant LAYOUT_STORAGE_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);
    bytes32 internal constant PROXY_INIT_PHASE_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin.phase")) - 1);

    event AdminChanged(address previousAdmin, address newAdmin);

    
    
    
    
    
    function constructorInit(Layout storage s, address initialAdmin) internal {
        require(initialAdmin != address(0), "ProxyAdmin: no initial admin");
        s.admin = initialAdmin;
        emit AdminChanged(address(0), initialAdmin);
    }

    
    
    
    
    
    
    
    function proxyInit(Layout storage s, address initialAdmin) internal {
        ProxyInitialization.setPhase(PROXY_INIT_PHASE_SLOT, 1);
        s.constructorInit(initialAdmin);
    }

    
    
    
    
    function changeProxyAdmin(Layout storage s, address sender, address newAdmin) internal {
        address previousAdmin = s.admin;
        require(sender == previousAdmin, "ProxyAdmin: not the admin");
        if (previousAdmin != newAdmin) {
            s.admin = newAdmin;
            emit AdminChanged(previousAdmin, newAdmin);
        }
    }

    
    
    function proxyAdmin(Layout storage s) internal view returns (address admin) {
        return s.admin;
    }

    
    
    
    function enforceIsProxyAdmin(Layout storage s, address account) internal view {
        require(account == s.admin, "ProxyAdmin: not the admin");
    }

    function layout() internal pure returns (Layout storage s) {
        bytes32 position = LAYOUT_STORAGE_SLOT;
        assembly {
            s.slot := position
        }
    }
}

// 
pragma solidity ^0.8.8;




library ProxyInitialization {
    
    
    
    
    function setPhase(bytes32 storageSlot, uint256 phase) internal {
        StorageSlot.Uint256Slot storage currentVersion = StorageSlot.getUint256Slot(storageSlot);
        require(currentVersion.value < phase, "Storage: phase reached");
        currentVersion.value = phase;
    }
}

// 
pragma solidity 0.8.17;












contract ERC721MetadataPerTokenFacet is ERC721MetadataPerTokenBase, ForwarderRegistryContextBase {
    using ProxyAdminStorage for ProxyAdminStorage.Layout;
    using ERC721ContractMetadataStorage for ERC721ContractMetadataStorage.Layout;

    constructor(IForwarderRegistry forwarderRegistry) ForwarderRegistryContextBase(forwarderRegistry) {}

    
    
    
    
    
    
    
    
    function initERC721MetadataStorage(string calldata tokenName, string calldata tokenSymbol) external {
        ProxyAdminStorage.layout().enforceIsProxyAdmin(_msgSender());
        ERC721ContractMetadataStorage.layout().proxyInit(tokenName, tokenSymbol);
    }

    
    function _msgSender() internal view virtual override(Context, ForwarderRegistryContextBase) returns (address) {
        return ForwarderRegistryContextBase._msgSender();
    }

    
    function _msgData() internal view virtual override(Context, ForwarderRegistryContextBase) returns (bytes calldata) {
        return ForwarderRegistryContextBase._msgData();
    }
}

// 
pragma solidity ^0.8.8;





interface IERC721 {
    
    
    
    
    
    
    
    
    
    function approve(address to, uint256 tokenId) external;

    
    
    
    
    
    function setApprovalForAll(address operator, bool approved) external;

    
    
    
    
    
    
    
    
    
    
    function transferFrom(address from, address to, uint256 tokenId) external;

    
    
    
    
    
    
    
    
    
    
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    
    
    
    
    
    
    
    
    
    
    
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    
    
    
    
    function balanceOf(address owner) external view returns (uint256 balance);

    
    
    
    
    function ownerOf(uint256 tokenId) external view returns (address tokenOwner);

    
    
    
    
    function getApproved(uint256 tokenId) external view returns (address approved);

    
    
    
    
    function isApprovedForAll(address owner, address operator) external view returns (bool approvedForAll);
}

// 
pragma solidity ^0.8.8;




interface IERC721BatchTransfer {
    
    
    
    
    
    
    
    
    
    function batchTransferFrom(address from, address to, uint256[] calldata tokenIds) external;
}

// 
pragma solidity ^0.8.8;




interface IERC721Burnable {
    
    
    
    
    
    
    function burnFrom(address from, uint256 tokenId) external;

    
    
    
    
    
    
    function batchBurnFrom(address from, uint256[] calldata tokenIds) external;
}

// 
pragma solidity ^0.8.8;




interface IERC721Deliverable {
    
    
    
    
    
    
    
    function deliver(address[] calldata recipients, uint256[] calldata tokenIds) external;
}

// 
pragma solidity ^0.8.8;




interface IERC721Mintable {
    
    
    
    
    
    
    function mint(address to, uint256 tokenId) external;

    
    
    
    
    
    
    
    
    function safeMint(address to, uint256 tokenId, bytes calldata data) external;

    
    
    
    
    
    
    function batchMint(address to, uint256[] calldata tokenIds) external;
}

// 
pragma solidity ^0.8.8;





interface IERC721Receiver {
    
    
    
    
    
    
    
    
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4 magicValue);
}

// 
pragma solidity ^0.8.8;





library ERC721ContractMetadataStorage {
    using InterfaceDetectionStorage for InterfaceDetectionStorage.Layout;
    using ERC721ContractMetadataStorage for ERC721ContractMetadataStorage.Layout;

    struct Layout {
        string tokenName;
        string tokenSymbol;
    }

    bytes32 internal constant LAYOUT_STORAGE_SLOT = bytes32(uint256(keccak256("animoca.token.ERC721.ERC721ContractMetadata.storage")) - 1);
    bytes32 internal constant PROXY_INIT_PHASE_SLOT = bytes32(uint256(keccak256("animoca.token.ERC721.ERC712ContractMetadata.phase")) - 1);

    
    
    
    
    
    function constructorInit(Layout storage s, string memory tokenName, string memory tokenSymbol) internal {
        s.tokenName = tokenName;
        s.tokenSymbol = tokenSymbol;
        InterfaceDetectionStorage.layout().setSupportedInterface(type(IERC721Metadata).interfaceId, true);
    }

    
    
    
    
    
    
    
    function proxyInit(Layout storage s, string calldata tokenName, string calldata tokenSymbol) internal {
        ProxyInitialization.setPhase(PROXY_INIT_PHASE_SLOT, 1);
        s.tokenName = tokenName;
        s.tokenSymbol = tokenSymbol;
        InterfaceDetectionStorage.layout().setSupportedInterface(type(IERC721Metadata).interfaceId, true);
    }

    
    
    function name(Layout storage s) internal view returns (string memory tokenName) {
        return s.tokenName;
    }

    
    
    function symbol(Layout storage s) internal view returns (string memory tokenSymbol) {
        return s.tokenSymbol;
    }

    function layout() internal pure returns (Layout storage s) {
        bytes32 position = LAYOUT_STORAGE_SLOT;
        assembly {
            s.slot := position
        }
    }
}

// 
pragma solidity ^0.8.8;











library ERC721Storage {
    using Address for address;
    using ERC721Storage for ERC721Storage.Layout;
    using InterfaceDetectionStorage for InterfaceDetectionStorage.Layout;

    struct Layout {
        mapping(uint256 => uint256) owners;
        mapping(address => uint256) balances;
        mapping(uint256 => address) approvals;
        mapping(address => mapping(address => bool)) operators;
    }

    bytes32 internal constant LAYOUT_STORAGE_SLOT = bytes32(uint256(keccak256("animoca.token.ERC721.ERC721.storage")) - 1);

    bytes4 internal constant ERC721_RECEIVED = IERC721Receiver.onERC721Received.selector;

    // Single token approval flag
    // This bit is set in the owner's value to indicate that there is an approval set for this token
    uint256 internal constant TOKEN_APPROVAL_OWNER_FLAG = 1 << 160;

    // Burnt token magic value
    // This magic number is used as the owner's value to indicate that the token has been burnt
    uint256 internal constant BURNT_TOKEN_OWNER_VALUE = 0xdead000000000000000000000000000000000000000000000000000000000000;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    
    function init() internal {
        InterfaceDetectionStorage.layout().setSupportedInterface(type(IERC721).interfaceId, true);
    }

    
    function initERC721BatchTransfer() internal {
        InterfaceDetectionStorage.layout().setSupportedInterface(type(IERC721BatchTransfer).interfaceId, true);
    }

    
    function initERC721Mintable() internal {
        InterfaceDetectionStorage.layout().setSupportedInterface(type(IERC721Mintable).interfaceId, true);
    }

    
    function initERC721Deliverable() internal {
        InterfaceDetectionStorage.layout().setSupportedInterface(type(IERC721Deliverable).interfaceId, true);
    }

    
    function initERC721Burnable() internal {
        InterfaceDetectionStorage.layout().setSupportedInterface(type(IERC721Burnable).interfaceId, true);
    }

    
    
    
    
    
    
    
    
    
    function approve(Layout storage s, address sender, address to, uint256 tokenId) internal {
        uint256 owner = s.owners[tokenId];
        require(_tokenExists(owner), "ERC721: non-existing token");
        address ownerAddress = _tokenOwner(owner);
        require(to != ownerAddress, "ERC721: self-approval");
        require(_isOperatable(s, ownerAddress, sender), "ERC721: non-approved sender");
        if (to == address(0)) {
            if (_tokenHasApproval(owner)) {
                // remove the approval bit if it is present
                s.owners[tokenId] = uint256(uint160(ownerAddress));
            }
        } else {
            uint256 ownerWithApprovalBit = owner | TOKEN_APPROVAL_OWNER_FLAG;
            if (owner != ownerWithApprovalBit) {
                // add the approval bit if it is not present
                s.owners[tokenId] = ownerWithApprovalBit;
            }
            s.approvals[tokenId] = to;
        }
        emit Approval(ownerAddress, to, tokenId);
    }

    
    
    
    
    
    
    
    function setApprovalForAll(Layout storage s, address sender, address operator, bool approved) internal {
        require(operator != sender, "ERC721: self-approval for all");
        s.operators[sender][operator] = approved;
        emit ApprovalForAll(sender, operator, approved);
    }

    
    
    
    
    
    
    
    
    
    
    
    function transferFrom(Layout storage s, address sender, address from, address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: transfer to address(0)");

        uint256 owner = s.owners[tokenId];
        require(_tokenExists(owner), "ERC721: non-existing token");
        require(_tokenOwner(owner) == from, "ERC721: non-owned token");

        if (!_isOperatable(s, from, sender)) {
            require(_tokenHasApproval(owner) && sender == s.approvals[tokenId], "ERC721: non-approved sender");
        }

        s.owners[tokenId] = uint256(uint160(to));
        if (from != to) {
            unchecked {
                // cannot underflow as balance is verified through ownership
                --s.balances[from];
                //  cannot overflow as supply cannot overflow
                ++s.balances[to];
            }
        }

        emit Transfer(from, to, tokenId);
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    function safeTransferFrom(Layout storage s, address sender, address from, address to, uint256 tokenId) internal {
        s.transferFrom(sender, from, to, tokenId);
        if (to.isContract()) {
            _callOnERC721Received(sender, from, to, tokenId, "");
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function safeTransferFrom(Layout storage s, address sender, address from, address to, uint256 tokenId, bytes calldata data) internal {
        s.transferFrom(sender, from, to, tokenId);
        if (to.isContract()) {
            _callOnERC721Received(sender, from, to, tokenId, data);
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    function batchTransferFrom(Layout storage s, address sender, address from, address to, uint256[] calldata tokenIds) internal {
        require(to != address(0), "ERC721: transfer to address(0)");
        bool operatable = _isOperatable(s, from, sender);

        uint256 length = tokenIds.length;
        unchecked {
            for (uint256 i; i != length; ++i) {
                uint256 tokenId = tokenIds[i];
                uint256 owner = s.owners[tokenId];
                require(_tokenExists(owner), "ERC721: non-existing token");
                require(_tokenOwner(owner) == from, "ERC721: non-owned token");
                if (!operatable) {
                    require(_tokenHasApproval(owner) && sender == s.approvals[tokenId], "ERC721: non-approved sender");
                }
                s.owners[tokenId] = uint256(uint160(to));
                emit Transfer(from, to, tokenId);
            }

            if (from != to && length != 0) {
                // cannot underflow as balance is verified through ownership
                s.balances[from] -= length;
                // cannot overflow as supply cannot overflow
                s.balances[to] += length;
            }
        }
    }

    
    
    
    
    
    
    
    
    function mint(Layout storage s, address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to address(0)");
        require(!_tokenExists(s.owners[tokenId]), "ERC721: existing token");

        s.owners[tokenId] = uint256(uint160(to));

        unchecked {
            // cannot overflow due to the cost of minting individual tokens
            ++s.balances[to];
        }

        emit Transfer(address(0), to, tokenId);
    }

    
    
    
    
    
    
    
    
    
    
    
    function safeMint(Layout storage s, address sender, address to, uint256 tokenId, bytes memory data) internal {
        s.mint(to, tokenId);
        if (to.isContract()) {
            _callOnERC721Received(sender, address(0), to, tokenId, data);
        }
    }

    
    
    
    
    
    
    
    
    function batchMint(Layout storage s, address to, uint256[] memory tokenIds) internal {
        require(to != address(0), "ERC721: mint to address(0)");

        uint256 length = tokenIds.length;
        unchecked {
            for (uint256 i; i != length; ++i) {
                uint256 tokenId = tokenIds[i];
                require(!_tokenExists(s.owners[tokenId]), "ERC721: existing token");

                s.owners[tokenId] = uint256(uint160(to));
                emit Transfer(address(0), to, tokenId);
            }

            s.balances[to] += length;
        }
    }

    
    
    
    
    
    
    
    
    
    function deliver(Layout storage s, address[] memory recipients, uint256[] memory tokenIds) internal {
        uint256 length = recipients.length;
        require(length == tokenIds.length, "ERC721: inconsistent arrays");
        unchecked {
            for (uint256 i; i != length; ++i) {
                s.mint(recipients[i], tokenIds[i]);
            }
        }
    }

    
    
    
    
    
    
    
    
    
    function mintOnce(Layout storage s, address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to address(0)");

        uint256 owner = s.owners[tokenId];
        require(!_tokenExists(owner), "ERC721: existing token");
        require(!_tokenWasBurnt(owner), "ERC721: burnt token");

        s.owners[tokenId] = uint256(uint160(to));

        unchecked {
            // cannot overflow due to the cost of minting individual tokens
            ++s.balances[to];
        }

        emit Transfer(address(0), to, tokenId);
    }

    
    
    
    
    
    
    
    
    
    
    
    function safeMintOnce(Layout storage s, address sender, address to, uint256 tokenId, bytes memory data) internal {
        s.mintOnce(to, tokenId);
        if (to.isContract()) {
            _callOnERC721Received(sender, address(0), to, tokenId, data);
        }
    }

    
    
    
    
    
    
    
    
    
    function batchMintOnce(Layout storage s, address to, uint256[] memory tokenIds) internal {
        require(to != address(0), "ERC721: mint to address(0)");

        uint256 length = tokenIds.length;
        unchecked {
            for (uint256 i; i != length; ++i) {
                uint256 tokenId = tokenIds[i];
                uint256 owner = s.owners[tokenId];
                require(!_tokenExists(owner), "ERC721: existing token");
                require(!_tokenWasBurnt(owner), "ERC721: burnt token");

                s.owners[tokenId] = uint256(uint160(to));

                emit Transfer(address(0), to, tokenId);
            }

            s.balances[to] += length;
        }
    }

    
    
    
    
    
    
    
    
    
    
    function deliverOnce(Layout storage s, address[] memory recipients, uint256[] memory tokenIds) internal {
        uint256 length = recipients.length;
        require(length == tokenIds.length, "ERC721: inconsistent arrays");
        unchecked {
            for (uint256 i; i != length; ++i) {
                address to = recipients[i];
                require(to != address(0), "ERC721: mint to address(0)");

                uint256 tokenId = tokenIds[i];
                uint256 owner = s.owners[tokenId];
                require(!_tokenExists(owner), "ERC721: existing token");
                require(!_tokenWasBurnt(owner), "ERC721: burnt token");

                s.owners[tokenId] = uint256(uint160(to));
                ++s.balances[to];

                emit Transfer(address(0), to, tokenId);
            }
        }
    }

    
    
    
    
    
    
    
    
    function burnFrom(Layout storage s, address sender, address from, uint256 tokenId) internal {
        uint256 owner = s.owners[tokenId];
        require(from == _tokenOwner(owner), "ERC721: non-owned token");

        if (!_isOperatable(s, from, sender)) {
            require(_tokenHasApproval(owner) && sender == s.approvals[tokenId], "ERC721: non-approved sender");
        }

        s.owners[tokenId] = BURNT_TOKEN_OWNER_VALUE;

        unchecked {
            // cannot underflow as balance is verified through TOKEN ownership
            --s.balances[from];
        }
        emit Transfer(from, address(0), tokenId);
    }

    
    
    
    
    
    
    
    
    function batchBurnFrom(Layout storage s, address sender, address from, uint256[] calldata tokenIds) internal {
        bool operatable = _isOperatable(s, from, sender);

        uint256 length = tokenIds.length;
        unchecked {
            for (uint256 i; i != length; ++i) {
                uint256 tokenId = tokenIds[i];
                uint256 owner = s.owners[tokenId];
                require(from == _tokenOwner(owner), "ERC721: non-owned token");
                if (!operatable) {
                    require(_tokenHasApproval(owner) && sender == s.approvals[tokenId], "ERC721: non-approved sender");
                }
                s.owners[tokenId] = BURNT_TOKEN_OWNER_VALUE;
                emit Transfer(from, address(0), tokenId);
            }

            if (length != 0) {
                s.balances[from] -= length;
            }
        }
    }

    
    
    
    
    
    function balanceOf(Layout storage s, address owner) internal view returns (uint256 balance) {
        require(owner != address(0), "ERC721: balance of address(0)");
        return s.balances[owner];
    }

    
    
    
    
    
    function ownerOf(Layout storage s, uint256 tokenId) internal view returns (address tokenOwner) {
        uint256 owner = s.owners[tokenId];
        require(_tokenExists(owner), "ERC721: non-existing token");
        return _tokenOwner(owner);
    }

    
    
    
    
    
    function getApproved(Layout storage s, uint256 tokenId) internal view returns (address approved) {
        uint256 owner = s.owners[tokenId];
        require(_tokenExists(owner), "ERC721: non-existing token");
        if (_tokenHasApproval(owner)) {
            return s.approvals[tokenId];
        } else {
            return address(0);
        }
    }

    
    
    
    
    
    function isApprovedForAll(Layout storage s, address owner, address operator) internal view returns (bool approvedForAll) {
        return s.operators[owner][operator];
    }

    
    
    
    function wasBurnt(Layout storage s, uint256 tokenId) internal view returns (bool tokenWasBurnt) {
        return _tokenWasBurnt(s.owners[tokenId]);
    }

    function layout() internal pure returns (Layout storage s) {
        bytes32 position = LAYOUT_STORAGE_SLOT;
        assembly {
            s.slot := position
        }
    }

    
    
    
    
    
    
    
    function _callOnERC721Received(address sender, address from, address to, uint256 tokenId, bytes memory data) private {
        require(IERC721Receiver(to).onERC721Received(sender, from, tokenId, data) == ERC721_RECEIVED, "ERC721: safe transfer rejected");
    }

    
    
    
    
    function _isOperatable(Layout storage s, address owner, address account) private view returns (bool operatable) {
        return (owner == account) || s.operators[owner][account];
    }

    function _tokenOwner(uint256 owner) private pure returns (address tokenOwner) {
        return address(uint160(owner));
    }

    function _tokenExists(uint256 owner) private pure returns (bool tokenExists) {
        return uint160(owner) != 0;
    }

    function _tokenWasBurnt(uint256 owner) private pure returns (bool tokenWasBurnt) {
        return owner == BURNT_TOKEN_OWNER_VALUE;
    }

    function _tokenHasApproval(uint256 owner) private pure returns (bool tokenHasApproval) {
        return owner & TOKEN_APPROVAL_OWNER_FLAG != 0;
    }
}

// 
pragma solidity ^0.8.8;

library TokenMetadataPerTokenStorage {
    using TokenMetadataPerTokenStorage for TokenMetadataPerTokenStorage.Layout;

    struct Layout {
        mapping(uint256 => string) uris;
    }

    bytes32 internal constant LAYOUT_STORAGE_SLOT = bytes32(uint256(keccak256("animoca.token.metadata.TokenMetadataPerToken.storage")) - 1);

    
    
    
    function setTokenURI(Layout storage s, uint256 id, string calldata uri) internal {
        s.uris[id] = uri;
    }

    
    
    
    function batchSetTokenURI(Layout storage s, uint256[] calldata ids, string[] calldata uris) internal {
        uint256 length = ids.length;
        require(length == uris.length, "Metadata: inconsistent arrays");
        unchecked {
            for (uint256 i; i != length; ++i) {
                s.uris[ids[i]] = uris[i];
            }
        }
    }

    
    
    
    function tokenMetadataURI(Layout storage s, uint256 id) internal view returns (string memory tokenURI) {
        return s.uris[id];
    }

    function layout() internal pure returns (Layout storage s) {
        bytes32 position = LAYOUT_STORAGE_SLOT;
        assembly {
            s.slot := position
        }
    }
}

// 
pragma solidity ^0.8.8;

library Bytes32 {
    
    
    
    function toBase32String(bytes32 value) internal pure returns (string memory) {
        unchecked {
            bytes32 base32Alphabet = 0x6162636465666768696A6B6C6D6E6F707172737475767778797A323334353637;
            uint256 i = uint256(value);
            uint256 k = 52;
            bytes memory bstr = new bytes(k);
            bstr[--k] = base32Alphabet[uint8((i % 8) << 2)]; // uint8 s = uint8((256 - skip) % 5);  // (i % (2**s)) << (5-s)
            i /= 8;
            while (k > 0) {
                bstr[--k] = base32Alphabet[i % 32];
                i /= 32;
            }
            return string(bstr);
        }
    }

    
    
    
    function toASCIIString(bytes32 value) internal pure returns (string memory) {
        unchecked {
            if (value == 0x00) return "";
            bytes memory bytesString = bytes(abi.encodePacked(value));
            uint256 pos = 31;
            while (true) {
                if (bytesString[pos] != 0) break;
                --pos;
            }
            bytes memory asciiString = new bytes(pos + 1);
            for (uint256 i; i <= pos; ++i) {
                asciiString[i] = bytesString[i];
            }
            return string(asciiString);
        }
    }
}