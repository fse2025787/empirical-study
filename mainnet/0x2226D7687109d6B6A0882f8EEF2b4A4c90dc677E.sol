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



interface ITheGraphDelegationPosition is IExternalPosition {
    enum Actions {Delegate, Undelegate, Withdraw}
}

// 

/*
    This file is part of the Enzyme Protocol.
    (c) Enzyme Council <[email protected]>
    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;





abstract contract TheGraphDelegationPositionDataDecoder {
    
    function __decodeDelegateActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (address indexer_, uint256 tokens_)
    {
        return abi.decode(_actionArgs, (address, uint256));
    }

    
    function __decodeUndelegateActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (address indexer_, uint256 shares_)
    {
        return abi.decode(_actionArgs, (address, uint256));
    }

    
    function __decodeWithdrawActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (address indexer_, address nextIndexer_)
    {
        return abi.decode(_actionArgs, (address, address));
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




contract TheGraphDelegationPositionParser is
    IExternalPositionParser,
    TheGraphDelegationPositionDataDecoder
{
    address private immutable GRT_TOKEN;

    constructor(address _grtToken) public {
        GRT_TOKEN = _grtToken;
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
        if (_actionId == uint256(ITheGraphDelegationPosition.Actions.Delegate)) {
            (, uint256 amount) = __decodeDelegateActionArgs(_encodedActionArgs);

            assetsToTransfer_ = new address[](1);
            assetsToTransfer_[0] = GRT_TOKEN;

            amountsToTransfer_ = new uint256[](1);
            amountsToTransfer_[0] = amount;
        } else {
            // Action.Undelegate and Action.Withdraw
            assetsToReceive_ = new address[](1);
            assetsToReceive_[0] = GRT_TOKEN;
        }

        return (assetsToTransfer_, amountsToTransfer_, assetsToReceive_);
    }

    
    
    function parseInitArgs(address, bytes memory) external override returns (bytes memory) {}
}