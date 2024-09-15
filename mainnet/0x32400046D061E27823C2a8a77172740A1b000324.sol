// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

// 







contract DiamondProxy {
    constructor(Diamond.DiamondCutData memory _diamondCut) {
        Diamond.diamondCut(_diamondCut);
    }

    
    
    fallback() external payable {
        Diamond.DiamondStorage storage diamondStorage = Diamond.getDiamondStorage();
        // Check whether the data contains a "full" selector or it is empty.
        // Required because Diamond proxy finds a facet by function signature,
        // which is not defined for data length in range [1, 3].
        require(msg.data.length >= 4 || msg.data.length == 0, "Ut");
        // Get facet from function selector
        Diamond.SelectorToFacet memory facet = diamondStorage.selectorToFacet[msg.sig];
        address facetAddress = facet.facetAddress;

        require(facetAddress != address(0), "F"); // Proxy has no facet for this selector
        require(!diamondStorage.isFrozen || !facet.isFreezable, "q1"); // Facet is frozen

        assembly {
            // The pointer to the free memory slot
            let ptr := mload(0x40)
            // Copy function signature and arguments from calldata at zero position into memory at pointer position
            calldatacopy(ptr, 0, calldatasize())
            // Delegatecall method of the implementation contract returns 0 on error
            let result := delegatecall(gas(), facetAddress, ptr, calldatasize(), 0, 0)
            // Get the size of the last return data
            let size := returndatasize()
            // Copy the size length of bytes from return data at zero position to pointer position
            returndatacopy(ptr, 0, size)
            // Depending on the result value
            switch result
            case 0 {
                // End execution and revert state changes
                revert(ptr, size)
            }
            default {
                // Return data with length of size at pointers position
                return(ptr, size)
            }
        }
    }
}

pragma solidity ^0.8.0;

// 





library Diamond {
    
    
    bytes32 constant DIAMOND_INIT_SUCCESS_RETURN_VALUE =
        0x33774e659306e47509050e97cb651e731180a42d458212294d30751925c551a2; // keccak256("diamond.zksync.init") - 1

    
    bytes32 constant DIAMOND_STORAGE_POSITION = 0xc8fcad8db84d3cc18b4c41d551ea0ee66dd599cde068d998e57d5e09332c131b; // keccak256("diamond.standard.diamond.storage") - 1;

    event DiamondCut(FacetCut[] facetCuts, address initAddress, bytes initCalldata);

    
    
    
    
    struct SelectorToFacet {
        address facetAddress;
        uint16 selectorPosition;
        bool isFreezable;
    }

    
    
    
    struct FacetToSelectors {
        bytes4[] selectors;
        uint16 facetPosition;
    }

    
    
    
    
    
    
    struct DiamondStorage {
        mapping(bytes4 => SelectorToFacet) selectorToFacet;
        mapping(address => FacetToSelectors) facetToSelectors;
        address[] facets;
        bool isFrozen;
    }

    
    
    
    
    
    struct FacetCut {
        address facet;
        Action action;
        bool isFreezable;
        bytes4[] selectors;
    }

    
    
    
    
    struct DiamondCutData {
        FacetCut[] facetCuts;
        address initAddress;
        bytes initCalldata;
    }

    
    
    enum Action {
        Add,
        Replace,
        Remove
    }

    
    function getDiamondStorage() internal pure returns (DiamondStorage storage diamondStorage) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            diamondStorage.slot := position
        }
    }

    
    
    function diamondCut(DiamondCutData memory _diamondCut) internal {
        FacetCut[] memory facetCuts = _diamondCut.facetCuts;
        address initAddress = _diamondCut.initAddress;
        bytes memory initCalldata = _diamondCut.initCalldata;
        uint256 facetCutsLength = facetCuts.length;
        for (uint256 i = 0; i < facetCutsLength; ++i) {
            Action action = facetCuts[i].action;
            address facet = facetCuts[i].facet;
            bool isFacetFreezable = facetCuts[i].isFreezable;
            bytes4[] memory selectors = facetCuts[i].selectors;

            require(selectors.length > 0, "B"); // no functions for diamond cut

            if (action == Action.Add) {
                _addFunctions(facet, selectors, isFacetFreezable);
            } else if (action == Action.Replace) {
                _replaceFunctions(facet, selectors, isFacetFreezable);
            } else if (action == Action.Remove) {
                _removeFunctions(facet, selectors);
            } else {
                revert("C"); // undefined diamond cut action
            }
        }

        _initializeDiamondCut(initAddress, initCalldata);
        emit DiamondCut(facetCuts, initAddress, initCalldata);
    }

    
    /// NOTE: expect but NOT enforce that `_selectors` is NON-EMPTY array
    function _addFunctions(
        address _facet,
        bytes4[] memory _selectors,
        bool _isFacetFreezable
    ) private {
        DiamondStorage storage ds = getDiamondStorage();

        require(_facet != address(0), "G"); // facet with zero address cannot be added

        // Add facet to the list of facets if the facet address is new one
        _saveFacetIfNew(_facet);

        uint256 selectorsLength = _selectors.length;
        for (uint256 i = 0; i < selectorsLength; ++i) {
            bytes4 selector = _selectors[i];
            SelectorToFacet memory oldFacet = ds.selectorToFacet[selector];
            require(oldFacet.facetAddress == address(0), "J"); // facet for this selector already exists

            _addOneFunction(_facet, selector, _isFacetFreezable);
        }
    }

    
    /// NOTE: expect but NOT enforce that `_selectors` is NON-EMPTY array
    function _replaceFunctions(
        address _facet,
        bytes4[] memory _selectors,
        bool _isFacetFreezable
    ) private {
        DiamondStorage storage ds = getDiamondStorage();

        require(_facet != address(0), "K"); // cannot replace facet with zero address

        uint256 selectorsLength = _selectors.length;
        for (uint256 i = 0; i < selectorsLength; ++i) {
            bytes4 selector = _selectors[i];
            SelectorToFacet memory oldFacet = ds.selectorToFacet[selector];
            require(oldFacet.facetAddress != address(0), "L"); // it is impossible to replace the facet with zero address

            _removeOneFunction(oldFacet.facetAddress, selector);
            // Add facet to the list of facets if the facet address is a new one
            _saveFacetIfNew(_facet);
            _addOneFunction(_facet, selector, _isFacetFreezable);
        }
    }

    
    /// NOTE: expect but NOT enforce that `_selectors` is NON-EMPTY array
    function _removeFunctions(address _facet, bytes4[] memory _selectors) private {
        DiamondStorage storage ds = getDiamondStorage();

        require(_facet == address(0), "a1"); // facet address must be zero

        uint256 selectorsLength = _selectors.length;
        for (uint256 i = 0; i < selectorsLength; ++i) {
            bytes4 selector = _selectors[i];
            SelectorToFacet memory oldFacet = ds.selectorToFacet[selector];
            require(oldFacet.facetAddress != address(0), "a2"); // Can't delete a non-existent facet

            _removeOneFunction(oldFacet.facetAddress, selector);
        }
    }

    
    /// NOTE: should be called ONLY before adding a new selector associated with the address
    function _saveFacetIfNew(address _facet) private {
        DiamondStorage storage ds = getDiamondStorage();

        uint256 selectorsLength = ds.facetToSelectors[_facet].selectors.length;
        // If there are no selectors associated with facet then save facet as new one
        if (selectorsLength == 0) {
            ds.facetToSelectors[_facet].facetPosition = uint16(ds.facets.length);
            ds.facets.push(_facet);
        }
    }

    
    /// NOTE: It is expected but NOT enforced that:
    /// - `_facet` is NON-ZERO address
    /// - `_facet` is already stored address in `DiamondStorage.facets`
    /// - `_selector` is NOT associated by another facet
    function _addOneFunction(
        address _facet,
        bytes4 _selector,
        bool _isSelectorFreezable
    ) private {
        DiamondStorage storage ds = getDiamondStorage();

        uint16 selectorPosition = uint16(ds.facetToSelectors[_facet].selectors.length);

        // if selectorPosition is nonzero, it means it is not a new facet
        // so the freezability of the first selector must be matched to _isSelectorFreezable
        // so all the selectors in a facet will have the same freezability
        if (selectorPosition != 0) {
            bytes4 selector0 = ds.facetToSelectors[_facet].selectors[0];
            require(_isSelectorFreezable == ds.selectorToFacet[selector0].isFreezable, "J1");
        }

        ds.selectorToFacet[_selector] = SelectorToFacet({
            facetAddress: _facet,
            selectorPosition: selectorPosition,
            isFreezable: _isSelectorFreezable
        });
        ds.facetToSelectors[_facet].selectors.push(_selector);
    }

    
    /// NOTE: It is expected but NOT enforced that `_facet` is NON-ZERO address
    function _removeOneFunction(address _facet, bytes4 _selector) private {
        DiamondStorage storage ds = getDiamondStorage();

        // Get index of `FacetToSelectors.selectors` of the selector and last element of array
        uint256 selectorPosition = ds.selectorToFacet[_selector].selectorPosition;
        uint256 lastSelectorPosition = ds.facetToSelectors[_facet].selectors.length - 1;

        // If the selector is not at the end of the array then move the last element to the selector position
        if (selectorPosition != lastSelectorPosition) {
            bytes4 lastSelector = ds.facetToSelectors[_facet].selectors[lastSelectorPosition];

            ds.facetToSelectors[_facet].selectors[selectorPosition] = lastSelector;
            ds.selectorToFacet[lastSelector].selectorPosition = uint16(selectorPosition);
        }

        // Remove last element from the selectors array
        ds.facetToSelectors[_facet].selectors.pop();

        // Finally, clean up the association with facet
        delete ds.selectorToFacet[_selector];

        // If there are no selectors for facet then remove the facet from the list of known facets
        if (lastSelectorPosition == 0) {
            _removeFacet(_facet);
        }
    }

    
    /// NOTE: It is expected but NOT enforced that there are no selectors associated wih `_facet`
    function _removeFacet(address _facet) private {
        DiamondStorage storage ds = getDiamondStorage();

        // Get index of `DiamondStorage.facets` of the facet and last element of array
        uint256 facetPosition = ds.facetToSelectors[_facet].facetPosition;
        uint256 lastFacetPosition = ds.facets.length - 1;

        // If the facet is not at the end of the array then move the last element to the facet position
        if (facetPosition != lastFacetPosition) {
            address lastFacet = ds.facets[lastFacetPosition];

            ds.facets[facetPosition] = lastFacet;
            ds.facetToSelectors[lastFacet].facetPosition = uint16(facetPosition);
        }

        // Remove last element from the facets array
        ds.facets.pop();
    }

    
    
    function _initializeDiamondCut(address _init, bytes memory _calldata) private {
        if (_init == address(0)) {
            require(_calldata.length == 0, "H"); // Non-empty calldata for zero address
        } else {
            // Do not check whether `_init` is a contract since later we check that it returns data.
            (bool success, bytes memory data) = _init.delegatecall(_calldata);
            require(success, "I"); // delegatecall failed

            // Check that called contract returns magic value to make sure that contract logic
            // supposed to be used as diamond cut initializer.
            require(data.length == 32, "lp");
            require(abi.decode(data, (bytes32)) == DIAMOND_INIT_SUCCESS_RETURN_VALUE, "lp1");
        }
    }
}