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



interface IExternalPosition {
    function getDebtAssets() external returns (address[] memory, uint256[] memory);

    function getManagedAssets() external returns (address[] memory, uint256[] memory);

    function init(bytes memory) external;

    function receiveCallFromVault(bytes memory) external;
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;




interface IExternalPositionParser {
    function parseAssetsForAction(
        address _externalPosition,
        uint256 _actionId,
        bytes memory _encodedActionArgs
    )
        external
        returns (
            address[] memory assetsToTransfer_,
            uint256[] memory amountsToTransfer_,
            address[] memory assetsToReceive_
        );

    function parseInitArgs(address _vaultProxy, bytes memory _initializationData)
        external
        returns (bytes memory initArgs_);
}

// 

/*
    This file is part of the Enzyme Protocol.
    (c) Enzyme Council <[email protected]>
    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/



pragma solidity 0.6.12;



interface INotionalV2Position is IExternalPosition {
    enum Actions {
        AddCollateral,
        Lend,
        Redeem,
        Borrow
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




abstract contract NotionalV2PositionDataDecoder {
    
    function __decodeAddCollateralActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (uint16 currencyId_, uint256 collateralAssetAmount_)
    {
        return abi.decode(_actionArgs, (uint16, uint256));
    }

    
    function __decodeBorrowActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (
            uint16 borrowCurrencyId_,
            bytes32 encodedBorrowTrade_,
            uint16 collateralCurrencyId_,
            uint256 collateralAssetAmount_
        )
    {
        return abi.decode(_actionArgs, (uint16, bytes32, uint16, uint256));
    }

    
    function __decodeLendActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (
            uint16 currencyId_,
            uint256 underlyingTokenAmount_,
            bytes32 encodedLendTrade_
        )
    {
        return abi.decode(_actionArgs, (uint16, uint256, bytes32));
    }

    
    function __decodeRedeemActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (uint16 currencyId_, uint88 yieldTokenAmount_)
    {
        return abi.decode(_actionArgs, (uint16, uint88));
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










contract NotionalV2PositionParser is NotionalV2PositionDataDecoder, IExternalPositionParser {
    uint16 private constant ETH_CURRENCY_ID = 1;

    uint8 private constant BORROW_TRADE_ACTION_TYPE = 1;
    uint8 private constant LEND_TRADE_ACTION_TYPE = 0;

    INotionalV2Router private immutable NOTIONAL_V2_ROUTER_CONTRACT;
    address private immutable WETH_TOKEN;

    constructor(address _notionalV2Router, address _weth) public {
        NOTIONAL_V2_ROUTER_CONTRACT = INotionalV2Router(_notionalV2Router);
        WETH_TOKEN = _weth;
    }

    
    
    
    
    
    
    function parseAssetsForAction(
        address,
        uint256 _actionId,
        bytes memory _encodedActionArgs
    )
        external
        override
        returns (
            address[] memory assetsToTransfer_,
            uint256[] memory amountsToTransfer_,
            address[] memory assetsToReceive_
        )
    {
        if (_actionId == uint256(INotionalV2Position.Actions.AddCollateral)) {
            (uint16 currencyId, uint256 collateralAssetAmount) = __decodeAddCollateralActionArgs(
                _encodedActionArgs
            );

            assetsToTransfer_ = new address[](1);
            amountsToTransfer_ = new uint256[](1);

            assetsToTransfer_[0] = __getAssetForCurrencyId(currencyId);
            amountsToTransfer_[0] = collateralAssetAmount;
        } else if (_actionId == uint256(INotionalV2Position.Actions.Lend)) {
            (
                uint16 currencyId,
                uint256 underlyingAssetAmount,
                bytes32 encodedTrade
            ) = __decodeLendActionArgs(_encodedActionArgs);

            require(
                uint8(bytes1(encodedTrade)) == LEND_TRADE_ACTION_TYPE,
                "parseAssetsForAction: Incorrect trade action type"
            );

            assetsToTransfer_ = new address[](1);
            amountsToTransfer_ = new uint256[](1);

            assetsToTransfer_[0] = __getAssetForCurrencyId(currencyId);
            amountsToTransfer_[0] = underlyingAssetAmount;
        } else if (_actionId == uint256(INotionalV2Position.Actions.Redeem)) {
            (uint16 currencyId, ) = __decodeRedeemActionArgs(_encodedActionArgs);

            assetsToReceive_ = new address[](1);
            assetsToReceive_[0] = __getAssetForCurrencyId(currencyId);
        } else if (_actionId == uint256(INotionalV2Position.Actions.Borrow)) {
            (
                uint16 borrowCurrencyId,
                bytes32 encodedTrade,
                uint16 collateralCurrencyId,
                uint256 collateralAssetAmount
            ) = __decodeBorrowActionArgs(_encodedActionArgs);

            require(
                uint8(bytes1(encodedTrade)) == BORROW_TRADE_ACTION_TYPE,
                "parseAssetsForAction: Incorrect trade action type"
            );

            if (collateralAssetAmount > 0) {
                assetsToTransfer_ = new address[](1);
                amountsToTransfer_ = new uint256[](1);

                assetsToTransfer_[0] = __getAssetForCurrencyId(collateralCurrencyId);
                amountsToTransfer_[0] = collateralAssetAmount;
            }

            assetsToReceive_ = new address[](1);
            assetsToReceive_[0] = __getAssetForCurrencyId(borrowCurrencyId);
        }

        return (assetsToTransfer_, amountsToTransfer_, assetsToReceive_);
    }

    
    
    function parseInitArgs(address, bytes memory) external override returns (bytes memory) {
        return "";
    }

    // PRIVATE FUNCTIONS

    
    function __getAssetForCurrencyId(uint16 _currencyId) private view returns (address asset_) {
        if (_currencyId == ETH_CURRENCY_ID) {
            return WETH_TOKEN;
        }

        (, INotionalV2Router.Token memory token) = NOTIONAL_V2_ROUTER_CONTRACT.getCurrency(
            _currencyId
        );

        return token.tokenAddress;
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





interface INotionalV2Router {
    enum AssetStorageState {
        NoChange,
        Update,
        Delete,
        RevertIfStored
    }
    enum DepositActionType {
        None,
        DepositAsset,
        DepositUnderlying,
        DepositAssetAndMintNToken,
        DepositUnderlyingAndMintNToken,
        RedeemNToken,
        ConvertCashToNToken
    }
    enum TokenType {
        UnderlyingToken,
        cToken,
        cETH,
        Ether,
        NonMintable,
        aToken
    }

    struct AccountBalance {
        uint16 currencyId;
        int256 cashBalance;
        int256 nTokenBalance;
        uint256 lastClaimTime;
        uint256 accountIncentiveDebt;
    }

    struct AccountContext {
        uint40 nextSettleTime;
        bytes1 hasDebt;
        uint8 assetArrayLength;
        uint16 bitmapCurrencyId;
        bytes18 activeCurrencies;
    }

    struct BalanceActionWithTrades {
        DepositActionType actionType;
        uint16 currencyId;
        uint256 depositActionAmount;
        uint256 withdrawAmountInternalPrecision;
        bool withdrawEntireCashBalance;
        bool redeemToUnderlying;
        bytes32[] trades;
    }

    struct PortfolioAsset {
        uint256 currencyId;
        uint256 maturity;
        uint256 assetType;
        int256 notional;
        uint256 storageSlot;
        AssetStorageState storageState;
    }

    struct Token {
        address tokenAddress;
        bool hasTransferFee;
        int256 decimals;
        TokenType tokenType;
        uint256 maxCollateralBalance;
    }

    function batchBalanceAndTradeAction(
        address _account,
        BalanceActionWithTrades[] calldata _actions
    ) external payable;

    function depositUnderlyingToken(
        address _account,
        uint16 _currencyId,
        uint256 _amountExternalPrecision
    ) external payable returns (uint256);

    function getAccount(address _account)
        external
        view
        returns (
            AccountContext memory accountContext_,
            AccountBalance[] memory accountBalances_,
            PortfolioAsset[] memory portfolio_
        );

    function getAccountBalance(uint16 _currencyId, address _account)
        external
        view
        returns (
            int256 cashBalance_,
            int256 nTokenBalance_,
            uint256 lastClaimTime_
        );

    function getAccountPortfolio(address _account)
        external
        view
        returns (PortfolioAsset[] memory portfolio_);

    function getCurrency(uint16 _currencyId)
        external
        view
        returns (Token memory assetToken_, Token memory underlyingToken_);

    function getPresentfCashValue(
        uint16 _currencyId,
        uint256 _maturity,
        int256 _notional,
        uint256 _blockTime,
        bool _riskAdjusted
    ) external view returns (int256 presentValue_);

    function withdraw(
        uint16 _currencyId,
        uint88 _amountInternalPrecision,
        bool _redeemToUnderlying
    ) external returns (uint256 amount_);
}