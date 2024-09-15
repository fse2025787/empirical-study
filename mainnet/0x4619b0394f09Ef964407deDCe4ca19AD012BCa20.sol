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







abstract contract ConvexVotingPositionDataDecoder {
    
    function __decodeClaimRewardsActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (
            address[] memory allTokensToTransfer_,
            bool claimLockerRewards_,
            address[] memory extraRewardTokens_,
            IVotiumMultiMerkleStash.ClaimParam[] memory votiumClaims_,
            bool unstakeCvxCrv_
        )
    {
        return
            abi.decode(
                _actionArgs,
                (address[], bool, address[], IVotiumMultiMerkleStash.ClaimParam[], bool)
            );
    }

    
    function __decodeDelegateActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (address delegatee_)
    {
        return abi.decode(_actionArgs, (address));
    }

    
    function __decodeLockActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (uint256 amount_, uint256 spendRatio_)
    {
        return abi.decode(_actionArgs, (uint256, uint256));
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




contract ConvexVotingPositionParser is IExternalPositionParser, ConvexVotingPositionDataDecoder {
    address private immutable CVX_TOKEN;

    constructor(address _cvxToken) public {
        CVX_TOKEN = _cvxToken;
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
        if (_actionId == uint256(IConvexVotingPosition.Actions.Lock)) {
            (uint256 amount, ) = __decodeLockActionArgs(_encodedActionArgs);

            assetsToTransfer_ = new address[](1);
            assetsToTransfer_[0] = CVX_TOKEN;

            amountsToTransfer_ = new uint256[](1);
            amountsToTransfer_[0] = amount;
        } else if (_actionId == uint256(IConvexVotingPosition.Actions.Withdraw)) {
            assetsToReceive_ = new address[](1);
            assetsToReceive_[0] = CVX_TOKEN;
        }

        // No validations or transferred assets passed for Actions.ClaimRewards

        return (assetsToTransfer_, amountsToTransfer_, assetsToReceive_);
    }

    
    
    function parseInitArgs(address, bytes memory) external override returns (bytes memory) {}
}

// 

/*
    This file is part of the Enzyme Protocol.
    (c) Enzyme Council <[email protected]>
    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/



pragma solidity 0.6.12;



interface IConvexVotingPosition is IExternalPosition {
    enum Actions {Lock, Relock, Withdraw, ClaimRewards, Delegate}
}

// 

/*
    This file is part of the Enzyme Protocol.
    (c) Enzyme Council <[email protected]>
    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;




interface IVotiumMultiMerkleStash {
    struct ClaimParam {
        address token;
        uint256 index;
        uint256 amount;
        bytes32[] merkleProof;
    }

    function claimMulti(address, ClaimParam[] calldata) external;
}