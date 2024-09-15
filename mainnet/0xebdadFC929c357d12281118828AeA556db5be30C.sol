// SPDX-License-Identifier: GPL-3.0
pragma experimental ABIEncoderV2;

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;





interface IPolicy {
    function activateForFund(address _comptrollerProxy) external;

    function addFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings) external;

    function canDisable() external pure returns (bool canDisable_);

    function identifier() external pure returns (string memory identifier_);

    function implementedHooks()
        external
        pure
        returns (IPolicyManager.PolicyHook[] memory implementedHooks_);

    function updateFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings)
        external;

    function validateRule(
        address _comptrollerProxy,
        IPolicyManager.PolicyHook _hook,
        bytes calldata _encodedArgs
    ) external returns (bool isValid_);
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;






abstract contract PolicyBase is IPolicy {
    address internal immutable POLICY_MANAGER;

    modifier onlyPolicyManager {
        require(msg.sender == POLICY_MANAGER, "Only the PolicyManager can make this call");
        _;
    }

    constructor(address _policyManager) public {
        POLICY_MANAGER = _policyManager;
    }

    
    
    function activateForFund(address) external virtual override {
        return;
    }

    
    
    
    function canDisable() external pure virtual override returns (bool canDisable_) {
        return false;
    }

    
    
    function updateFundSettings(address, bytes calldata) external virtual override {
        revert("updateFundSettings: Updates not allowed for this policy");
    }

    //////////////////////////////
    // VALIDATION DATA DECODING //
    //////////////////////////////

    
    function __decodeAddTrackedAssetsValidationData(bytes memory _validationData)
        internal
        pure
        returns (address caller_, address[] memory assets_)
    {
        return abi.decode(_validationData, (address, address[]));
    }

    
    function __decodeCreateExternalPositionValidationData(bytes memory _validationData)
        internal
        pure
        returns (
            address caller_,
            uint256 typeId_,
            bytes memory initializationData_
        )
    {
        return abi.decode(_validationData, (address, uint256, bytes));
    }

    
    function __decodePreTransferSharesValidationData(bytes memory _validationData)
        internal
        pure
        returns (
            address sender_,
            address recipient_,
            uint256 amount_
        )
    {
        return abi.decode(_validationData, (address, address, uint256));
    }

    
    function __decodePostBuySharesValidationData(bytes memory _validationData)
        internal
        pure
        returns (
            address buyer_,
            uint256 investmentAmount_,
            uint256 sharesIssued_,
            uint256 gav_
        )
    {
        return abi.decode(_validationData, (address, uint256, uint256, uint256));
    }

    
    function __decodePostCallOnExternalPositionValidationData(bytes memory _validationData)
        internal
        pure
        returns (
            address caller_,
            address externalPosition_,
            address[] memory assetsToTransfer_,
            uint256[] memory amountsToTransfer_,
            address[] memory assetsToReceive_,
            bytes memory encodedActionData_
        )
    {
        return
            abi.decode(
                _validationData,
                (address, address, address[], uint256[], address[], bytes)
            );
    }

    
    function __decodePostCallOnIntegrationValidationData(bytes memory _validationData)
        internal
        pure
        returns (
            address caller_,
            address adapter_,
            bytes4 selector_,
            address[] memory incomingAssets_,
            uint256[] memory incomingAssetAmounts_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_
        )
    {
        return
            abi.decode(
                _validationData,
                (address, address, bytes4, address[], uint256[], address[], uint256[])
            );
    }

    
    function __decodeReactivateExternalPositionValidationData(bytes memory _validationData)
        internal
        pure
        returns (address caller_, address externalPosition_)
    {
        return abi.decode(_validationData, (address, address));
    }

    
    function __decodeRedeemSharesForSpecificAssetsValidationData(bytes memory _validationData)
        internal
        pure
        returns (
            address redeemer_,
            address recipient_,
            uint256 sharesToRedeemPostFees_,
            address[] memory assets_,
            uint256[] memory assetAmounts_,
            uint256 gavPreRedeem_
        )
    {
        return
            abi.decode(
                _validationData,
                (address, address, uint256, address[], uint256[], uint256)
            );
    }

    
    function __decodeRemoveExternalPositionValidationData(bytes memory _validationData)
        internal
        pure
        returns (address caller_, address externalPosition_)
    {
        return abi.decode(_validationData, (address, address));
    }

    
    function __decodeRemoveTrackedAssetsValidationData(bytes memory _validationData)
        internal
        pure
        returns (address caller_, address[] memory assets_)
    {
        return abi.decode(_validationData, (address, address[]));
    }

    ///////////////////
    // STATE GETTERS //
    ///////////////////

    
    
    function getPolicyManager() external view returns (address policyManager_) {
        return POLICY_MANAGER;
    }
}
// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;





interface IPolicyManager {
    // When updating PolicyHook, also update these functions in PolicyManager:
    // 1. __getAllPolicyHooks()
    // 2. __policyHookRestrictsCurrentInvestorActions()
    enum PolicyHook {
        PostBuyShares,
        PostCallOnIntegration,
        PreTransferShares,
        RedeemSharesForSpecificAssets,
        AddTrackedAssets,
        RemoveTrackedAssets,
        CreateExternalPosition,
        PostCallOnExternalPosition,
        RemoveExternalPosition,
        ReactivateExternalPosition
    }

    function validatePolicies(
        address,
        PolicyHook,
        bytes calldata
    ) external;
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;







/// send in a single call to buy shares in a fund
contract MinMaxInvestmentPolicy is PolicyBase {
    event FundSettingsSet(
        address indexed comptrollerProxy,
        uint256 minInvestmentAmount,
        uint256 maxInvestmentAmount
    );

    struct FundSettings {
        uint256 minInvestmentAmount;
        uint256 maxInvestmentAmount;
    }

    mapping(address => FundSettings) private comptrollerProxyToFundSettings;

    constructor(address _policyManager) public PolicyBase(_policyManager) {}

    
    
    
    function addFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings)
        external
        override
        onlyPolicyManager
    {
        __setFundSettings(_comptrollerProxy, _encodedSettings);
    }

    
    
    function canDisable() external pure virtual override returns (bool canDisable_) {
        return true;
    }

    
    
    function identifier() external pure override returns (string memory identifier_) {
        return "MIN_MAX_INVESTMENT";
    }

    
    
    function implementedHooks()
        external
        pure
        override
        returns (IPolicyManager.PolicyHook[] memory implementedHooks_)
    {
        implementedHooks_ = new IPolicyManager.PolicyHook[](1);
        implementedHooks_[0] = IPolicyManager.PolicyHook.PostBuyShares;

        return implementedHooks_;
    }

    
    
    
    function updateFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings)
        external
        override
        onlyPolicyManager
    {
        __setFundSettings(_comptrollerProxy, _encodedSettings);
    }

    
    
    
    
    function passesRule(address _comptrollerProxy, uint256 _investmentAmount)
        public
        view
        returns (bool isValid_)
    {
        uint256 minInvestmentAmount = comptrollerProxyToFundSettings[_comptrollerProxy]
            .minInvestmentAmount;
        uint256 maxInvestmentAmount = comptrollerProxyToFundSettings[_comptrollerProxy]
            .maxInvestmentAmount;

        // Both minInvestmentAmount and maxInvestmentAmount can be 0 in order to close the fund
        // temporarily
        if (minInvestmentAmount == 0) {
            return _investmentAmount <= maxInvestmentAmount;
        } else if (maxInvestmentAmount == 0) {
            return _investmentAmount >= minInvestmentAmount;
        }
        return
            _investmentAmount >= minInvestmentAmount && _investmentAmount <= maxInvestmentAmount;
    }

    
    
    
    
    
    function validateRule(
        address _comptrollerProxy,
        IPolicyManager.PolicyHook,
        bytes calldata _encodedArgs
    ) external override returns (bool isValid_) {
        (, uint256 investmentAmount, , ) = __decodePostBuySharesValidationData(_encodedArgs);

        return passesRule(_comptrollerProxy, investmentAmount);
    }

    
    
    
    function __setFundSettings(address _comptrollerProxy, bytes memory _encodedSettings) private {
        (uint256 minInvestmentAmount, uint256 maxInvestmentAmount) = abi.decode(
            _encodedSettings,
            (uint256, uint256)
        );

        require(
            maxInvestmentAmount == 0 || minInvestmentAmount < maxInvestmentAmount,
            "__setFundSettings: minInvestmentAmount must be less than maxInvestmentAmount"
        );

        comptrollerProxyToFundSettings[_comptrollerProxy]
            .minInvestmentAmount = minInvestmentAmount;
        comptrollerProxyToFundSettings[_comptrollerProxy]
            .maxInvestmentAmount = maxInvestmentAmount;

        emit FundSettingsSet(_comptrollerProxy, minInvestmentAmount, maxInvestmentAmount);
    }

    ///////////////////
    // STATE GETTERS //
    ///////////////////

    
    
    
    function getFundSettings(address _comptrollerProxy)
        external
        view
        returns (FundSettings memory fundSettings_)
    {
        return comptrollerProxyToFundSettings[_comptrollerProxy];
    }
}
