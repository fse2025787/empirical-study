// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;


// 
pragma solidity ^0.8.8;


interface IDiamondCutCommon {
    enum FacetCutAction {
        ADD,
        REPLACE,
        REMOVE
    }
    // Add=0, Replace=1, Remove=2

    struct FacetCut {
        address facet;
        FacetCutAction action;
        bytes4[] selectors;
    }

    struct Initialization {
        address target;
        bytes data;
    }

    
    
    
    
    event DiamondCut(FacetCut[] cuts, address target, bytes data);
}

// 
pragma solidity ^0.8.8;





interface IDiamondLoupe {
    struct Facet {
        address facet;
        bytes4[] selectors;
    }

    
    
    function facets() external view returns (Facet[] memory diamondFacets);

    
    
    
    function facetFunctionSelectors(address facetAddress) external view returns (bytes4[] memory selectors);

    
    
    function facetAddresses() external view returns (address[] memory diamondFacetsAddresses);

    
    
    
    function facetAddress(bytes4 functionSelector) external view returns (address diamondFacetAddress);
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
pragma solidity 0.8.17;











contract DiamondLoupeFacet is IDiamondLoupe, ForwarderRegistryContextBase {
    using ProxyAdminStorage for ProxyAdminStorage.Layout;
    using DiamondStorage for DiamondStorage.Layout;

    constructor(IForwarderRegistry forwarderRegistry) ForwarderRegistryContextBase(forwarderRegistry) {}

    
    
    function initDiamondLoupeStorage() external {
        ProxyAdminStorage.layout().enforceIsProxyAdmin(_msgSender());
        DiamondStorage.initDiamondLoupe();
    }

    
    function facets() external view override returns (IDiamondLoupe.Facet[] memory facets_) {
        facets_ = DiamondStorage.layout().facets();
    }

    
    function facetFunctionSelectors(address facet) external view override returns (bytes4[] memory facetFunctionSelectors_) {
        facetFunctionSelectors_ = DiamondStorage.layout().facetFunctionSelectors(facet);
    }

    
    function facetAddresses() external view override returns (address[] memory facetAddresses_) {
        facetAddresses_ = DiamondStorage.layout().facetAddresses();
    }

    
    function facetAddress(bytes4 functionSelector) external view override returns (address facetAddress_) {
        facetAddress_ = DiamondStorage.layout().facetAddress(functionSelector);
    }
}

// 
pragma solidity ^0.8.8;







interface IDiamondCut is IDiamondCutCommon {
    
    
    
    
    
    function diamondCut(FacetCut[] calldata cuts, address target, bytes calldata data) external;
}

// 
pragma solidity ^0.8.8;







interface IDiamondCutBatchInit is IDiamondCutCommon {
    
    
    
    
    function diamondCut(FacetCut[] calldata cuts, Initialization[] calldata initializations) external;
}

// 
pragma solidity ^0.8.8;










library DiamondStorage {
    using Address for address;
    using DiamondStorage for DiamondStorage.Layout;
    using InterfaceDetectionStorage for InterfaceDetectionStorage.Layout;

    struct Layout {
        // selector => (facet address, selector slot position)
        mapping(bytes4 => bytes32) diamondFacets;
        // number of selectors registered in selectorSlots
        uint16 selectorCount;
        // array of selector slots with 8 selectors per slot
        mapping(uint256 => bytes32) selectorSlots;
    }

    bytes32 internal constant LAYOUT_STORAGE_SLOT = bytes32(uint256(keccak256("animoca.core.Diamond.storage")) - 1);

    bytes32 internal constant CLEAR_ADDRESS_MASK = bytes32(uint256(0xffffffffffffffffffffffff));
    bytes32 internal constant CLEAR_SELECTOR_MASK = bytes32(uint256(0xffffffff << 224));

    event DiamondCut(IDiamondCutCommon.FacetCut[] cuts, address target, bytes data);

    
    function initDiamondCut() internal {
        InterfaceDetectionStorage.Layout storage interfaceDetectionLayout = InterfaceDetectionStorage.layout();
        interfaceDetectionLayout.setSupportedInterface(type(IDiamondCut).interfaceId, true);
        interfaceDetectionLayout.setSupportedInterface(type(IDiamondCutBatchInit).interfaceId, true);
    }

    
    function initDiamondLoupe() internal {
        InterfaceDetectionStorage.layout().setSupportedInterface(type(IDiamondLoupe).interfaceId, true);
    }

    function diamondCut(Layout storage s, IDiamondCutCommon.FacetCut[] memory cuts, address target, bytes memory data) internal {
        cutFacets(s, cuts);
        emit DiamondCut(cuts, target, data);
        initializationCall(target, data);
    }

    function diamondCut(
        Layout storage s,
        IDiamondCutCommon.FacetCut[] memory cuts,
        IDiamondCutCommon.Initialization[] memory initializations
    ) internal {
        unchecked {
            s.cutFacets(cuts);
            emit DiamondCut(cuts, address(0), "");
            uint256 length = initializations.length;
            for (uint256 i; i != length; ++i) {
                initializationCall(initializations[i].target, initializations[i].data);
            }
        }
    }

    function cutFacets(Layout storage s, IDiamondCutCommon.FacetCut[] memory facetCuts) internal {
        unchecked {
            uint256 originalSelectorCount = s.selectorCount;
            uint256 selectorCount = originalSelectorCount;
            bytes32 selectorSlot;

            // Check if last selector slot is not full
            if (selectorCount & 7 > 0) {
                // get last selectorSlot
                selectorSlot = s.selectorSlots[selectorCount >> 3];
            }

            uint256 length = facetCuts.length;
            for (uint256 i; i != length; ++i) {
                IDiamondCutCommon.FacetCut memory facetCut = facetCuts[i];
                IDiamondCutCommon.FacetCutAction action = facetCut.action;

                require(facetCut.selectors.length != 0, "Diamond: no function selectors");

                if (action == IDiamondCutCommon.FacetCutAction.ADD) {
                    (selectorCount, selectorSlot) = s.addFacetSelectors(selectorCount, selectorSlot, facetCut);
                } else if (action == IDiamondCutCommon.FacetCutAction.REPLACE) {
                    s.replaceFacetSelectors(facetCut);
                } else {
                    (selectorCount, selectorSlot) = s.removeFacetSelectors(selectorCount, selectorSlot, facetCut);
                }
            }

            if (selectorCount != originalSelectorCount) {
                s.selectorCount = uint16(selectorCount);
            }

            // If last selector slot is not full
            if (selectorCount & 7 > 0) {
                s.selectorSlots[selectorCount >> 3] = selectorSlot;
            }
        }
    }

    function addFacetSelectors(
        Layout storage s,
        uint256 selectorCount,
        bytes32 selectorSlot,
        IDiamondCutCommon.FacetCut memory facetCut
    ) internal returns (uint256, bytes32) {
        unchecked {
            if (facetCut.facet != address(this)) {
                // allows immutable functions to be added from a constructor
                require(facetCut.facet.isContract(), "Diamond: facet has no code"); // reverts if executed from a constructor
            }

            uint256 length = facetCut.selectors.length;
            for (uint256 i; i != length; ++i) {
                bytes4 selector = facetCut.selectors[i];
                bytes32 oldFacet = s.diamondFacets[selector];

                require(address(bytes20(oldFacet)) == address(0), "Diamond: selector already added");

                // add facet for selector
                s.diamondFacets[selector] = bytes20(facetCut.facet) | bytes32(selectorCount);
                uint256 selectorInSlotPosition = (selectorCount & 7) << 5;

                // clear selector position in slot and add selector
                selectorSlot = (selectorSlot & ~(CLEAR_SELECTOR_MASK >> selectorInSlotPosition)) | (bytes32(selector) >> selectorInSlotPosition);

                // if slot is full then write it to storage
                if (selectorInSlotPosition == 224) {
                    s.selectorSlots[selectorCount >> 3] = selectorSlot;
                    selectorSlot = 0;
                }

                ++selectorCount;
            }

            return (selectorCount, selectorSlot);
        }
    }

    function removeFacetSelectors(
        Layout storage s,
        uint256 selectorCount,
        bytes32 selectorSlot,
        IDiamondCutCommon.FacetCut memory facetCut
    ) internal returns (uint256, bytes32) {
        unchecked {
            require(facetCut.facet == address(0), "Diamond: non-zero address facet");

            uint256 selectorSlotCount = selectorCount >> 3;
            uint256 selectorInSlotIndex = selectorCount & 7;

            for (uint256 i; i != facetCut.selectors.length; ++i) {
                bytes4 selector = facetCut.selectors[i];
                bytes32 oldFacet = s.diamondFacets[selector];

                require(address(bytes20(oldFacet)) != address(0), "Diamond: selector not found");
                require(address(bytes20(oldFacet)) != address(this), "Diamond: immutable function");

                if (selectorSlot == 0) {
                    selectorSlotCount--;
                    selectorSlot = s.selectorSlots[selectorSlotCount];
                    selectorInSlotIndex = 7;
                } else {
                    selectorInSlotIndex--;
                }

                bytes4 lastSelector;
                uint256 oldSelectorsSlotCount;
                uint256 oldSelectorInSlotPosition;

                // adding a block here prevents stack too deep error
                {
                    // replace selector with last selector in l.facets
                    lastSelector = bytes4(selectorSlot << (selectorInSlotIndex << 5));

                    if (lastSelector != selector) {
                        // update last selector slot position info
                        s.diamondFacets[lastSelector] = (oldFacet & CLEAR_ADDRESS_MASK) | bytes20(s.diamondFacets[lastSelector]);
                    }

                    delete s.diamondFacets[selector];
                    uint256 oldSelectorCount = uint16(uint256(oldFacet));
                    oldSelectorsSlotCount = oldSelectorCount >> 3;
                    oldSelectorInSlotPosition = (oldSelectorCount & 7) << 5;
                }

                if (oldSelectorsSlotCount != selectorSlotCount) {
                    bytes32 oldSelectorSlot = s.selectorSlots[oldSelectorsSlotCount];

                    // clears the selector we are deleting and puts the last selector in its place.
                    oldSelectorSlot =
                        (oldSelectorSlot & ~(CLEAR_SELECTOR_MASK >> oldSelectorInSlotPosition)) |
                        (bytes32(lastSelector) >> oldSelectorInSlotPosition);

                    // update storage with the modified slot
                    s.selectorSlots[oldSelectorsSlotCount] = oldSelectorSlot;
                } else {
                    // clears the selector we are deleting and puts the last selector in its place.
                    selectorSlot =
                        (selectorSlot & ~(CLEAR_SELECTOR_MASK >> oldSelectorInSlotPosition)) |
                        (bytes32(lastSelector) >> oldSelectorInSlotPosition);
                }

                if (selectorInSlotIndex == 0) {
                    delete s.selectorSlots[selectorSlotCount];
                    selectorSlot = 0;
                }
            }

            selectorCount = (selectorSlotCount << 3) | selectorInSlotIndex;

            return (selectorCount, selectorSlot);
        }
    }

    function replaceFacetSelectors(Layout storage s, IDiamondCutCommon.FacetCut memory facetCut) internal {
        unchecked {
            require(facetCut.facet.isContract(), "Diamond: facet has no code");

            uint256 length = facetCut.selectors.length;
            for (uint256 i; i != length; ++i) {
                bytes4 selector = facetCut.selectors[i];
                bytes32 oldFacet = s.diamondFacets[selector];
                address oldFacetAddress = address(bytes20(oldFacet));

                require(oldFacetAddress != address(0), "Diamond: selector not found");
                require(oldFacetAddress != address(this), "Diamond: immutable function");
                require(oldFacetAddress != facetCut.facet, "Diamond: identical function");

                // replace old facet address
                s.diamondFacets[selector] = (oldFacet & CLEAR_ADDRESS_MASK) | bytes20(facetCut.facet);
            }
        }
    }

    function initializationCall(address target, bytes memory data) internal {
        if (target == address(0)) {
            require(data.length == 0, "Diamond: data is not empty");
        } else {
            require(data.length != 0, "Diamond: data is empty");
            if (target != address(this)) {
                require(target.isContract(), "Diamond: target has no code");
            }

            (bool success, bytes memory returndata) = target.delegatecall(data);
            if (!success) {
                uint256 returndataLength = returndata.length;
                if (returndataLength != 0) {
                    assembly {
                        revert(add(32, returndata), returndataLength)
                    }
                } else {
                    revert("Diamond: init call reverted");
                }
            }
        }
    }

    function facets(Layout storage s) internal view returns (IDiamondLoupe.Facet[] memory diamondFacets) {
        unchecked {
            uint16 selectorCount = s.selectorCount;
            diamondFacets = new IDiamondLoupe.Facet[](selectorCount);

            uint256[] memory numFacetSelectors = new uint256[](selectorCount);
            uint256 numFacets;
            uint256 selectorIndex;

            // loop through function selectors
            for (uint256 slotIndex; selectorIndex < selectorCount; ++slotIndex) {
                bytes32 slot = s.selectorSlots[slotIndex];

                for (uint256 selectorSlotIndex; selectorSlotIndex != 8; ++selectorSlotIndex) {
                    ++selectorIndex;

                    if (selectorIndex > selectorCount) {
                        break;
                    }

                    bytes4 selector = bytes4(slot << (selectorSlotIndex << 5));
                    address facet = address(bytes20(s.diamondFacets[selector]));

                    bool continueLoop;

                    for (uint256 facetIndex; facetIndex != numFacets; ++facetIndex) {
                        if (diamondFacets[facetIndex].facet == facet) {
                            diamondFacets[facetIndex].selectors[numFacetSelectors[facetIndex]] = selector;
                            ++numFacetSelectors[facetIndex];
                            continueLoop = true;
                            break;
                        }
                    }

                    if (continueLoop) {
                        continue;
                    }

                    diamondFacets[numFacets].facet = facet;
                    diamondFacets[numFacets].selectors = new bytes4[](selectorCount);
                    diamondFacets[numFacets].selectors[0] = selector;
                    numFacetSelectors[numFacets] = 1;
                    ++numFacets;
                }
            }

            for (uint256 facetIndex; facetIndex != numFacets; ++facetIndex) {
                uint256 numSelectors = numFacetSelectors[facetIndex];
                bytes4[] memory selectors = diamondFacets[facetIndex].selectors;

                // setting the number of selectors
                assembly {
                    mstore(selectors, numSelectors)
                }
            }

            // setting the number of facets
            assembly {
                mstore(diamondFacets, numFacets)
            }
        }
    }

    function facetFunctionSelectors(Layout storage s, address facet) internal view returns (bytes4[] memory selectors) {
        unchecked {
            uint16 selectorCount = s.selectorCount;
            selectors = new bytes4[](selectorCount);

            uint256 numSelectors;
            uint256 selectorIndex;

            // loop through function selectors
            for (uint256 slotIndex; selectorIndex < selectorCount; ++slotIndex) {
                bytes32 slot = s.selectorSlots[slotIndex];

                for (uint256 selectorSlotIndex; selectorSlotIndex != 8; ++selectorSlotIndex) {
                    ++selectorIndex;

                    if (selectorIndex > selectorCount) {
                        break;
                    }

                    bytes4 selector = bytes4(slot << (selectorSlotIndex << 5));

                    if (facet == address(bytes20(s.diamondFacets[selector]))) {
                        selectors[numSelectors] = selector;
                        ++numSelectors;
                    }
                }
            }

            // set the number of selectors in the array
            assembly {
                mstore(selectors, numSelectors)
            }
        }
    }

    function facetAddresses(Layout storage s) internal view returns (address[] memory addresses) {
        unchecked {
            uint16 selectorCount = s.selectorCount;
            addresses = new address[](selectorCount);
            uint256 numFacets;
            uint256 selectorIndex;

            for (uint256 slotIndex; selectorIndex < selectorCount; ++slotIndex) {
                bytes32 slot = s.selectorSlots[slotIndex];

                for (uint256 selectorSlotIndex; selectorSlotIndex != 8; ++selectorSlotIndex) {
                    ++selectorIndex;

                    if (selectorIndex > selectorCount) {
                        break;
                    }

                    bytes4 selector = bytes4(slot << (selectorSlotIndex << 5));
                    address facet = address(bytes20(s.diamondFacets[selector]));

                    bool continueLoop;

                    for (uint256 facetIndex; facetIndex != numFacets; ++facetIndex) {
                        if (facet == addresses[facetIndex]) {
                            continueLoop = true;
                            break;
                        }
                    }

                    if (continueLoop) {
                        continue;
                    }

                    addresses[numFacets] = facet;
                    ++numFacets;
                }
            }

            // set the number of facet addresses in the array
            assembly {
                mstore(addresses, numFacets)
            }
        }
    }

    function facetAddress(Layout storage s, bytes4 selector) internal view returns (address facet) {
        facet = address(bytes20(s.diamondFacets[selector]));
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