// SPDX-License-Identifier: Apache-2.0
pragma experimental ABIEncoderV2;


// 
/*

  Copyright 2021 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;







interface INativeOrdersEvents {
    
    
    
    
    
    
    
    
    
    event LimitOrderFilled(
        bytes32 orderHash,
        address maker,
        address taker,
        address feeRecipient,
        address makerToken,
        address takerToken,
        uint128 takerTokenFilledAmount,
        uint128 makerTokenFilledAmount,
        uint128 takerTokenFeeFilledAmount,
        uint256 protocolFeePaid,
        bytes32 pool
    );

    
    
    
    
    
    
    
    event RfqOrderFilled(
        bytes32 orderHash,
        address maker,
        address taker,
        address makerToken,
        address takerToken,
        uint128 takerTokenFilledAmount,
        uint128 makerTokenFilledAmount,
        bytes32 pool
    );

    
    
    
    event OrderCancelled(bytes32 orderHash, address maker);

    
    
    
    
    
    ///        have.
    event PairCancelledLimitOrders(address maker, address makerToken, address takerToken, uint256 minValidSalt);

    
    
    
    
    
    ///        have.
    event PairCancelledRfqOrders(address maker, address makerToken, address takerToken, uint256 minValidSalt);

    
    ///      orders with a given txOrigin.
    
    
    
    event RfqOrderOriginsAllowed(address origin, address[] addrs, bool allowed);

    
    
    
    
    event OrderSignerRegistered(address maker, address signer, bool allowed);
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;





interface IERC20Transformer {
    
    struct TransformContext {
        // The caller of `TransformERC20.transformERC20()`.
        address payable sender;
        // The recipient address, which may be distinct from `sender` e.g. in
        // meta-transactions.
        address payable recipient;
        // Arbitrary data to pass to the transformer.
        bytes data;
    }

    
    ///      delegatecalled in the context of the FlashWallet instance being used.
    
    
    function transform(TransformContext calldata context) external returns (bytes4 success);
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;

interface IOwnableV06 {
    
    
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    
    function transferOwnership(address newOwner) external;

    
    
    function owner() external view returns (address ownerAddress);
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;








interface INativeOrdersFeature is INativeOrdersEvents {
    
    ///      the staking contract.
    
    function transferProtocolFeesForPools(bytes32[] calldata poolIds) external;

    
    
    ///      attached to this call. Any unspent ETH will be refunded to
    ///      the caller.
    
    
    
    
    function fillLimitOrder(
        LibNativeOrder.LimitOrder calldata order,
        LibSignature.Signature calldata signature,
        uint128 takerTokenFillAmount
    ) external payable returns (uint128 takerTokenFilledAmount, uint128 makerTokenFilledAmount);

    
    ///      The taker will be the caller.
    
    
    
    
    
    function fillRfqOrder(
        LibNativeOrder.RfqOrder calldata order,
        LibSignature.Signature calldata signature,
        uint128 takerTokenFillAmount
    ) external returns (uint128 takerTokenFilledAmount, uint128 makerTokenFilledAmount);

    
    ///      The taker will be the caller. ETH protocol fees can be
    ///      attached to this call. Any unspent ETH will be refunded to
    ///      the caller.
    
    
    
    
    function fillOrKillLimitOrder(
        LibNativeOrder.LimitOrder calldata order,
        LibSignature.Signature calldata signature,
        uint128 takerTokenFillAmount
    ) external payable returns (uint128 makerTokenFilledAmount);

    
    ///      The taker will be the caller.
    
    
    
    
    function fillOrKillRfqOrder(
        LibNativeOrder.RfqOrder calldata order,
        LibSignature.Signature calldata signature,
        uint128 takerTokenFillAmount
    ) external returns (uint128 makerTokenFilledAmount);

    
    ///      attached to this call. Any unspent ETH will be refunded to
    ///      `msg.sender` (not `sender`).
    
    
    
    
    
    
    
    function _fillLimitOrder(
        LibNativeOrder.LimitOrder calldata order,
        LibSignature.Signature calldata signature,
        uint128 takerTokenFillAmount,
        address taker,
        address sender
    ) external payable returns (uint128 takerTokenFilledAmount, uint128 makerTokenFilledAmount);

    
    
    
    
    
    
    ///        balance of taker tokens to fill the order.
    
    
    
    function _fillRfqOrder(
        LibNativeOrder.RfqOrder calldata order,
        LibSignature.Signature calldata signature,
        uint128 takerTokenFillAmount,
        address taker,
        bool useSelfBalance,
        address recipient
    ) external returns (uint128 takerTokenFilledAmount, uint128 makerTokenFilledAmount);

    
    ///      Silently succeeds if the order has already been cancelled.
    
    function cancelLimitOrder(LibNativeOrder.LimitOrder calldata order) external;

    
    ///      Silently succeeds if the order has already been cancelled.
    
    function cancelRfqOrder(LibNativeOrder.RfqOrder calldata order) external;

    
    ///      specifies the message sender as its txOrigin.
    
    
    function registerAllowedRfqOrigins(address[] memory origins, bool allowed) external;

    
    ///      Silently succeeds if the order has already been cancelled.
    
    function batchCancelLimitOrders(LibNativeOrder.LimitOrder[] calldata orders) external;

    
    ///      Silently succeeds if the order has already been cancelled.
    
    function batchCancelRfqOrders(LibNativeOrder.RfqOrder[] calldata orders) external;

    
    ///      than the value provided. The caller must be the maker. Subsequent
    ///      calls to this function with the same caller and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    function cancelPairLimitOrders(
        IERC20TokenV06 makerToken,
        IERC20TokenV06 takerToken,
        uint256 minValidSalt
    ) external;

    
    ///      than the value provided. The caller must be a signer registered to the maker.
    ///      Subsequent calls to this function with the same maker and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    
    function cancelPairLimitOrdersWithSigner(
        address maker,
        IERC20TokenV06 makerToken,
        IERC20TokenV06 takerToken,
        uint256 minValidSalt
    ) external;

    
    ///      than the values provided. The caller must be the maker. Subsequent
    ///      calls to this function with the same caller and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    function batchCancelPairLimitOrders(
        IERC20TokenV06[] calldata makerTokens,
        IERC20TokenV06[] calldata takerTokens,
        uint256[] calldata minValidSalts
    ) external;

    
    ///      than the values provided. The caller must be a signer registered to the maker.
    ///      Subsequent calls to this function with the same maker and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    
    function batchCancelPairLimitOrdersWithSigner(
        address maker,
        IERC20TokenV06[] memory makerTokens,
        IERC20TokenV06[] memory takerTokens,
        uint256[] memory minValidSalts
    ) external;

    
    ///      than the value provided. The caller must be the maker. Subsequent
    ///      calls to this function with the same caller and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    function cancelPairRfqOrders(
        IERC20TokenV06 makerToken,
        IERC20TokenV06 takerToken,
        uint256 minValidSalt
    ) external;

    
    ///      than the value provided. The caller must be a signer registered to the maker.
    ///      Subsequent calls to this function with the same maker and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    
    function cancelPairRfqOrdersWithSigner(
        address maker,
        IERC20TokenV06 makerToken,
        IERC20TokenV06 takerToken,
        uint256 minValidSalt
    ) external;

    
    ///      than the values provided. The caller must be the maker. Subsequent
    ///      calls to this function with the same caller and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    function batchCancelPairRfqOrders(
        IERC20TokenV06[] calldata makerTokens,
        IERC20TokenV06[] calldata takerTokens,
        uint256[] calldata minValidSalts
    ) external;

    
    ///      than the values provided. The caller must be a signer registered to the maker.
    ///      Subsequent calls to this function with the same maker and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    
    function batchCancelPairRfqOrdersWithSigner(
        address maker,
        IERC20TokenV06[] memory makerTokens,
        IERC20TokenV06[] memory takerTokens,
        uint256[] memory minValidSalts
    ) external;

    
    
    
    function getLimitOrderInfo(LibNativeOrder.LimitOrder calldata order)
        external
        view
        returns (LibNativeOrder.OrderInfo memory orderInfo);

    
    
    
    function getRfqOrderInfo(LibNativeOrder.RfqOrder calldata order)
        external
        view
        returns (LibNativeOrder.OrderInfo memory orderInfo);

    
    
    
    function getLimitOrderHash(LibNativeOrder.LimitOrder calldata order) external view returns (bytes32 orderHash);

    
    
    
    function getRfqOrderHash(LibNativeOrder.RfqOrder calldata order) external view returns (bytes32 orderHash);

    
    ///      gas price to arrive at the required protocol fee to fill a native order.
    
    function getProtocolFeeMultiplier() external view returns (uint32 multiplier);

    
    ///      Fillable amount is determined using balances and allowances of the maker.
    
    
    
    
    ///         based on maker funds, in taker tokens.
    
    function getLimitOrderRelevantState(
        LibNativeOrder.LimitOrder calldata order,
        LibSignature.Signature calldata signature
    )
        external
        view
        returns (
            LibNativeOrder.OrderInfo memory orderInfo,
            uint128 actualFillableTakerTokenAmount,
            bool isSignatureValid
        );

    
    ///      Fillable amount is determined using balances and allowances of the maker.
    
    
    
    
    ///         based on maker funds, in taker tokens.
    
    function getRfqOrderRelevantState(LibNativeOrder.RfqOrder calldata order, LibSignature.Signature calldata signature)
        external
        view
        returns (
            LibNativeOrder.OrderInfo memory orderInfo,
            uint128 actualFillableTakerTokenAmount,
            bool isSignatureValid
        );

    
    ///      Orders that would normally cause `getLimitOrderRelevantState()`
    ///      to revert will have empty results.
    
    
    
    
    ///         based on maker funds, in taker tokens.
    
    function batchGetLimitOrderRelevantStates(
        LibNativeOrder.LimitOrder[] calldata orders,
        LibSignature.Signature[] calldata signatures
    )
        external
        view
        returns (
            LibNativeOrder.OrderInfo[] memory orderInfos,
            uint128[] memory actualFillableTakerTokenAmounts,
            bool[] memory isSignatureValids
        );

    
    ///      Orders that would normally cause `getRfqOrderRelevantState()`
    ///      to revert will have empty results.
    
    
    
    
    ///         based on maker funds, in taker tokens.
    
    function batchGetRfqOrderRelevantStates(
        LibNativeOrder.RfqOrder[] calldata orders,
        LibSignature.Signature[] calldata signatures
    )
        external
        view
        returns (
            LibNativeOrder.OrderInfo[] memory orderInfos,
            uint128[] memory actualFillableTakerTokenAmounts,
            bool[] memory isSignatureValids
        );

    
    ///      This allows one to sign on behalf of a contract that calls this function
    
    
    function registerAllowedOrderSigner(address signer, bool allowed) external;

    
    
    
    function isValidOrderSigner(address maker, address signer) external view returns (bool isAllowed);
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;







abstract contract Transformer is IERC20Transformer {
    using LibRichErrorsV06 for bytes;

    
    address public immutable deployer;
    
    address internal immutable _implementation;

    
    constructor() public {
        deployer = msg.sender;
        _implementation = address(this);
    }

    
    ///      succeed in the context of a delegatecall (from another contract).
    
    function die(address payable ethRecipient) external virtual {
        // Only the deployer can call this.
        if (msg.sender != deployer) {
            LibTransformERC20RichErrors.OnlyCallableByDeployerError(msg.sender, deployer).rrevert();
        }
        // Must be executing our own context.
        if (address(this) != _implementation) {
            LibTransformERC20RichErrors.InvalidExecutionContextError(address(this), _implementation).rrevert();
        }
        selfdestruct(ethRecipient);
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;




// solhint-disable no-empty-blocks

interface IOwnableFeature is IOwnableV06 {
    
    
    
    
    event Migrated(address caller, address migrator, address newOwner);

    
    ///      The result of the function being called should be the magic bytes
    ///      0x2c64c5ef (`keccack('MIGRATE_SUCCESS')`). Only callable by the owner.
    ///      The owner will be temporarily set to `address(this)` inside the call.
    ///      Before returning, the owner will be set to `newOwner`.
    
    
    
    function migrate(
        address target,
        bytes calldata data,
        address newOwner
    ) external;
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



interface ISimpleFunctionRegistryFeature {
    
    
    
    
    event ProxyFunctionUpdated(bytes4 indexed selector, address oldImpl, address newImpl);

    
    
    
    function rollback(bytes4 selector, address targetImpl) external;

    
    
    
    function extend(bytes4 selector, address impl) external;

    
    
    
    ///         the function.
    function getRollbackLength(bytes4 selector) external view returns (uint256 rollbackLength);

    
    
    
    
    ///         index `idx`.
    function getRollbackEntryAtIndex(bytes4 selector, uint256 idx) external view returns (address impl);
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;







interface ITransformERC20Feature {
    
    struct Transformation {
        // The deployment nonce for the transformer.
        // The address of the transformer contract will be derived from this
        // value.
        uint32 deploymentNonce;
        // Arbitrary data to pass to the transformer.
        bytes data;
    }

    
    struct TransformERC20Args {
        // The taker address.
        address payable taker;
        // The token being provided by the taker.
        // If `0xeee...`, ETH is implied and should be provided with the call.`
        IERC20TokenV06 inputToken;
        // The token to be acquired by the taker.
        // `0xeee...` implies ETH.
        IERC20TokenV06 outputToken;
        // The amount of `inputToken` to take from the taker.
        // If set to `uint256(-1)`, the entire spendable balance of the taker
        // will be solt.
        uint256 inputTokenAmount;
        // The minimum amount of `outputToken` the taker
        // must receive for the entire transformation to succeed. If set to zero,
        // the minimum output token transfer will not be asserted.
        uint256 minOutputTokenAmount;
        // The transformations to execute on the token balance(s)
        // in sequence.
        Transformation[] transformations;
        // Whether to use the Exchange Proxy's balance of `inputToken`.
        bool useSelfBalance;
        // The recipient of the bought `outputToken`.
        address payable recipient;
    }

    
    
    
    ///        If `0xeee...`, ETH is implied and should be provided with the call.`
    
    ///        `0xeee...` implies ETH.
    
    
    event TransformedERC20(
        address indexed taker,
        address inputToken,
        address outputToken,
        uint256 inputTokenAmount,
        uint256 outputTokenAmount
    );

    
    
    event TransformerDeployerUpdated(address transformerDeployer);

    
    
    event QuoteSignerUpdated(address quoteSigner);

    
    ///      Only callable by the owner.
    
    ///        for transformers.
    function setTransformerDeployer(address transformerDeployer) external;

    
    ///      Only callable by the owner.
    
    function setQuoteSigner(address quoteSigner) external;

    
    ///      Useful if we somehow break the current wallet instance.
    ///       Only callable by the owner.
    
    function createTransformWallet() external returns (IFlashWallet wallet);

    
    ///      to an ERC20 `outputToken`.
    
    ///        If `0xeee...`, ETH is implied and should be provided with the call.`
    
    ///        `0xeee...` implies ETH.
    
    
    ///        must receive for the entire transformation to succeed.
    
    ///        in sequence.
    
    function transformERC20(
        IERC20TokenV06 inputToken,
        IERC20TokenV06 outputToken,
        uint256 inputTokenAmount,
        uint256 minOutputTokenAmount,
        Transformation[] calldata transformations
    ) external payable returns (uint256 outputTokenAmount);

    
    
    
    function _transformERC20(TransformERC20Args calldata args) external payable returns (uint256 outputTokenAmount);

    
    ///      context for transformations.
    
    function getTransformWallet() external view returns (IFlashWallet wallet);

    
    
    function getTransformerDeployer() external view returns (address deployer);

    
    
    function getQuoteSigner() external view returns (address signer);
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;






interface IMetaTransactionsFeature {
    
    struct MetaTransactionData {
        // Signer of meta-transaction. On whose behalf to execute the MTX.
        address payable signer;
        // Required sender, or NULL for anyone.
        address sender;
        // Minimum gas price.
        uint256 minGasPrice;
        // Maximum gas price.
        uint256 maxGasPrice;
        // MTX is invalid after this time.
        uint256 expirationTimeSeconds;
        // Nonce to make this MTX unique.
        uint256 salt;
        // Encoded call data to a function on the exchange proxy.
        bytes callData;
        // Amount of ETH to attach to the call.
        uint256 value;
        // ERC20 fee `signer` pays `sender`.
        IERC20TokenV06 feeToken;
        // ERC20 fee amount.
        uint256 feeAmount;
    }

    
    ///      `executeMetaTransaction()` or `executeMetaTransactions()`.
    
    
    
    
    event MetaTransactionExecuted(bytes32 hash, bytes4 indexed selector, address signer, address sender);

    
    
    
    
    function executeMetaTransaction(MetaTransactionData calldata mtx, LibSignature.Signature calldata signature)
        external
        payable
        returns (bytes memory returnResult);

    
    
    
    
    function batchExecuteMetaTransactions(
        MetaTransactionData[] calldata mtxs,
        LibSignature.Signature[] calldata signatures
    ) external payable returns (bytes[] memory returnResults);

    
    
    
    function getMetaTransactionExecutedBlock(MetaTransactionData calldata mtx)
        external
        view
        returns (uint256 blockNumber);

    
    
    
    function getMetaTransactionHashExecutedBlock(bytes32 mtxHash) external view returns (uint256 blockNumber);

    
    
    
    function getMetaTransactionHash(MetaTransactionData calldata mtx) external view returns (bytes32 mtxHash);
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;





interface IUniswapFeature {
    
    
    
    
    
    
    function sellToUniswap(
        IERC20TokenV06[] calldata tokens,
        uint256 sellAmount,
        uint256 minBuyAmount,
        bool isSushi
    ) external payable returns (uint256 buyAmount);
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;





interface IUniswapV3Feature {
    
    
    
    
    
    function sellEthForTokenToUniswapV3(
        bytes memory encodedPath,
        uint256 minBuyAmount,
        address recipient
    ) external payable returns (uint256 buyAmount);

    
    
    
    
    
    
    function sellTokenForEthToUniswapV3(
        bytes memory encodedPath,
        uint256 sellAmount,
        uint256 minBuyAmount,
        address payable recipient
    ) external returns (uint256 buyAmount);

    
    
    
    
    
    
    function sellTokenForTokenToUniswapV3(
        bytes memory encodedPath,
        uint256 sellAmount,
        uint256 minBuyAmount,
        address recipient
    ) external returns (uint256 buyAmount);

    
    ///      Private variant, uses tokens held by `address(this)`.
    
    
    
    
    
    function _sellHeldTokenForTokenToUniswapV3(
        bytes memory encodedPath,
        uint256 sellAmount,
        uint256 minBuyAmount,
        address recipient
    ) external returns (uint256 buyAmount);

    
    ///      by the caller/pool to the pool. Can only be called by a valid
    ///      UniswapV3 pool.
    
    
    
    ///        struct of: inputToken, outputToken, fee, payer
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}

// 
/*

  Copyright 2021 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;





interface IPancakeSwapFeature {
    enum ProtocolFork {
        PancakeSwap,
        PancakeSwapV2,
        BakerySwap,
        SushiSwap,
        ApeSwap,
        CafeSwap,
        CheeseSwap,
        JulSwap
    }

    
    
    
    
    
    
    function sellToPancakeSwap(
        IERC20TokenV06[] calldata tokens,
        uint256 sellAmount,
        uint256 minBuyAmount,
        ProtocolFork fork
    ) external payable returns (uint256 buyAmount);
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;






interface ILiquidityProviderFeature {
    
    event LiquidityProviderSwap(
        IERC20TokenV06 inputToken,
        IERC20TokenV06 outputToken,
        uint256 inputTokenAmount,
        uint256 outputTokenAmount,
        ILiquidityProvider provider,
        address recipient
    );

    
    ///      at the given `provider` address.
    
    
    
    ///        to trade with.
    
    ///        address(0), `msg.sender` is assumed to be the recipient.
    
    
    ///        buy. Reverts if this amount is not satisfied.
    
    
    function sellToLiquidityProvider(
        IERC20TokenV06 inputToken,
        IERC20TokenV06 outputToken,
        ILiquidityProvider provider,
        address recipient,
        uint256 sellAmount,
        uint256 minBuyAmount,
        bytes calldata auxiliaryData
    ) external payable returns (uint256 boughtAmount);
}

// 
/*

  Copyright 2021 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;






interface IBatchFillNativeOrdersFeature {
    
    
    
    
    
    ///        fill the full fill amount for any individual order.
    
    
    function batchFillLimitOrders(
        LibNativeOrder.LimitOrder[] calldata orders,
        LibSignature.Signature[] calldata signatures,
        uint128[] calldata takerTokenFillAmounts,
        bool revertIfIncomplete
    ) external payable returns (uint128[] memory takerTokenFilledAmounts, uint128[] memory makerTokenFilledAmounts);

    
    
    
    
    
    ///        fill the full fill amount for any individual order.
    
    
    function batchFillRfqOrders(
        LibNativeOrder.RfqOrder[] calldata orders,
        LibSignature.Signature[] calldata signatures,
        uint128[] calldata takerTokenFillAmounts,
        bool revertIfIncomplete
    ) external returns (uint128[] memory takerTokenFilledAmounts, uint128[] memory makerTokenFilledAmounts);
}

// 
/*

  Copyright 2021 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;




interface IMultiplexFeature {
    // Identifies the type of subcall.
    enum MultiplexSubcall {
        Invalid,
        RFQ,
        OTC,
        UniswapV2,
        UniswapV3,
        LiquidityProvider,
        TransformERC20,
        BatchSell,
        MultiHopSell
    }

    // Parameters for a batch sell.
    struct BatchSellParams {
        // The token being sold.
        IERC20TokenV06 inputToken;
        // The token being bought.
        IERC20TokenV06 outputToken;
        // The amount of `inputToken` to sell.
        uint256 sellAmount;
        // The nested calls to perform.
        BatchSellSubcall[] calls;
        // Whether to use the Exchange Proxy's balance
        // of input tokens.
        bool useSelfBalance;
        // The recipient of the bought output tokens.
        address recipient;
    }

    // Represents a constituent call of a batch sell.
    struct BatchSellSubcall {
        // The function to call.
        MultiplexSubcall id;
        // Amount of input token to sell. If the highest bit is 1,
        // this value represents a proportion of the total
        // `sellAmount` of the batch sell. See `_normalizeSellAmount`
        // for details.
        uint256 sellAmount;
        // ABI-encoded parameters needed to perform the call.
        bytes data;
    }

    // Parameters for a multi-hop sell.
    struct MultiHopSellParams {
        // The sell path, i.e.
        // tokens = [inputToken, hopToken1, ..., hopTokenN, outputToken]
        address[] tokens;
        // The amount of `tokens[0]` to sell.
        uint256 sellAmount;
        // The nested calls to perform.
        MultiHopSellSubcall[] calls;
        // Whether to use the Exchange Proxy's balance
        // of input tokens.
        bool useSelfBalance;
        // The recipient of the bought output tokens.
        address recipient;
    }

    // Represents a constituent call of a multi-hop sell.
    struct MultiHopSellSubcall {
        // The function to call.
        MultiplexSubcall id;
        // ABI-encoded parameters needed to perform the call.
        bytes data;
    }

    struct BatchSellState {
        // Tracks the amount of input token sold.
        uint256 soldAmount;
        // Tracks the amount of output token bought.
        uint256 boughtAmount;
    }

    struct MultiHopSellState {
        // This variable is used for the input and output amounts of
        // each hop. After the final hop, this will contain the output
        // amount of the multi-hop sell.
        uint256 outputTokenAmount;
        // For each hop in a multi-hop sell, `from` is the
        // address that holds the input tokens of the hop,
        // `to` is the address that receives the output tokens
        // of the hop.
        // See `_computeHopTarget` for details.
        address from;
        address to;
        // The index of the current hop in the multi-hop chain.
        uint256 hopIndex;
    }

    
    ///      calls.
    
    
    
    ///        must be bought for this function to not revert.
    
    function multiplexBatchSellEthForToken(
        IERC20TokenV06 outputToken,
        BatchSellSubcall[] calldata calls,
        uint256 minBuyAmount
    ) external payable returns (uint256 boughtAmount);

    
    ///      using the provided calls.
    
    
    
    
    ///        must be bought for this function to not revert.
    
    function multiplexBatchSellTokenForEth(
        IERC20TokenV06 inputToken,
        BatchSellSubcall[] calldata calls,
        uint256 sellAmount,
        uint256 minBuyAmount
    ) external returns (uint256 boughtAmount);

    
    ///      `outputToken` using the provided calls.
    
    
    
    
    
    ///        that must be bought for this function to not revert.
    
    function multiplexBatchSellTokenForToken(
        IERC20TokenV06 inputToken,
        IERC20TokenV06 outputToken,
        BatchSellSubcall[] calldata calls,
        uint256 sellAmount,
        uint256 minBuyAmount
    ) external returns (uint256 boughtAmount);

    
    ///      and calls. `tokens[0]` must be WETH.
    ///      The last token in `tokens` is the output token that
    ///      will ultimately be sent to `msg.sender`
    
    ///        i.e. `tokens[i]` will be sold for `tokens[i+1]` via
    ///        `calls[i]`.
    
    
    ///        must be bought for this function to not revert.
    
    function multiplexMultiHopSellEthForToken(
        address[] calldata tokens,
        MultiHopSellSubcall[] calldata calls,
        uint256 minBuyAmount
    ) external payable returns (uint256 boughtAmount);

    
    ///      for ETH via the given sequence of tokens and calls.
    ///      The last token in `tokens` must be WETH.
    
    ///        i.e. `tokens[i]` will be sold for `tokens[i+1]` via
    ///        `calls[i]`.
    
    
    ///        must be bought for this function to not revert.
    
    function multiplexMultiHopSellTokenForEth(
        address[] calldata tokens,
        MultiHopSellSubcall[] calldata calls,
        uint256 sellAmount,
        uint256 minBuyAmount
    ) external returns (uint256 boughtAmount);

    
    ///      via the given sequence of tokens and calls.
    ///      The last token in `tokens` is the output token that
    ///      will ultimately be sent to `msg.sender`
    
    ///        i.e. `tokens[i]` will be sold for `tokens[i+1]` via
    ///        `calls[i]`.
    
    
    ///        must be bought for this function to not revert.
    
    function multiplexMultiHopSellTokenForToken(
        address[] calldata tokens,
        MultiHopSellSubcall[] calldata calls,
        uint256 sellAmount,
        uint256 minBuyAmount
    ) external returns (uint256 boughtAmount);
}

// 
/*

  Copyright 2021 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;






interface IOtcOrdersFeature {
    
    
    
    
    
    
    event OtcOrderFilled(
        bytes32 orderHash,
        address maker,
        address taker,
        address makerToken,
        address takerToken,
        uint128 makerTokenFilledAmount,
        uint128 takerTokenFilledAmount
    );

    
    
    
    
    ///        order with.
    
    
    function fillOtcOrder(
        LibNativeOrder.OtcOrder calldata order,
        LibSignature.Signature calldata makerSignature,
        uint128 takerTokenFillAmount
    ) external returns (uint128 takerTokenFilledAmount, uint128 makerTokenFilledAmount);

    
    ///      Unwraps bought WETH into ETH before sending it to
    ///      the taker.
    
    
    
    ///        order with.
    
    
    function fillOtcOrderForEth(
        LibNativeOrder.OtcOrder calldata order,
        LibSignature.Signature calldata makerSignature,
        uint128 takerTokenFillAmount
    ) external returns (uint128 takerTokenFilledAmount, uint128 makerTokenFilledAmount);

    
    ///      to `msg.value`.
    
    
    
    
    function fillOtcOrderWithEth(LibNativeOrder.OtcOrder calldata order, LibSignature.Signature calldata makerSignature)
        external
        payable
        returns (uint128 takerTokenFilledAmount, uint128 makerTokenFilledAmount);

    
    ///      requires order to be signed by both maker and taker.
    
    
    
    function fillTakerSignedOtcOrder(
        LibNativeOrder.OtcOrder calldata order,
        LibSignature.Signature calldata makerSignature,
        LibSignature.Signature calldata takerSignature
    ) external;

    
    ///      requires order to be signed by both maker and taker.
    ///      Unwraps bought WETH into ETH before sending it to
    ///      the taker.
    
    
    
    function fillTakerSignedOtcOrderForEth(
        LibNativeOrder.OtcOrder calldata order,
        LibSignature.Signature calldata makerSignature,
        LibSignature.Signature calldata takerSignature
    ) external;

    
    
    
    
    
    ///        to unwrap bought WETH into ETH for each order. Should be set
    ///        to false if the maker token is not WETH.
    
    ///         each order in `orders` was filled successfully.
    function batchFillTakerSignedOtcOrders(
        LibNativeOrder.OtcOrder[] calldata orders,
        LibSignature.Signature[] calldata makerSignatures,
        LibSignature.Signature[] calldata takerSignatures,
        bool[] calldata unwrapWeth
    ) external returns (bool[] memory successes);

    
    ///      Internal variant.
    
    
    
    ///        order with.
    
    
    ///        of input tokens.
    
    
    
    function _fillOtcOrder(
        LibNativeOrder.OtcOrder calldata order,
        LibSignature.Signature calldata makerSignature,
        uint128 takerTokenFillAmount,
        address taker,
        bool useSelfBalance,
        address recipient
    ) external returns (uint128 takerTokenFilledAmount, uint128 makerTokenFilledAmount);

    
    
    
    function getOtcOrderInfo(LibNativeOrder.OtcOrder calldata order)
        external
        view
        returns (LibNativeOrder.OtcOrderInfo memory orderInfo);

    
    
    
    function getOtcOrderHash(LibNativeOrder.OtcOrder calldata order) external view returns (bytes32 orderHash);

    
    ///      tx.origin address and nonce bucket.
    
    
    
    function lastOtcTxOriginNonce(address txOrigin, uint64 nonceBucket) external view returns (uint128 lastNonce);
}

// 
/*
  Copyright 2020 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity ^0.6.5;





interface IFundRecoveryFeature {
    
    /// in the context of the Exchange Proxy instance being used.
    
    
    
    function transferTrappedTokensTo(
        IERC20TokenV06 erc20,
        uint256 amountOut,
        address payable recipientWallet
    ) external;
}

// 
/*

  Copyright 2021 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6;








interface IERC721OrdersFeature {
    
    
    ///        buying the ERC721 token.
    
    
    
    
    
    ///        to sell or buy.
    
    
    
    ///                this will be the address of the caller. If not, this will be `address(0)`.
    event ERC721OrderFilled(
        LibNFTOrder.TradeDirection direction,
        address maker,
        address taker,
        uint256 nonce,
        IERC20TokenV06 erc20Token,
        uint256 erc20TokenAmount,
        IERC721Token erc721Token,
        uint256 erc721TokenId,
        address matcher
    );

    
    
    
    event ERC721OrderCancelled(address maker, uint256 nonce);

    
    ///      Contains all the fields of the order.
    event ERC721OrderPreSigned(
        LibNFTOrder.TradeDirection direction,
        address maker,
        address taker,
        uint256 expiry,
        uint256 nonce,
        IERC20TokenV06 erc20Token,
        uint256 erc20TokenAmount,
        LibNFTOrder.Fee[] fees,
        IERC721Token erc721Token,
        uint256 erc721TokenId,
        LibNFTOrder.Property[] erc721TokenProperties
    );

    
    
    
    
    ///        sold. If the given order specifies properties,
    ///        the asset must satisfy those properties. Otherwise,
    ///        it must equal the tokenId in the order.
    
    ///        ERC20 token of the order is e.g. WETH, unwraps the
    ///        token before transferring it to the taker.
    
    ///        `zeroExERC721OrderCallback` on `msg.sender` after
    ///        the ERC20 tokens have been transferred to `msg.sender`
    ///        but before transferring the ERC721 asset to the buyer.
    function sellERC721(
        LibNFTOrder.ERC721Order calldata buyOrder,
        LibSignature.Signature calldata signature,
        uint256 erc721TokenId,
        bool unwrapNativeToken,
        bytes calldata callbackData
    ) external;

    
    
    
    
    ///        `zeroExERC721OrderCallback` on `msg.sender` after
    ///        the ERC721 asset has been transferred to `msg.sender`
    ///        but before transferring the ERC20 tokens to the seller.
    ///        Native tokens acquired during the callback can be used
    ///        to fill the order.
    function buyERC721(
        LibNFTOrder.ERC721Order calldata sellOrder,
        LibSignature.Signature calldata signature,
        bytes calldata callbackData
    ) external payable;

    
    ///      should be the maker of the order. Silently succeeds if
    ///      an order with the same nonce has already been filled or
    ///      cancelled.
    
    function cancelERC721Order(uint256 orderNonce) external;

    
    ///      should be the maker of the orders. Silently succeeds if
    ///      an order with the same nonce has already been filled or
    ///      cancelled.
    
    function batchCancelERC721Orders(uint256[] calldata orderNonces) external;

    
    ///      given orders.
    
    
    
    ///        callback for each order. Refer to the `callbackData`
    ///        parameter to for `buyERC721`.
    
    ///        function fails to fill any individual order.
    
    ///         each order in `orders` was successfully filled.
    function batchBuyERC721s(
        LibNFTOrder.ERC721Order[] calldata sellOrders,
        LibSignature.Signature[] calldata signatures,
        bytes[] calldata callbackData,
        bool revertIfIncomplete
    ) external payable returns (bool[] memory successes);

    
    ///      a non-negative spread. Each order is filled at
    ///      their respective price, and the matcher receives
    ///      a profit denominated in the ERC20 token.
    
    
    
    
    
    ///         of this function (denominated in the ERC20 token
    ///         of the matched orders).
    function matchERC721Orders(
        LibNFTOrder.ERC721Order calldata sellOrder,
        LibNFTOrder.ERC721Order calldata buyOrder,
        LibSignature.Signature calldata sellOrderSignature,
        LibSignature.Signature calldata buyOrderSignature
    ) external returns (uint256 profit);

    
    ///      non-negative spreads. Each order is filled at
    ///      their respective price, and the matcher receives
    ///      a profit denominated in the ERC20 token.
    
    
    
    
    
    ///         of this function for each pair of matched orders
    ///         (denominated in the ERC20 token of the order pair).
    
    ///         whether each pair of orders was successfully matched.
    function batchMatchERC721Orders(
        LibNFTOrder.ERC721Order[] calldata sellOrders,
        LibNFTOrder.ERC721Order[] calldata buyOrders,
        LibSignature.Signature[] calldata sellOrderSignatures,
        LibSignature.Signature[] calldata buyOrderSignatures
    ) external returns (uint256[] memory profits, bool[] memory successes);

    
    ///      This callback can be used to sell an ERC721 asset if
    ///      a valid ERC721 order, signature and `unwrapNativeToken`
    ///      are encoded in `data`. This allows takers to sell their
    ///      ERC721 asset without first calling `setApprovalForAll`.
    
    
    
    
    ///        valid ERC721 order, signature and `unwrapNativeToken`
    ///        are encoded in `data`, this function will try to fill
    ///        the order using the received asset.
    
    ///         indicating that the callback succeeded.
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4 success);

    
    ///      the order, the `PRESIGNED` signature type will become
    ///      valid for that order and signer.
    
    function preSignERC721Order(LibNFTOrder.ERC721Order calldata order) external;

    
    ///      the given ERC721 order. Reverts if not.
    
    
    function validateERC721OrderSignature(
        LibNFTOrder.ERC721Order calldata order,
        LibSignature.Signature calldata signature
    ) external view;

    
    ///      whether or not the given token ID satisfies the required
    ///      properties specified in the order. If the order does not
    ///      specify any properties, this function instead checks
    ///      whether the given token ID matches the ID in the order.
    ///      Reverts if any checks fail, or if the order is selling
    ///      an ERC721 asset.
    
    
    function validateERC721OrderProperties(LibNFTOrder.ERC721Order calldata order, uint256 erc721TokenId) external view;

    
    
    
    function getERC721OrderStatus(LibNFTOrder.ERC721Order calldata order)
        external
        view
        returns (LibNFTOrder.OrderStatus status);

    
    
    
    function getERC721OrderHash(LibNFTOrder.ERC721Order calldata order) external view returns (bytes32 orderHash);

    
    ///      maker address and nonce range.
    
    
    ///        by maker address and the upper 248 bits of the
    ///        order nonce. We define `nonceRange` to be these
    ///        248 bits.
    
    ///         given maker and nonce range.
    function getERC721OrderStatusBitVector(address maker, uint248 nonceRange) external view returns (uint256 bitVector);
}

// 
/*

  Copyright 2021 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6;








interface IERC1155OrdersFeature {
    
    
    ///        buying the ERC1155 token.
    
    
    
    
    
    
    
    
    
    event ERC1155OrderFilled(
        LibNFTOrder.TradeDirection direction,
        address maker,
        address taker,
        uint256 nonce,
        IERC20TokenV06 erc20Token,
        uint256 erc20FillAmount,
        IERC1155Token erc1155Token,
        uint256 erc1155TokenId,
        uint128 erc1155FillAmount,
        address matcher
    );

    
    
    
    event ERC1155OrderCancelled(address maker, uint256 nonce);

    
    ///      Contains all the fields of the order.
    event ERC1155OrderPreSigned(
        LibNFTOrder.TradeDirection direction,
        address maker,
        address taker,
        uint256 expiry,
        uint256 nonce,
        IERC20TokenV06 erc20Token,
        uint256 erc20TokenAmount,
        LibNFTOrder.Fee[] fees,
        IERC1155Token erc1155Token,
        uint256 erc1155TokenId,
        LibNFTOrder.Property[] erc1155TokenProperties,
        uint128 erc1155TokenAmount
    );

    
    
    
    
    ///        sold. If the given order specifies properties,
    ///        the asset must satisfy those properties. Otherwise,
    ///        it must equal the tokenId in the order.
    
    ///        to sell.
    
    ///        ERC20 token of the order is e.g. WETH, unwraps the
    ///        token before transferring it to the taker.
    
    ///        `zeroExERC1155OrderCallback` on `msg.sender` after
    ///        the ERC20 tokens have been transferred to `msg.sender`
    ///        but before transferring the ERC1155 asset to the buyer.
    function sellERC1155(
        LibNFTOrder.ERC1155Order calldata buyOrder,
        LibSignature.Signature calldata signature,
        uint256 erc1155TokenId,
        uint128 erc1155SellAmount,
        bool unwrapNativeToken,
        bytes calldata callbackData
    ) external;

    
    
    
    
    ///        to buy.
    
    ///        `zeroExERC1155OrderCallback` on `msg.sender` after
    ///        the ERC1155 asset has been transferred to `msg.sender`
    ///        but before transferring the ERC20 tokens to the seller.
    ///        Native tokens acquired during the callback can be used
    ///        to fill the order.
    function buyERC1155(
        LibNFTOrder.ERC1155Order calldata sellOrder,
        LibSignature.Signature calldata signature,
        uint128 erc1155BuyAmount,
        bytes calldata callbackData
    ) external payable;

    
    ///      should be the maker of the order. Silently succeeds if
    ///      an order with the same nonce has already been filled or
    ///      cancelled.
    
    function cancelERC1155Order(uint256 orderNonce) external;

    
    ///      should be the maker of the orders. Silently succeeds if
    ///      an order with the same nonce has already been filled or
    ///      cancelled.
    
    function batchCancelERC1155Orders(uint256[] calldata orderNonces) external;

    
    ///      given orders.
    
    
    
    ///        to buy for each order.
    
    ///        callback for each order. Refer to the `callbackData`
    ///        parameter to for `buyERC1155`.
    
    ///        function fails to fill any individual order.
    
    ///         each order in `orders` was successfully filled.
    function batchBuyERC1155s(
        LibNFTOrder.ERC1155Order[] calldata sellOrders,
        LibSignature.Signature[] calldata signatures,
        uint128[] calldata erc1155TokenAmounts,
        bytes[] calldata callbackData,
        bool revertIfIncomplete
    ) external payable returns (bool[] memory successes);

    
    ///      This callback can be used to sell an ERC1155 asset if
    ///      a valid ERC1155 order, signature and `unwrapNativeToken`
    ///      are encoded in `data`. This allows takers to sell their
    ///      ERC1155 asset without first calling `setApprovalForAll`.
    
    
    
    
    
    ///        valid ERC1155 order, signature and `unwrapNativeToken`
    ///        are encoded in `data`, this function will try to fill
    ///        the order using the received asset.
    
    ///         indicating that the callback succeeded.
    function onERC1155Received(
        address operator,
        address from,
        uint256 tokenId,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4 success);

    
    ///      the order, the `PRESIGNED` signature type will become
    ///      valid for that order and signer.
    
    function preSignERC1155Order(LibNFTOrder.ERC1155Order calldata order) external;

    
    ///      the given ERC1155 order. Reverts if not.
    
    
    function validateERC1155OrderSignature(
        LibNFTOrder.ERC1155Order calldata order,
        LibSignature.Signature calldata signature
    ) external view;

    
    ///      whether or not the given token ID satisfies the required
    ///      properties specified in the order. If the order does not
    ///      specify any properties, this function instead checks
    ///      whether the given token ID matches the ID in the order.
    ///      Reverts if any checks fail, or if the order is selling
    ///      an ERC1155 asset.
    
    
    function validateERC1155OrderProperties(LibNFTOrder.ERC1155Order calldata order, uint256 erc1155TokenId)
        external
        view;

    
    
    
    function getERC1155OrderInfo(LibNFTOrder.ERC1155Order calldata order)
        external
        view
        returns (LibNFTOrder.OrderInfo memory orderInfo);

    
    
    
    function getERC1155OrderHash(LibNFTOrder.ERC1155Order calldata order) external view returns (bytes32 orderHash);
}

// 
/*

  Copyright 2022 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6;



interface IERC165Feature {
    
    ///      ERC165 interface. This function should use at most 30,000 gas.
    
    
    ///         0x Exchange Proxy.
    function supportInterface(bytes4 interfaceId) external pure returns (bool isSupported);
}// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;
















///      This transformer shortcuts bridge orders and fills them directly
contract FillQuoteTransformer is Transformer {
    using LibERC20TokenV06 for IERC20TokenV06;
    using LibERC20Transformer for IERC20TokenV06;
    using LibSafeMathV06 for uint256;
    using LibSafeMathV06 for uint128;
    using LibRichErrorsV06 for bytes;

    
    enum Side {
        Sell,
        Buy
    }

    enum OrderType {
        Bridge,
        Limit,
        Rfq,
        Otc
    }

    struct LimitOrderInfo {
        LibNativeOrder.LimitOrder order;
        LibSignature.Signature signature;
        // Maximum taker token amount of this limit order to fill.
        uint256 maxTakerTokenFillAmount;
    }

    struct RfqOrderInfo {
        LibNativeOrder.RfqOrder order;
        LibSignature.Signature signature;
        // Maximum taker token amount of this limit order to fill.
        uint256 maxTakerTokenFillAmount;
    }

    struct OtcOrderInfo {
        LibNativeOrder.OtcOrder order;
        LibSignature.Signature signature;
        // Maximum taker token amount of this limit order to fill.
        uint256 maxTakerTokenFillAmount;
    }

    
    struct TransformData {
        // Whether we are performing a market sell or buy.
        Side side;
        // The token being sold.
        // This should be an actual token, not the ETH pseudo-token.
        IERC20TokenV06 sellToken;
        // The token being bought.
        // This should be an actual token, not the ETH pseudo-token.
        IERC20TokenV06 buyToken;
        // External liquidity bridge orders. Sorted by fill sequence.
        IBridgeAdapter.BridgeOrder[] bridgeOrders;
        // Native limit orders. Sorted by fill sequence.
        LimitOrderInfo[] limitOrders;
        // Native RFQ orders. Sorted by fill sequence.
        RfqOrderInfo[] rfqOrders;
        // The sequence to fill the orders in. Each item will fill the next
        // order of that type in either `bridgeOrders`, `limitOrders`,
        // or `rfqOrders.`
        OrderType[] fillSequence;
        // Amount of `sellToken` to sell or `buyToken` to buy.
        // For sells, setting the high-bit indicates that
        // `sellAmount & LOW_BITS` should be treated as a `1e18` fraction of
        // the current balance of `sellToken`, where
        // `1e18+ == 100%` and `0.5e18 == 50%`, etc.
        uint256 fillAmount;
        // Who to transfer unused protocol fees to.
        // May be a valid address or one of:
        // `address(0)`: Stay in flash wallet.
        // `address(1)`: Send to the taker.
        // `address(2)`: Send to the sender (caller of `transformERC20()`).
        address payable refundReceiver;
        // Otc orders. Sorted by fill sequence.
        OtcOrderInfo[] otcOrders;
    }

    struct FillOrderResults {
        // The amount of taker tokens sold, according to balance checks.
        uint256 takerTokenSoldAmount;
        // The amount of maker tokens sold, according to balance checks.
        uint256 makerTokenBoughtAmount;
        // The amount of protocol fee paid.
        uint256 protocolFeePaid;
    }

    
    struct FillState {
        uint256 ethRemaining;
        uint256 boughtAmount;
        uint256 soldAmount;
        uint256 protocolFee;
        uint256 takerTokenBalanceRemaining;
        uint256[4] currentIndices;
        OrderType currentOrderType;
    }

    
    ///      to pay the 0x Protocol fee.
    
    event ProtocolFeeUnfunded(bytes32 orderHash);

    
    uint256 private constant HIGH_BIT = 2**255;
    
    uint256 private constant LOWER_255_BITS = HIGH_BIT - 1;
    
    ///      protocol fees will be sent to the transform recipient.
    address private constant REFUND_RECEIVER_RECIPIENT = address(1);
    
    ///      protocol fees will be sent to the sender.
    address private constant REFUND_RECEIVER_SENDER = address(2);

    
    IBridgeAdapter public immutable bridgeAdapter;

    
    IZeroEx public immutable zeroEx;

    
    
    
    constructor(IBridgeAdapter bridgeAdapter_, IZeroEx zeroEx_) public Transformer() {
        bridgeAdapter = bridgeAdapter_;
        zeroEx = zeroEx_;
    }

    
    ///      for `buyToken` by filling `orders`. Protocol fees should be attached
    ///      to this call. `buyToken` and excess ETH will be transferred back to the caller.
    
    
    function transform(TransformContext calldata context) external override returns (bytes4 magicBytes) {
        TransformData memory data = abi.decode(context.data, (TransformData));
        FillState memory state;

        // Validate data fields.
        if (data.sellToken.isTokenETH() || data.buyToken.isTokenETH()) {
            LibTransformERC20RichErrors
                .InvalidTransformDataError(
                    LibTransformERC20RichErrors.InvalidTransformDataErrorCode.INVALID_TOKENS,
                    context.data
                )
                .rrevert();
        }

        if (
            data.bridgeOrders.length + data.limitOrders.length + data.rfqOrders.length + data.otcOrders.length !=
            data.fillSequence.length
        ) {
            LibTransformERC20RichErrors
                .InvalidTransformDataError(
                    LibTransformERC20RichErrors.InvalidTransformDataErrorCode.INVALID_ARRAY_LENGTH,
                    context.data
                )
                .rrevert();
        }

        state.takerTokenBalanceRemaining = data.sellToken.getTokenBalanceOf(address(this));
        if (data.side == Side.Sell) {
            data.fillAmount = _normalizeFillAmount(data.fillAmount, state.takerTokenBalanceRemaining);
        }

        // Approve the exchange proxy to spend our sell tokens if native orders
        // are present.
        if (data.limitOrders.length + data.rfqOrders.length + data.otcOrders.length != 0) {
            data.sellToken.approveIfBelow(address(zeroEx), data.fillAmount);
            // Compute the protocol fee if a limit order is present.
            if (data.limitOrders.length != 0) {
                state.protocolFee = uint256(zeroEx.getProtocolFeeMultiplier()).safeMul(tx.gasprice);
            }
        }

        state.ethRemaining = address(this).balance;

        // Fill the orders.
        for (uint256 i = 0; i < data.fillSequence.length; ++i) {
            // Check if we've hit our targets.
            if (data.side == Side.Sell) {
                // Market sell check.
                if (state.soldAmount >= data.fillAmount) {
                    break;
                }
            } else {
                // Market buy check.
                if (state.boughtAmount >= data.fillAmount) {
                    break;
                }
            }

            state.currentOrderType = OrderType(data.fillSequence[i]);
            uint256 orderIndex = state.currentIndices[uint256(state.currentOrderType)];
            // Fill the order.
            FillOrderResults memory results;
            if (state.currentOrderType == OrderType.Bridge) {
                results = _fillBridgeOrder(data.bridgeOrders[orderIndex], data, state);
            } else if (state.currentOrderType == OrderType.Limit) {
                results = _fillLimitOrder(data.limitOrders[orderIndex], data, state);
            } else if (state.currentOrderType == OrderType.Rfq) {
                results = _fillRfqOrder(data.rfqOrders[orderIndex], data, state);
            } else if (state.currentOrderType == OrderType.Otc) {
                results = _fillOtcOrder(data.otcOrders[orderIndex], data, state);
            } else {
                revert("INVALID_ORDER_TYPE");
            }

            // Accumulate totals.
            state.soldAmount = state.soldAmount.safeAdd(results.takerTokenSoldAmount);
            state.boughtAmount = state.boughtAmount.safeAdd(results.makerTokenBoughtAmount);
            state.ethRemaining = state.ethRemaining.safeSub(results.protocolFeePaid);
            state.takerTokenBalanceRemaining = state.takerTokenBalanceRemaining.safeSub(results.takerTokenSoldAmount);
            state.currentIndices[uint256(state.currentOrderType)]++;
        }

        // Ensure we hit our targets.
        if (data.side == Side.Sell) {
            // Market sell check.
            if (state.soldAmount < data.fillAmount) {
                LibTransformERC20RichErrors
                    .IncompleteFillSellQuoteError(address(data.sellToken), state.soldAmount, data.fillAmount)
                    .rrevert();
            }
        } else {
            // Market buy check.
            if (state.boughtAmount < data.fillAmount) {
                LibTransformERC20RichErrors
                    .IncompleteFillBuyQuoteError(address(data.buyToken), state.boughtAmount, data.fillAmount)
                    .rrevert();
            }
        }

        // Refund unspent protocol fees.
        if (state.ethRemaining > 0 && data.refundReceiver != address(0)) {
            bool transferSuccess;
            if (data.refundReceiver == REFUND_RECEIVER_RECIPIENT) {
                (transferSuccess, ) = context.recipient.call{value: state.ethRemaining}("");
            } else if (data.refundReceiver == REFUND_RECEIVER_SENDER) {
                (transferSuccess, ) = context.sender.call{value: state.ethRemaining}("");
            } else {
                (transferSuccess, ) = data.refundReceiver.call{value: state.ethRemaining}("");
            }
            require(transferSuccess, "FillQuoteTransformer/ETHER_TRANSFER_FALIED");
        }
        return LibERC20Transformer.TRANSFORMER_SUCCESS;
    }

    // Fill a single bridge order.
    function _fillBridgeOrder(
        IBridgeAdapter.BridgeOrder memory order,
        TransformData memory data,
        FillState memory state
    ) private returns (FillOrderResults memory results) {
        uint256 takerTokenFillAmount = _computeTakerTokenFillAmount(
            data,
            state,
            order.takerTokenAmount,
            order.makerTokenAmount,
            0
        );

        (bool success, bytes memory resultData) = address(bridgeAdapter).delegatecall(
            abi.encodeWithSelector(
                IBridgeAdapter.trade.selector,
                order,
                data.sellToken,
                data.buyToken,
                takerTokenFillAmount
            )
        );
        if (success) {
            results.makerTokenBoughtAmount = abi.decode(resultData, (uint256));
            results.takerTokenSoldAmount = takerTokenFillAmount;
        }
    }

    // Fill a single limit order.
    function _fillLimitOrder(
        LimitOrderInfo memory orderInfo,
        TransformData memory data,
        FillState memory state
    ) private returns (FillOrderResults memory results) {
        uint256 takerTokenFillAmount = LibSafeMathV06.min256(
            _computeTakerTokenFillAmount(
                data,
                state,
                orderInfo.order.takerAmount,
                orderInfo.order.makerAmount,
                orderInfo.order.takerTokenFeeAmount
            ),
            orderInfo.maxTakerTokenFillAmount
        );

        // Emit an event if we do not have sufficient ETH to cover the protocol fee.
        if (state.ethRemaining < state.protocolFee) {
            bytes32 orderHash = zeroEx.getLimitOrderHash(orderInfo.order);
            emit ProtocolFeeUnfunded(orderHash);
            return results; // Empty results.
        }

        try
            zeroEx.fillLimitOrder{value: state.protocolFee}(
                orderInfo.order,
                orderInfo.signature,
                takerTokenFillAmount.safeDowncastToUint128()
            )
        returns (uint128 takerTokenFilledAmount, uint128 makerTokenFilledAmount) {
            if (orderInfo.order.takerTokenFeeAmount > 0) {
                takerTokenFilledAmount = takerTokenFilledAmount.safeAdd128(
                    LibMathV06
                        .getPartialAmountFloor(
                            takerTokenFilledAmount,
                            orderInfo.order.takerAmount,
                            orderInfo.order.takerTokenFeeAmount
                        )
                        .safeDowncastToUint128()
                );
            }
            results.takerTokenSoldAmount = takerTokenFilledAmount;
            results.makerTokenBoughtAmount = makerTokenFilledAmount;
            results.protocolFeePaid = state.protocolFee;
        } catch {}
    }

    // Fill a single RFQ order.
    function _fillRfqOrder(
        RfqOrderInfo memory orderInfo,
        TransformData memory data,
        FillState memory state
    ) private returns (FillOrderResults memory results) {
        uint256 takerTokenFillAmount = LibSafeMathV06.min256(
            _computeTakerTokenFillAmount(data, state, orderInfo.order.takerAmount, orderInfo.order.makerAmount, 0),
            orderInfo.maxTakerTokenFillAmount
        );

        try
            zeroEx.fillRfqOrder(orderInfo.order, orderInfo.signature, takerTokenFillAmount.safeDowncastToUint128())
        returns (uint128 takerTokenFilledAmount, uint128 makerTokenFilledAmount) {
            results.takerTokenSoldAmount = takerTokenFilledAmount;
            results.makerTokenBoughtAmount = makerTokenFilledAmount;
        } catch {}
    }

    // Fill a single OTC order.
    function _fillOtcOrder(
        OtcOrderInfo memory orderInfo,
        TransformData memory data,
        FillState memory state
    ) private returns (FillOrderResults memory results) {
        uint256 takerTokenFillAmount = LibSafeMathV06.min256(
            _computeTakerTokenFillAmount(data, state, orderInfo.order.takerAmount, orderInfo.order.makerAmount, 0),
            orderInfo.maxTakerTokenFillAmount
        );
        try
            zeroEx.fillOtcOrder(orderInfo.order, orderInfo.signature, takerTokenFillAmount.safeDowncastToUint128())
        returns (uint128 takerTokenFilledAmount, uint128 makerTokenFilledAmount) {
            results.takerTokenSoldAmount = takerTokenFilledAmount;
            results.makerTokenBoughtAmount = makerTokenFilledAmount;
        } catch {
            revert("FillQuoteTransformer/OTC_ORDER_FILL_FAILED");
        }
    }

    // Compute the next taker token fill amount of a generic order.
    function _computeTakerTokenFillAmount(
        TransformData memory data,
        FillState memory state,
        uint256 orderTakerAmount,
        uint256 orderMakerAmount,
        uint256 orderTakerTokenFeeAmount
    ) private pure returns (uint256 takerTokenFillAmount) {
        if (data.side == Side.Sell) {
            takerTokenFillAmount = data.fillAmount.safeSub(state.soldAmount);
            if (orderTakerTokenFeeAmount != 0) {
                takerTokenFillAmount = LibMathV06.getPartialAmountCeil(
                    takerTokenFillAmount,
                    orderTakerAmount.safeAdd(orderTakerTokenFeeAmount),
                    orderTakerAmount
                );
            }
        } else {
            // Buy
            takerTokenFillAmount = LibMathV06.getPartialAmountCeil(
                data.fillAmount.safeSub(state.boughtAmount),
                orderMakerAmount,
                orderTakerAmount
            );
        }
        return
            LibSafeMathV06.min256(
                LibSafeMathV06.min256(takerTokenFillAmount, orderTakerAmount),
                state.takerTokenBalanceRemaining
            );
    }

    // Convert possible proportional values to absolute quantities.
    function _normalizeFillAmount(uint256 rawAmount, uint256 balance) private pure returns (uint256 normalized) {
        if ((rawAmount & HIGH_BIT) == HIGH_BIT) {
            // If the high bit of `rawAmount` is set then the lower 255 bits
            // specify a fraction of `balance`.
            return
                LibSafeMathV06.min256(
                    (balance * LibSafeMathV06.min256(rawAmount & LOWER_255_BITS, 1e18)) / 1e18,
                    balance
                );
        }
        return rawAmount;
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;

library LibRichErrorsV06 {
    // bytes4(keccak256("Error(string)"))
    bytes4 internal constant STANDARD_ERROR_SELECTOR = 0x08c379a0;

    // solhint-disable func-name-mixedcase
    
    ///      This is the same payload that would be included by a `revert(string)`
    ///      solidity statement. It has the function signature `Error(string)`.
    
    
    function StandardError(string memory message) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(STANDARD_ERROR_SELECTOR, bytes(message));
    }

    // solhint-enable func-name-mixedcase

    
    
    function rrevert(bytes memory errorData) internal pure {
        assembly {
            revert(add(errorData, 0x20), mload(errorData))
        }
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;

interface IERC20TokenV06 {
    // solhint-disable no-simple-event-func-name
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    
    
    
    
    function transfer(address to, uint256 value) external returns (bool);

    
    
    
    
    
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    
    
    
    
    function approve(address spender, uint256 value) external returns (bool);

    
    
    function totalSupply() external view returns (uint256);

    
    
    
    function balanceOf(address owner) external view returns (uint256);

    
    
    
    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function decimals() external view returns (uint8);
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;





library LibERC20TokenV06 {
    bytes private constant DECIMALS_CALL_DATA = hex"313ce567";

    
    ///      Reverts if the return data is invalid or the call reverts.
    
    
    
    function compatApprove(
        IERC20TokenV06 token,
        address spender,
        uint256 allowance
    ) internal {
        bytes memory callData = abi.encodeWithSelector(token.approve.selector, spender, allowance);
        _callWithOptionalBooleanResult(address(token), callData);
    }

    
    ///      maximum if the current approval is not already >= an amount.
    ///      Reverts if the return data is invalid or the call reverts.
    
    
    
    function approveIfBelow(
        IERC20TokenV06 token,
        address spender,
        uint256 amount
    ) internal {
        if (token.allowance(address(this), spender) < amount) {
            compatApprove(token, spender, uint256(-1));
        }
    }

    
    ///      Reverts if the return data is invalid or the call reverts.
    
    
    
    function compatTransfer(
        IERC20TokenV06 token,
        address to,
        uint256 amount
    ) internal {
        bytes memory callData = abi.encodeWithSelector(token.transfer.selector, to, amount);
        _callWithOptionalBooleanResult(address(token), callData);
    }

    
    ///      Reverts if the return data is invalid or the call reverts.
    
    
    
    
    function compatTransferFrom(
        IERC20TokenV06 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bytes memory callData = abi.encodeWithSelector(token.transferFrom.selector, from, to, amount);
        _callWithOptionalBooleanResult(address(token), callData);
    }

    
    ///      Returns `18` if the call reverts.
    
    
    function compatDecimals(IERC20TokenV06 token) internal view returns (uint8 tokenDecimals) {
        tokenDecimals = 18;
        (bool didSucceed, bytes memory resultData) = address(token).staticcall(DECIMALS_CALL_DATA);
        if (didSucceed && resultData.length >= 32) {
            tokenDecimals = uint8(LibBytesV06.readUint256(resultData, 0));
        }
    }

    
    ///      Returns `0` if the call reverts.
    
    
    
    
    function compatAllowance(
        IERC20TokenV06 token,
        address owner,
        address spender
    ) internal view returns (uint256 allowance_) {
        (bool didSucceed, bytes memory resultData) = address(token).staticcall(
            abi.encodeWithSelector(token.allowance.selector, owner, spender)
        );
        if (didSucceed && resultData.length >= 32) {
            allowance_ = LibBytesV06.readUint256(resultData, 0);
        }
    }

    
    ///      Returns `0` if the call reverts.
    
    
    
    function compatBalanceOf(IERC20TokenV06 token, address owner) internal view returns (uint256 balance) {
        (bool didSucceed, bytes memory resultData) = address(token).staticcall(
            abi.encodeWithSelector(token.balanceOf.selector, owner)
        );
        if (didSucceed && resultData.length >= 32) {
            balance = LibBytesV06.readUint256(resultData, 0);
        }
    }

    
    ///      and asserts that either nothing was returned or a single boolean
    ///      was returned equal to `true`.
    
    
    function _callWithOptionalBooleanResult(address target, bytes memory callData) private {
        (bool didSucceed, bytes memory resultData) = target.call(callData);
        // Revert if the call reverted.
        if (!didSucceed) {
            LibRichErrorsV06.rrevert(resultData);
        }
        // If we get back 0 returndata, this may be a non-standard ERC-20 that
        // does not return a boolean. Check that it at least contains code.
        if (resultData.length == 0) {
            uint256 size;
            assembly {
                size := extcodesize(target)
            }
            require(size > 0, "invalid token address, contains no code");
            return;
        }
        // If we get back at least 32 bytes, we know the target address
        // contains code, and we assume it is a token that returned a boolean
        // success value, which must be true.
        if (resultData.length >= 32) {
            uint256 result = LibBytesV06.readUint256(resultData, 0);
            if (result == 1) {
                return;
            } else {
                LibRichErrorsV06.rrevert(resultData);
            }
        }
        // If 0 < returndatasize < 32, the target is a contract, but not a
        // valid token.
        LibRichErrorsV06.rrevert(resultData);
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;




library LibBytesV06 {
    using LibBytesV06 for bytes;

    
    
    
    ///         points to the header of the byte array which contains
    ///         the length.
    function rawAddress(bytes memory input) internal pure returns (uint256 memoryAddress) {
        assembly {
            memoryAddress := input
        }
        return memoryAddress;
    }

    
    
    
    function contentAddress(bytes memory input) internal pure returns (uint256 memoryAddress) {
        assembly {
            memoryAddress := add(input, 32)
        }
        return memoryAddress;
    }

    
    
    
    
    function memCopy(
        uint256 dest,
        uint256 source,
        uint256 length
    ) internal pure {
        if (length < 32) {
            // Handle a partial word by reading destination and masking
            // off the bits we are interested in.
            // This correctly handles overlap, zero lengths and source == dest
            assembly {
                let mask := sub(exp(256, sub(32, length)), 1)
                let s := and(mload(source), not(mask))
                let d := and(mload(dest), mask)
                mstore(dest, or(s, d))
            }
        } else {
            // Skip the O(length) loop when source == dest.
            if (source == dest) {
                return;
            }

            // For large copies we copy whole words at a time. The final
            // word is aligned to the end of the range (instead of after the
            // previous) to handle partial words. So a copy will look like this:
            //
            //  ####
            //      ####
            //          ####
            //            ####
            //
            // We handle overlap in the source and destination range by
            // changing the copying direction. This prevents us from
            // overwriting parts of source that we still need to copy.
            //
            // This correctly handles source == dest
            //
            if (source > dest) {
                assembly {
                    // We subtract 32 from `sEnd` and `dEnd` because it
                    // is easier to compare with in the loop, and these
                    // are also the addresses we need for copying the
                    // last bytes.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    // Remember the last 32 bytes of source
                    // This needs to be done here and not after the loop
                    // because we may have overwritten the last bytes in
                    // source already due to overlap.
                    let last := mload(sEnd)

                    // Copy whole words front to back
                    // Note: the first check is always true,
                    // this could have been a do-while loop.
                    // solhint-disable-next-line no-empty-blocks
                    for {

                    } lt(source, sEnd) {

                    } {
                        mstore(dest, mload(source))
                        source := add(source, 32)
                        dest := add(dest, 32)
                    }

                    // Write the last 32 bytes
                    mstore(dEnd, last)
                }
            } else {
                assembly {
                    // We subtract 32 from `sEnd` and `dEnd` because those
                    // are the starting points when copying a word at the end.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    // Remember the first 32 bytes of source
                    // This needs to be done here and not after the loop
                    // because we may have overwritten the first bytes in
                    // source already due to overlap.
                    let first := mload(source)

                    // Copy whole words back to front
                    // We use a signed comparisson here to allow dEnd to become
                    // negative (happens when source and dest < 32). Valid
                    // addresses in local memory will never be larger than
                    // 2**255, so they can be safely re-interpreted as signed.
                    // Note: the first check is always true,
                    // this could have been a do-while loop.
                    // solhint-disable-next-line no-empty-blocks
                    for {

                    } slt(dest, dEnd) {

                    } {
                        mstore(dEnd, mload(sEnd))
                        sEnd := sub(sEnd, 32)
                        dEnd := sub(dEnd, 32)
                    }

                    // Write the first 32 bytes
                    mstore(dest, first)
                }
            }
        }
    }

    
    
    
    
    
    function slice(
        bytes memory b,
        uint256 from,
        uint256 to
    ) internal pure returns (bytes memory result) {
        // Ensure that the from and to positions are valid positions for a slice within
        // the byte array that is being used.
        if (from > to) {
            LibRichErrorsV06.rrevert(
                LibBytesRichErrorsV06.InvalidByteOperationError(
                    LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                    from,
                    to
                )
            );
        }
        if (to > b.length) {
            LibRichErrorsV06.rrevert(
                LibBytesRichErrorsV06.InvalidByteOperationError(
                    LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                    to,
                    b.length
                )
            );
        }

        // Create a new bytes structure and copy contents
        result = new bytes(to - from);
        memCopy(result.contentAddress(), b.contentAddress() + from, result.length);
        return result;
    }

    
    ///      When `from == 0`, the original array will match the slice.
    ///      In other cases its state will be corrupted.
    
    
    
    
    function sliceDestructive(
        bytes memory b,
        uint256 from,
        uint256 to
    ) internal pure returns (bytes memory result) {
        // Ensure that the from and to positions are valid positions for a slice within
        // the byte array that is being used.
        if (from > to) {
            LibRichErrorsV06.rrevert(
                LibBytesRichErrorsV06.InvalidByteOperationError(
                    LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                    from,
                    to
                )
            );
        }
        if (to > b.length) {
            LibRichErrorsV06.rrevert(
                LibBytesRichErrorsV06.InvalidByteOperationError(
                    LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                    to,
                    b.length
                )
            );
        }

        // Create a new bytes structure around [from, to) in-place.
        assembly {
            result := add(b, from)
            mstore(result, sub(to, from))
        }
        return result;
    }

    
    
    
    function popLastByte(bytes memory b) internal pure returns (bytes1 result) {
        if (b.length == 0) {
            LibRichErrorsV06.rrevert(
                LibBytesRichErrorsV06.InvalidByteOperationError(
                    LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanZeroRequired,
                    b.length,
                    0
                )
            );
        }

        // Store last byte.
        result = b[b.length - 1];

        assembly {
            // Decrement length of byte array.
            let newLen := sub(mload(b), 1)
            mstore(b, newLen)
        }
        return result;
    }

    
    
    
    
    function equals(bytes memory lhs, bytes memory rhs) internal pure returns (bool equal) {
        // Keccak gas cost is 30 + numWords * 6. This is a cheap way to compare.
        // We early exit on unequal lengths, but keccak would also correctly
        // handle this.
        return lhs.length == rhs.length && keccak256(lhs) == keccak256(rhs);
    }

    
    
    
    
    function readAddress(bytes memory b, uint256 index) internal pure returns (address result) {
        if (b.length < index + 20) {
            LibRichErrorsV06.rrevert(
                LibBytesRichErrorsV06.InvalidByteOperationError(
                    LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                    b.length,
                    index + 20 // 20 is length of address
                )
            );
        }

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Read address from array memory
        assembly {
            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 20-byte mask to obtain address
            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    
    
    
    
    function writeAddress(
        bytes memory b,
        uint256 index,
        address input
    ) internal pure {
        if (b.length < index + 20) {
            LibRichErrorsV06.rrevert(
                LibBytesRichErrorsV06.InvalidByteOperationError(
                    LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                    b.length,
                    index + 20 // 20 is length of address
                )
            );
        }

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Store address into array memory
        assembly {
            // The address occupies 20 bytes and mstore stores 32 bytes.
            // First fetch the 32-byte word where we'll be storing the address, then
            // apply a mask so we have only the bytes in the word that the address will not occupy.
            // Then combine these bytes with the address and store the 32 bytes back to memory with mstore.

            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 12-byte mask to obtain extra bytes occupying word of memory where we'll store the address
            let neighbors := and(
                mload(add(b, index)),
                0xffffffffffffffffffffffff0000000000000000000000000000000000000000
            )

            // Make sure input address is clean.
            // (Solidity does not guarantee this)
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffff)

            // Store the neighbors and address into memory
            mstore(add(b, index), xor(input, neighbors))
        }
    }

    
    
    
    
    function readBytes32(bytes memory b, uint256 index) internal pure returns (bytes32 result) {
        if (b.length < index + 32) {
            LibRichErrorsV06.rrevert(
                LibBytesRichErrorsV06.InvalidByteOperationError(
                    LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                    b.length,
                    index + 32
                )
            );
        }

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

    
    
    
    
    function writeBytes32(
        bytes memory b,
        uint256 index,
        bytes32 input
    ) internal pure {
        if (b.length < index + 32) {
            LibRichErrorsV06.rrevert(
                LibBytesRichErrorsV06.InvalidByteOperationError(
                    LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                    b.length,
                    index + 32
                )
            );
        }

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            mstore(add(b, index), input)
        }
    }

    
    
    
    
    function readUint256(bytes memory b, uint256 index) internal pure returns (uint256 result) {
        result = uint256(readBytes32(b, index));
        return result;
    }

    
    
    
    
    function writeUint256(
        bytes memory b,
        uint256 index,
        uint256 input
    ) internal pure {
        writeBytes32(b, index, bytes32(input));
    }

    
    
    
    
    function readBytes4(bytes memory b, uint256 index) internal pure returns (bytes4 result) {
        if (b.length < index + 4) {
            LibRichErrorsV06.rrevert(
                LibBytesRichErrorsV06.InvalidByteOperationError(
                    LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsFourRequired,
                    b.length,
                    index + 4
                )
            );
        }

        // Arrays are prefixed by a 32 byte length field
        index += 32;

        // Read the bytes4 from array memory
        assembly {
            result := mload(add(b, index))
            // Solidity does not require us to clean the trailing bytes.
            // We do it anyway
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }

    
    ///      Decreasing length will lead to removing the corresponding lower order bytes from the byte array.
    ///      Increasing length may lead to appending adjacent in-memory bytes to the end of the byte array.
    
    
    function writeLength(bytes memory b, uint256 length) internal pure {
        assembly {
            mstore(b, length)
        }
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;

library LibBytesRichErrorsV06 {
    enum InvalidByteOperationErrorCodes {
        FromLessThanOrEqualsToRequired,
        ToLessThanOrEqualsLengthRequired,
        LengthGreaterThanZeroRequired,
        LengthGreaterThanOrEqualsFourRequired,
        LengthGreaterThanOrEqualsTwentyRequired,
        LengthGreaterThanOrEqualsThirtyTwoRequired,
        LengthGreaterThanOrEqualsNestedBytesLengthRequired,
        DestinationLengthGreaterThanOrEqualSourceLengthRequired
    }

    // bytes4(keccak256("InvalidByteOperationError(uint8,uint256,uint256)"))
    bytes4 internal constant INVALID_BYTE_OPERATION_ERROR_SELECTOR = 0x28006595;

    // solhint-disable func-name-mixedcase
    function InvalidByteOperationError(
        InvalidByteOperationErrorCodes errorCode,
        uint256 offset,
        uint256 required
    ) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(INVALID_BYTE_OPERATION_ERROR_SELECTOR, errorCode, offset, required);
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;




library LibSafeMathV06 {
    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        if (c / a != b) {
            LibRichErrorsV06.rrevert(
                LibSafeMathRichErrorsV06.Uint256BinOpError(
                    LibSafeMathRichErrorsV06.BinOpErrorCodes.MULTIPLICATION_OVERFLOW,
                    a,
                    b
                )
            );
        }
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            LibRichErrorsV06.rrevert(
                LibSafeMathRichErrorsV06.Uint256BinOpError(
                    LibSafeMathRichErrorsV06.BinOpErrorCodes.DIVISION_BY_ZERO,
                    a,
                    b
                )
            );
        }
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > a) {
            LibRichErrorsV06.rrevert(
                LibSafeMathRichErrorsV06.Uint256BinOpError(
                    LibSafeMathRichErrorsV06.BinOpErrorCodes.SUBTRACTION_UNDERFLOW,
                    a,
                    b
                )
            );
        }
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        if (c < a) {
            LibRichErrorsV06.rrevert(
                LibSafeMathRichErrorsV06.Uint256BinOpError(
                    LibSafeMathRichErrorsV06.BinOpErrorCodes.ADDITION_OVERFLOW,
                    a,
                    b
                )
            );
        }
        return c;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function safeMul128(uint128 a, uint128 b) internal pure returns (uint128) {
        if (a == 0) {
            return 0;
        }
        uint128 c = a * b;
        if (c / a != b) {
            LibRichErrorsV06.rrevert(
                LibSafeMathRichErrorsV06.Uint256BinOpError(
                    LibSafeMathRichErrorsV06.BinOpErrorCodes.MULTIPLICATION_OVERFLOW,
                    a,
                    b
                )
            );
        }
        return c;
    }

    function safeDiv128(uint128 a, uint128 b) internal pure returns (uint128) {
        if (b == 0) {
            LibRichErrorsV06.rrevert(
                LibSafeMathRichErrorsV06.Uint256BinOpError(
                    LibSafeMathRichErrorsV06.BinOpErrorCodes.DIVISION_BY_ZERO,
                    a,
                    b
                )
            );
        }
        uint128 c = a / b;
        return c;
    }

    function safeSub128(uint128 a, uint128 b) internal pure returns (uint128) {
        if (b > a) {
            LibRichErrorsV06.rrevert(
                LibSafeMathRichErrorsV06.Uint256BinOpError(
                    LibSafeMathRichErrorsV06.BinOpErrorCodes.SUBTRACTION_UNDERFLOW,
                    a,
                    b
                )
            );
        }
        return a - b;
    }

    function safeAdd128(uint128 a, uint128 b) internal pure returns (uint128) {
        uint128 c = a + b;
        if (c < a) {
            LibRichErrorsV06.rrevert(
                LibSafeMathRichErrorsV06.Uint256BinOpError(
                    LibSafeMathRichErrorsV06.BinOpErrorCodes.ADDITION_OVERFLOW,
                    a,
                    b
                )
            );
        }
        return c;
    }

    function max128(uint128 a, uint128 b) internal pure returns (uint128) {
        return a >= b ? a : b;
    }

    function min128(uint128 a, uint128 b) internal pure returns (uint128) {
        return a < b ? a : b;
    }

    function safeDowncastToUint128(uint256 a) internal pure returns (uint128) {
        if (a > type(uint128).max) {
            LibRichErrorsV06.rrevert(
                LibSafeMathRichErrorsV06.Uint256DowncastError(
                    LibSafeMathRichErrorsV06.DowncastErrorCodes.VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT128,
                    a
                )
            );
        }
        return uint128(a);
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;

library LibSafeMathRichErrorsV06 {
    // bytes4(keccak256("Uint256BinOpError(uint8,uint256,uint256)"))
    bytes4 internal constant UINT256_BINOP_ERROR_SELECTOR = 0xe946c1bb;

    // bytes4(keccak256("Uint256DowncastError(uint8,uint256)"))
    bytes4 internal constant UINT256_DOWNCAST_ERROR_SELECTOR = 0xc996af7b;

    enum BinOpErrorCodes {
        ADDITION_OVERFLOW,
        MULTIPLICATION_OVERFLOW,
        SUBTRACTION_UNDERFLOW,
        DIVISION_BY_ZERO
    }

    enum DowncastErrorCodes {
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT32,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT64,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT96,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT128
    }

    // solhint-disable func-name-mixedcase
    function Uint256BinOpError(
        BinOpErrorCodes errorCode,
        uint256 a,
        uint256 b
    ) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(UINT256_BINOP_ERROR_SELECTOR, errorCode, a, b);
    }

    function Uint256DowncastError(DowncastErrorCodes errorCode, uint256 a) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(UINT256_DOWNCAST_ERROR_SELECTOR, errorCode, a);
    }
}

// 
/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;





library LibMathV06 {
    using LibSafeMathV06 for uint256;

    
    ///      Reverts if rounding error is >= 0.1%
    
    
    
    
    function safeGetPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (uint256 partialAmount) {
        if (isRoundingErrorFloor(numerator, denominator, target)) {
            LibRichErrorsV06.rrevert(LibMathRichErrorsV06.RoundingError(numerator, denominator, target));
        }

        partialAmount = numerator.safeMul(target).safeDiv(denominator);
        return partialAmount;
    }

    
    ///      Reverts if rounding error is >= 0.1%
    
    
    
    
    function safeGetPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (uint256 partialAmount) {
        if (isRoundingErrorCeil(numerator, denominator, target)) {
            LibRichErrorsV06.rrevert(LibMathRichErrorsV06.RoundingError(numerator, denominator, target));
        }

        // safeDiv computes `floor(a / b)`. We use the identity (a, b integer):
        //       ceil(a / b) = floor((a + b - 1) / b)
        // To implement `ceil(a / b)` using safeDiv.
        partialAmount = numerator.safeMul(target).safeAdd(denominator.safeSub(1)).safeDiv(denominator);

        return partialAmount;
    }

    
    
    
    
    
    function getPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (uint256 partialAmount) {
        partialAmount = numerator.safeMul(target).safeDiv(denominator);
        return partialAmount;
    }

    
    
    
    
    
    function getPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (uint256 partialAmount) {
        // safeDiv computes `floor(a / b)`. We use the identity (a, b integer):
        //       ceil(a / b) = floor((a + b - 1) / b)
        // To implement `ceil(a / b)` using safeDiv.
        partialAmount = numerator.safeMul(target).safeAdd(denominator.safeSub(1)).safeDiv(denominator);

        return partialAmount;
    }

    
    
    
    
    
    function isRoundingErrorFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (bool isError) {
        if (denominator == 0) {
            LibRichErrorsV06.rrevert(LibMathRichErrorsV06.DivisionByZeroError());
        }

        // The absolute rounding error is the difference between the rounded
        // value and the ideal value. The relative rounding error is the
        // absolute rounding error divided by the absolute value of the
        // ideal value. This is undefined when the ideal value is zero.
        //
        // The ideal value is `numerator * target / denominator`.
        // Let's call `numerator * target % denominator` the remainder.
        // The absolute error is `remainder / denominator`.
        //
        // When the ideal value is zero, we require the absolute error to
        // be zero. Fortunately, this is always the case. The ideal value is
        // zero iff `numerator == 0` and/or `target == 0`. In this case the
        // remainder and absolute error are also zero.
        if (target == 0 || numerator == 0) {
            return false;
        }

        // Otherwise, we want the relative rounding error to be strictly
        // less than 0.1%.
        // The relative error is `remainder / (numerator * target)`.
        // We want the relative error less than 1 / 1000:
        //        remainder / (numerator * denominator)  <  1 / 1000
        // or equivalently:
        //        1000 * remainder  <  numerator * target
        // so we have a rounding error iff:
        //        1000 * remainder  >=  numerator * target
        uint256 remainder = mulmod(target, numerator, denominator);
        isError = remainder.safeMul(1000) >= numerator.safeMul(target);
        return isError;
    }

    
    
    
    
    
    function isRoundingErrorCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (bool isError) {
        if (denominator == 0) {
            LibRichErrorsV06.rrevert(LibMathRichErrorsV06.DivisionByZeroError());
        }

        // See the comments in `isRoundingError`.
        if (target == 0 || numerator == 0) {
            // When either is zero, the ideal value and rounded value are zero
            // and there is no rounding error. (Although the relative error
            // is undefined.)
            return false;
        }
        // Compute remainder as before
        uint256 remainder = mulmod(target, numerator, denominator);
        remainder = denominator.safeSub(remainder) % denominator;
        isError = remainder.safeMul(1000) >= numerator.safeMul(target);
        return isError;
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;

library LibMathRichErrorsV06 {
    // bytes4(keccak256("DivisionByZeroError()"))
    bytes internal constant DIVISION_BY_ZERO_ERROR = hex"a791837c";

    // bytes4(keccak256("RoundingError(uint256,uint256,uint256)"))
    bytes4 internal constant ROUNDING_ERROR_SELECTOR = 0x339f3de2;

    // solhint-disable func-name-mixedcase
    function DivisionByZeroError() internal pure returns (bytes memory) {
        return DIVISION_BY_ZERO_ERROR;
    }

    function RoundingError(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(ROUNDING_ERROR_SELECTOR, numerator, denominator, target);
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;

library LibTransformERC20RichErrors {
    // solhint-disable func-name-mixedcase,separate-by-one-line-in-contract

    function InsufficientEthAttachedError(uint256 ethAttached, uint256 ethNeeded) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                bytes4(keccak256("InsufficientEthAttachedError(uint256,uint256)")),
                ethAttached,
                ethNeeded
            );
    }

    function IncompleteTransformERC20Error(
        address outputToken,
        uint256 outputTokenAmount,
        uint256 minOutputTokenAmount
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                bytes4(keccak256("IncompleteTransformERC20Error(address,uint256,uint256)")),
                outputToken,
                outputTokenAmount,
                minOutputTokenAmount
            );
    }

    function NegativeTransformERC20OutputError(address outputToken, uint256 outputTokenLostAmount)
        internal
        pure
        returns (bytes memory)
    {
        return
            abi.encodeWithSelector(
                bytes4(keccak256("NegativeTransformERC20OutputError(address,uint256)")),
                outputToken,
                outputTokenLostAmount
            );
    }

    function TransformerFailedError(
        address transformer,
        bytes memory transformerData,
        bytes memory resultData
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                bytes4(keccak256("TransformerFailedError(address,bytes,bytes)")),
                transformer,
                transformerData,
                resultData
            );
    }

    // Common Transformer errors ///////////////////////////////////////////////

    function OnlyCallableByDeployerError(address caller, address deployer) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(bytes4(keccak256("OnlyCallableByDeployerError(address,address)")), caller, deployer);
    }

    function InvalidExecutionContextError(address actualContext, address expectedContext)
        internal
        pure
        returns (bytes memory)
    {
        return
            abi.encodeWithSelector(
                bytes4(keccak256("InvalidExecutionContextError(address,address)")),
                actualContext,
                expectedContext
            );
    }

    enum InvalidTransformDataErrorCode {
        INVALID_TOKENS,
        INVALID_ARRAY_LENGTH
    }

    function InvalidTransformDataError(InvalidTransformDataErrorCode errorCode, bytes memory transformData)
        internal
        pure
        returns (bytes memory)
    {
        return
            abi.encodeWithSelector(
                bytes4(keccak256("InvalidTransformDataError(uint8,bytes)")),
                errorCode,
                transformData
            );
    }

    // FillQuoteTransformer errors /////////////////////////////////////////////

    function IncompleteFillSellQuoteError(
        address sellToken,
        uint256 soldAmount,
        uint256 sellAmount
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                bytes4(keccak256("IncompleteFillSellQuoteError(address,uint256,uint256)")),
                sellToken,
                soldAmount,
                sellAmount
            );
    }

    function IncompleteFillBuyQuoteError(
        address buyToken,
        uint256 boughtAmount,
        uint256 buyAmount
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                bytes4(keccak256("IncompleteFillBuyQuoteError(address,uint256,uint256)")),
                buyToken,
                boughtAmount,
                buyAmount
            );
    }

    function InsufficientTakerTokenError(uint256 tokenBalance, uint256 tokensNeeded)
        internal
        pure
        returns (bytes memory)
    {
        return
            abi.encodeWithSelector(
                bytes4(keccak256("InsufficientTakerTokenError(uint256,uint256)")),
                tokenBalance,
                tokensNeeded
            );
    }

    function InsufficientProtocolFeeError(uint256 ethBalance, uint256 ethNeeded) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                bytes4(keccak256("InsufficientProtocolFeeError(uint256,uint256)")),
                ethBalance,
                ethNeeded
            );
    }

    function InvalidERC20AssetDataError(bytes memory assetData) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(bytes4(keccak256("InvalidERC20AssetDataError(bytes)")), assetData);
    }

    function InvalidTakerFeeTokenError(address token) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(bytes4(keccak256("InvalidTakerFeeTokenError(address)")), token);
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;






library LibSignature {
    using LibRichErrorsV06 for bytes;

    // '\x19Ethereum Signed Message:\n32\x00\x00\x00\x00' in a word.
    uint256 private constant ETH_SIGN_HASH_PREFIX = 0x19457468657265756d205369676e6564204d6573736167653a0a333200000000;
    
    ///      The valid range is given by fig (282) of the yellow paper.
    uint256 private constant ECDSA_SIGNATURE_R_LIMIT =
        uint256(0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141);
    
    ///      The valid range is given by fig (283) of the yellow paper.
    uint256 private constant ECDSA_SIGNATURE_S_LIMIT = ECDSA_SIGNATURE_R_LIMIT / 2 + 1;

    
    enum SignatureType {
        ILLEGAL,
        INVALID,
        EIP712,
        ETHSIGN,
        PRESIGNED
    }

    
    struct Signature {
        // How to validate the signature.
        SignatureType signatureType;
        // EC Signature data.
        uint8 v;
        // EC Signature data.
        bytes32 r;
        // EC Signature data.
        bytes32 s;
    }

    
    ///      Throws if the signature can't be validated.
    
    
    
    function getSignerOfHash(bytes32 hash, Signature memory signature) internal pure returns (address recovered) {
        // Ensure this is a signature type that can be validated against a hash.
        _validateHashCompatibleSignature(hash, signature);

        if (signature.signatureType == SignatureType.EIP712) {
            // Signed using EIP712
            recovered = ecrecover(hash, signature.v, signature.r, signature.s);
        } else if (signature.signatureType == SignatureType.ETHSIGN) {
            // Signed using `eth_sign`
            // Need to hash `hash` with "\x19Ethereum Signed Message:\n32" prefix
            // in packed encoding.
            bytes32 ethSignHash;
            assembly {
                // Use scratch space
                mstore(0, ETH_SIGN_HASH_PREFIX) // length of 28 bytes
                mstore(28, hash) // length of 32 bytes
                ethSignHash := keccak256(0, 60)
            }
            recovered = ecrecover(ethSignHash, signature.v, signature.r, signature.s);
        }
        // `recovered` can be null if the signature values are out of range.
        if (recovered == address(0)) {
            LibSignatureRichErrors
                .SignatureValidationError(LibSignatureRichErrors.SignatureValidationErrorCodes.BAD_SIGNATURE_DATA, hash)
                .rrevert();
        }
    }

    
    
    
    function _validateHashCompatibleSignature(bytes32 hash, Signature memory signature) private pure {
        // Ensure the r and s are within malleability limits.
        if (uint256(signature.r) >= ECDSA_SIGNATURE_R_LIMIT || uint256(signature.s) >= ECDSA_SIGNATURE_S_LIMIT) {
            LibSignatureRichErrors
                .SignatureValidationError(LibSignatureRichErrors.SignatureValidationErrorCodes.BAD_SIGNATURE_DATA, hash)
                .rrevert();
        }

        // Always illegal signature.
        if (signature.signatureType == SignatureType.ILLEGAL) {
            LibSignatureRichErrors
                .SignatureValidationError(LibSignatureRichErrors.SignatureValidationErrorCodes.ILLEGAL, hash)
                .rrevert();
        }

        // Always invalid.
        if (signature.signatureType == SignatureType.INVALID) {
            LibSignatureRichErrors
                .SignatureValidationError(LibSignatureRichErrors.SignatureValidationErrorCodes.ALWAYS_INVALID, hash)
                .rrevert();
        }

        // If a feature supports pre-signing, it wouldn't use
        // `getSignerOfHash` on a pre-signed order.
        if (signature.signatureType == SignatureType.PRESIGNED) {
            LibSignatureRichErrors
                .SignatureValidationError(LibSignatureRichErrors.SignatureValidationErrorCodes.UNSUPPORTED, hash)
                .rrevert();
        }

        // Solidity should check that the signature type is within enum range for us
        // when abi-decoding.
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;

library LibSignatureRichErrors {
    enum SignatureValidationErrorCodes {
        ALWAYS_INVALID,
        INVALID_LENGTH,
        UNSUPPORTED,
        ILLEGAL,
        WRONG_SIGNER,
        BAD_SIGNATURE_DATA
    }

    // solhint-disable func-name-mixedcase

    function SignatureValidationError(
        SignatureValidationErrorCodes code,
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                bytes4(keccak256("SignatureValidationError(uint8,bytes32,address,bytes)")),
                code,
                hash,
                signerAddress,
                signature
            );
    }

    function SignatureValidationError(SignatureValidationErrorCodes code, bytes32 hash)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(bytes4(keccak256("SignatureValidationError(uint8,bytes32)")), code, hash);
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;








library LibNativeOrder {
    using LibSafeMathV06 for uint256;
    using LibRichErrorsV06 for bytes;

    enum OrderStatus {
        INVALID,
        FILLABLE,
        FILLED,
        CANCELLED,
        EXPIRED
    }

    
    struct LimitOrder {
        IERC20TokenV06 makerToken;
        IERC20TokenV06 takerToken;
        uint128 makerAmount;
        uint128 takerAmount;
        uint128 takerTokenFeeAmount;
        address maker;
        address taker;
        address sender;
        address feeRecipient;
        bytes32 pool;
        uint64 expiry;
        uint256 salt;
    }

    
    struct RfqOrder {
        IERC20TokenV06 makerToken;
        IERC20TokenV06 takerToken;
        uint128 makerAmount;
        uint128 takerAmount;
        address maker;
        address taker;
        address txOrigin;
        bytes32 pool;
        uint64 expiry;
        uint256 salt;
    }

    
    struct OtcOrder {
        IERC20TokenV06 makerToken;
        IERC20TokenV06 takerToken;
        uint128 makerAmount;
        uint128 takerAmount;
        address maker;
        address taker;
        address txOrigin;
        uint256 expiryAndNonce; // [uint64 expiry, uint64 nonceBucket, uint128 nonce]
    }

    
    struct OrderInfo {
        bytes32 orderHash;
        OrderStatus status;
        uint128 takerTokenFilledAmount;
    }

    
    struct OtcOrderInfo {
        bytes32 orderHash;
        OrderStatus status;
    }

    uint256 private constant UINT_128_MASK = (1 << 128) - 1;
    uint256 private constant UINT_64_MASK = (1 << 64) - 1;
    uint256 private constant ADDRESS_MASK = (1 << 160) - 1;

    // The type hash for limit orders, which is:
    // keccak256(abi.encodePacked(
    //     "LimitOrder(",
    //       "address makerToken,",
    //       "address takerToken,",
    //       "uint128 makerAmount,",
    //       "uint128 takerAmount,",
    //       "uint128 takerTokenFeeAmount,",
    //       "address maker,",
    //       "address taker,",
    //       "address sender,",
    //       "address feeRecipient,",
    //       "bytes32 pool,",
    //       "uint64 expiry,",
    //       "uint256 salt"
    //     ")"
    // ))
    uint256 private constant _LIMIT_ORDER_TYPEHASH = 0xce918627cb55462ddbb85e73de69a8b322f2bc88f4507c52fcad6d4c33c29d49;

    // The type hash for RFQ orders, which is:
    // keccak256(abi.encodePacked(
    //     "RfqOrder(",
    //       "address makerToken,",
    //       "address takerToken,",
    //       "uint128 makerAmount,",
    //       "uint128 takerAmount,",
    //       "address maker,",
    //       "address taker,",
    //       "address txOrigin,",
    //       "bytes32 pool,",
    //       "uint64 expiry,",
    //       "uint256 salt"
    //     ")"
    // ))
    uint256 private constant _RFQ_ORDER_TYPEHASH = 0xe593d3fdfa8b60e5e17a1b2204662ecbe15c23f2084b9ad5bae40359540a7da9;

    // The type hash for OTC orders, which is:
    // keccak256(abi.encodePacked(
    //     "OtcOrder(",
    //       "address makerToken,",
    //       "address takerToken,",
    //       "uint128 makerAmount,",
    //       "uint128 takerAmount,",
    //       "address maker,",
    //       "address taker,",
    //       "address txOrigin,",
    //       "uint256 expiryAndNonce"
    //     ")"
    // ))
    uint256 private constant _OTC_ORDER_TYPEHASH = 0x2f754524de756ae72459efbe1ec88c19a745639821de528ac3fb88f9e65e35c8;

    
    
    
    function getLimitOrderStructHash(LimitOrder memory order) internal pure returns (bytes32 structHash) {
        // The struct hash is:
        // keccak256(abi.encode(
        //   TYPE_HASH,
        //   order.makerToken,
        //   order.takerToken,
        //   order.makerAmount,
        //   order.takerAmount,
        //   order.takerTokenFeeAmount,
        //   order.maker,
        //   order.taker,
        //   order.sender,
        //   order.feeRecipient,
        //   order.pool,
        //   order.expiry,
        //   order.salt,
        // ))
        assembly {
            let mem := mload(0x40)
            mstore(mem, _LIMIT_ORDER_TYPEHASH)
            // order.makerToken;
            mstore(add(mem, 0x20), and(ADDRESS_MASK, mload(order)))
            // order.takerToken;
            mstore(add(mem, 0x40), and(ADDRESS_MASK, mload(add(order, 0x20))))
            // order.makerAmount;
            mstore(add(mem, 0x60), and(UINT_128_MASK, mload(add(order, 0x40))))
            // order.takerAmount;
            mstore(add(mem, 0x80), and(UINT_128_MASK, mload(add(order, 0x60))))
            // order.takerTokenFeeAmount;
            mstore(add(mem, 0xA0), and(UINT_128_MASK, mload(add(order, 0x80))))
            // order.maker;
            mstore(add(mem, 0xC0), and(ADDRESS_MASK, mload(add(order, 0xA0))))
            // order.taker;
            mstore(add(mem, 0xE0), and(ADDRESS_MASK, mload(add(order, 0xC0))))
            // order.sender;
            mstore(add(mem, 0x100), and(ADDRESS_MASK, mload(add(order, 0xE0))))
            // order.feeRecipient;
            mstore(add(mem, 0x120), and(ADDRESS_MASK, mload(add(order, 0x100))))
            // order.pool;
            mstore(add(mem, 0x140), mload(add(order, 0x120)))
            // order.expiry;
            mstore(add(mem, 0x160), and(UINT_64_MASK, mload(add(order, 0x140))))
            // order.salt;
            mstore(add(mem, 0x180), mload(add(order, 0x160)))
            structHash := keccak256(mem, 0x1A0)
        }
    }

    
    
    
    function getRfqOrderStructHash(RfqOrder memory order) internal pure returns (bytes32 structHash) {
        // The struct hash is:
        // keccak256(abi.encode(
        //   TYPE_HASH,
        //   order.makerToken,
        //   order.takerToken,
        //   order.makerAmount,
        //   order.takerAmount,
        //   order.maker,
        //   order.taker,
        //   order.txOrigin,
        //   order.pool,
        //   order.expiry,
        //   order.salt,
        // ))
        assembly {
            let mem := mload(0x40)
            mstore(mem, _RFQ_ORDER_TYPEHASH)
            // order.makerToken;
            mstore(add(mem, 0x20), and(ADDRESS_MASK, mload(order)))
            // order.takerToken;
            mstore(add(mem, 0x40), and(ADDRESS_MASK, mload(add(order, 0x20))))
            // order.makerAmount;
            mstore(add(mem, 0x60), and(UINT_128_MASK, mload(add(order, 0x40))))
            // order.takerAmount;
            mstore(add(mem, 0x80), and(UINT_128_MASK, mload(add(order, 0x60))))
            // order.maker;
            mstore(add(mem, 0xA0), and(ADDRESS_MASK, mload(add(order, 0x80))))
            // order.taker;
            mstore(add(mem, 0xC0), and(ADDRESS_MASK, mload(add(order, 0xA0))))
            // order.txOrigin;
            mstore(add(mem, 0xE0), and(ADDRESS_MASK, mload(add(order, 0xC0))))
            // order.pool;
            mstore(add(mem, 0x100), mload(add(order, 0xE0)))
            // order.expiry;
            mstore(add(mem, 0x120), and(UINT_64_MASK, mload(add(order, 0x100))))
            // order.salt;
            mstore(add(mem, 0x140), mload(add(order, 0x120)))
            structHash := keccak256(mem, 0x160)
        }
    }

    
    
    
    function getOtcOrderStructHash(OtcOrder memory order) internal pure returns (bytes32 structHash) {
        // The struct hash is:
        // keccak256(abi.encode(
        //   TYPE_HASH,
        //   order.makerToken,
        //   order.takerToken,
        //   order.makerAmount,
        //   order.takerAmount,
        //   order.maker,
        //   order.taker,
        //   order.txOrigin,
        //   order.expiryAndNonce,
        // ))
        assembly {
            let mem := mload(0x40)
            mstore(mem, _OTC_ORDER_TYPEHASH)
            // order.makerToken;
            mstore(add(mem, 0x20), and(ADDRESS_MASK, mload(order)))
            // order.takerToken;
            mstore(add(mem, 0x40), and(ADDRESS_MASK, mload(add(order, 0x20))))
            // order.makerAmount;
            mstore(add(mem, 0x60), and(UINT_128_MASK, mload(add(order, 0x40))))
            // order.takerAmount;
            mstore(add(mem, 0x80), and(UINT_128_MASK, mload(add(order, 0x60))))
            // order.maker;
            mstore(add(mem, 0xA0), and(ADDRESS_MASK, mload(add(order, 0x80))))
            // order.taker;
            mstore(add(mem, 0xC0), and(ADDRESS_MASK, mload(add(order, 0xA0))))
            // order.txOrigin;
            mstore(add(mem, 0xE0), and(ADDRESS_MASK, mload(add(order, 0xC0))))
            // order.expiryAndNonce;
            mstore(add(mem, 0x100), mload(add(order, 0xE0)))
            structHash := keccak256(mem, 0x120)
        }
    }

    
    
    function refundExcessProtocolFeeToSender(uint256 ethProtocolFeePaid) internal {
        if (msg.value > ethProtocolFeePaid && msg.sender != address(this)) {
            uint256 refundAmount = msg.value.safeSub(ethProtocolFeePaid);
            (bool success, ) = msg.sender.call{value: refundAmount}("");
            if (!success) {
                LibNativeOrdersRichErrors.ProtocolFeeRefundFailed(msg.sender, refundAmount).rrevert();
            }
        }
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;

library LibNativeOrdersRichErrors {
    // solhint-disable func-name-mixedcase

    function ProtocolFeeRefundFailed(address receiver, uint256 refundAmount) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                bytes4(keccak256("ProtocolFeeRefundFailed(address,uint256)")),
                receiver,
                refundAmount
            );
    }

    function OrderNotFillableByOriginError(
        bytes32 orderHash,
        address txOrigin,
        address orderTxOrigin
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                bytes4(keccak256("OrderNotFillableByOriginError(bytes32,address,address)")),
                orderHash,
                txOrigin,
                orderTxOrigin
            );
    }

    function OrderNotFillableError(bytes32 orderHash, uint8 orderStatus) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(bytes4(keccak256("OrderNotFillableError(bytes32,uint8)")), orderHash, orderStatus);
    }

    function OrderNotSignedByMakerError(
        bytes32 orderHash,
        address signer,
        address maker
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                bytes4(keccak256("OrderNotSignedByMakerError(bytes32,address,address)")),
                orderHash,
                signer,
                maker
            );
    }

    function InvalidSignerError(address maker, address signer) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(bytes4(keccak256("InvalidSignerError(address,address)")), maker, signer);
    }

    function OrderNotFillableBySenderError(
        bytes32 orderHash,
        address sender,
        address orderSender
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                bytes4(keccak256("OrderNotFillableBySenderError(bytes32,address,address)")),
                orderHash,
                sender,
                orderSender
            );
    }

    function OrderNotFillableByTakerError(
        bytes32 orderHash,
        address taker,
        address orderTaker
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                bytes4(keccak256("OrderNotFillableByTakerError(bytes32,address,address)")),
                orderHash,
                taker,
                orderTaker
            );
    }

    function CancelSaltTooLowError(uint256 minValidSalt, uint256 oldMinValidSalt) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                bytes4(keccak256("CancelSaltTooLowError(uint256,uint256)")),
                minValidSalt,
                oldMinValidSalt
            );
    }

    function FillOrKillFailedError(
        bytes32 orderHash,
        uint256 takerTokenFilledAmount,
        uint256 takerTokenFillAmount
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                bytes4(keccak256("FillOrKillFailedError(bytes32,uint256,uint256)")),
                orderHash,
                takerTokenFilledAmount,
                takerTokenFillAmount
            );
    }

    function OnlyOrderMakerAllowed(
        bytes32 orderHash,
        address sender,
        address maker
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                bytes4(keccak256("OnlyOrderMakerAllowed(bytes32,address,address)")),
                orderHash,
                sender,
                maker
            );
    }

    function BatchFillIncompleteError(
        bytes32 orderHash,
        uint256 takerTokenFilledAmount,
        uint256 takerTokenFillAmount
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                bytes4(keccak256("BatchFillIncompleteError(bytes32,uint256,uint256)")),
                orderHash,
                takerTokenFilledAmount,
                takerTokenFillAmount
            );
    }
}

// 
/*

  Copyright 2021 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;




interface IBridgeAdapter {
    struct BridgeOrder {
        // Upper 16 bytes: uint128 protocol ID (right-aligned)
        // Lower 16 bytes: ASCII source name (left-aligned)
        bytes32 source;
        uint256 takerTokenAmount;
        uint256 makerTokenAmount;
        bytes bridgeData;
    }

    
    
    ///        encodes the (right-aligned) uint128 protocol ID and the
    ///        lower 16 bytes encodes an ASCII source name.
    
    
    
    
    event BridgeFill(
        bytes32 source,
        IERC20TokenV06 inputToken,
        IERC20TokenV06 outputToken,
        uint256 inputTokenAmount,
        uint256 outputTokenAmount
    );

    function isSupportedSource(bytes32 source) external returns (bool isSupported);

    function trade(
        BridgeOrder calldata order,
        IERC20TokenV06 sellToken,
        IERC20TokenV06 buyToken,
        uint256 sellAmount
    ) external returns (uint256 boughtAmount);
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;





library LibERC20Transformer {
    using LibERC20TokenV06 for IERC20TokenV06;

    
    address internal constant ETH_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    
    IERC20TokenV06 internal constant ETH_TOKEN = IERC20TokenV06(ETH_TOKEN_ADDRESS);
    
    ///      This is just `keccak256('TRANSFORMER_SUCCESS')`.
    bytes4 internal constant TRANSFORMER_SUCCESS = 0x13c9929e;

    
    
    
    
    function transformerTransfer(
        IERC20TokenV06 token,
        address payable to,
        uint256 amount
    ) internal {
        if (isTokenETH(token)) {
            to.transfer(amount);
        } else {
            token.compatTransfer(to, amount);
        }
    }

    
    
    
    function isTokenETH(IERC20TokenV06 token) internal pure returns (bool isETH) {
        return address(token) == ETH_TOKEN_ADDRESS;
    }

    
    
    
    
    function getTokenBalanceOf(IERC20TokenV06 token, address owner) internal view returns (uint256 tokenBalance) {
        if (isTokenETH(token)) {
            return owner.balance;
        }
        return token.balanceOf(owner);
    }

    
    
    
    function rlpEncodeNonce(uint32 nonce) internal pure returns (bytes memory rlpNonce) {
        // See https://github.com/ethereum/wiki/wiki/RLP for RLP encoding rules.
        if (nonce == 0) {
            rlpNonce = new bytes(1);
            rlpNonce[0] = 0x80;
        } else if (nonce < 0x80) {
            rlpNonce = new bytes(1);
            rlpNonce[0] = bytes1(uint8(nonce));
        } else if (nonce <= 0xFF) {
            rlpNonce = new bytes(2);
            rlpNonce[0] = 0x81;
            rlpNonce[1] = bytes1(uint8(nonce));
        } else if (nonce <= 0xFFFF) {
            rlpNonce = new bytes(3);
            rlpNonce[0] = 0x82;
            rlpNonce[1] = bytes1(uint8((nonce & 0xFF00) >> 8));
            rlpNonce[2] = bytes1(uint8(nonce));
        } else if (nonce <= 0xFFFFFF) {
            rlpNonce = new bytes(4);
            rlpNonce[0] = 0x83;
            rlpNonce[1] = bytes1(uint8((nonce & 0xFF0000) >> 16));
            rlpNonce[2] = bytes1(uint8((nonce & 0xFF00) >> 8));
            rlpNonce[3] = bytes1(uint8(nonce));
        } else {
            rlpNonce = new bytes(5);
            rlpNonce[0] = 0x84;
            rlpNonce[1] = bytes1(uint8((nonce & 0xFF000000) >> 24));
            rlpNonce[2] = bytes1(uint8((nonce & 0xFF0000) >> 16));
            rlpNonce[3] = bytes1(uint8((nonce & 0xFF00) >> 8));
            rlpNonce[4] = bytes1(uint8(nonce));
        }
    }

    
    ///      the nonce given by `deploymentNonce`.
    
    
    ///        a contract.
    
    function getDeployedAddress(address deployer, uint32 deploymentNonce)
        internal
        pure
        returns (address payable deploymentAddress)
    {
        // The address of if a deployed contract is the lower 20 bytes of the
        // hash of the RLP-encoded deployer's account address + account nonce.
        // See: https://ethereum.stackexchange.com/questions/760/how-is-the-address-of-an-ethereum-contract-computed
        bytes memory rlpNonce = rlpEncodeNonce(deploymentNonce);
        return
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                bytes1(uint8(0xC0 + 21 + rlpNonce.length)),
                                bytes1(uint8(0x80 + 20)),
                                deployer,
                                rlpNonce
                            )
                        )
                    )
                )
            );
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;





















interface IZeroEx is
    IOwnableFeature,
    ISimpleFunctionRegistryFeature,
    ITransformERC20Feature,
    IMetaTransactionsFeature,
    IUniswapFeature,
    IUniswapV3Feature,
    IPancakeSwapFeature,
    ILiquidityProviderFeature,
    INativeOrdersFeature,
    IBatchFillNativeOrdersFeature,
    IMultiplexFeature,
    IOtcOrdersFeature,
    IFundRecoveryFeature,
    IERC721OrdersFeature,
    IERC1155OrdersFeature,
    IERC165Feature
{
    // solhint-disable state-visibility

    
    receive() external payable;
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;





interface ITokenSpenderFeature {
    
    ///      Only callable from within.
    
    
    
    
    function _spendERC20Tokens(
        IERC20TokenV06 token,
        address owner,
        address to,
        uint256 amount
    ) external;

    
    ///      pulled from `owner`.
    
    
    
    function getSpendableERC20BalanceOf(IERC20TokenV06 token, address owner) external view returns (uint256 amount);

    
    
    function getAllowanceTarget() external view returns (address target);
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;





interface IFlashWallet {
    
    
    
    
    
    function executeCall(
        address payable target,
        bytes calldata callData,
        uint256 value
    ) external payable returns (bytes memory resultData);

    
    ///      Only an authority can call this.
    
    
    
    function executeDelegateCall(address payable target, bytes calldata callData)
        external
        payable
        returns (bytes memory resultData);

    
    receive() external payable;

    
    
    function owner() external view returns (address owner_);
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



interface ILiquidityProvider {
    
    
    
    
    
    
    
    
    
    
    
    event LiquidityProviderFill(
        IERC20TokenV06 inputToken,
        IERC20TokenV06 outputToken,
        uint256 inputTokenAmount,
        uint256 outputTokenAmount,
        bytes32 sourceId,
        address sourceAddress,
        address sender,
        address recipient
    );

    
    ///      to sell must be transferred to the contract prior to calling this
    ///      function to trigger the trade.
    
    
    
    
    
    
    function sellTokenForToken(
        IERC20TokenV06 inputToken,
        IERC20TokenV06 outputToken,
        address recipient,
        uint256 minBuyAmount,
        bytes calldata auxiliaryData
    ) external returns (uint256 boughtAmount);

    
    ///      call or sent to the contract prior to calling this function to
    ///      trigger the trade.
    
    
    
    
    
    function sellEthForToken(
        IERC20TokenV06 outputToken,
        address recipient,
        uint256 minBuyAmount,
        bytes calldata auxiliaryData
    ) external payable returns (uint256 boughtAmount);

    
    ///      to calling this function to trigger the trade.
    
    
    
    
    
    function sellTokenForEth(
        IERC20TokenV06 inputToken,
        address payable recipient,
        uint256 minBuyAmount,
        bytes calldata auxiliaryData
    ) external returns (uint256 boughtAmount);

    
    ///      selling `sellAmount` of `inputToken`.
    
    ///        the wETH address if selling ETH.
    
    ///        the wETH address if buying ETH.
    
    
    function getSellQuote(
        IERC20TokenV06 inputToken,
        IERC20TokenV06 outputToken,
        uint256 sellAmount
    ) external view returns (uint256 outputTokenAmount);
}

// 
/*

  Copyright 2021 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6;








library LibNFTOrder {
    enum OrderStatus {
        INVALID,
        FILLABLE,
        UNFILLABLE,
        EXPIRED
    }

    enum TradeDirection {
        SELL_NFT,
        BUY_NFT
    }

    struct Property {
        IPropertyValidator propertyValidator;
        bytes propertyData;
    }

    struct Fee {
        address recipient;
        uint256 amount;
        bytes feeData;
    }

    // "Base struct" for ERC721Order and ERC1155, used
    // by the abstract contract `NFTOrders`.
    struct NFTOrder {
        TradeDirection direction;
        address maker;
        address taker;
        uint256 expiry;
        uint256 nonce;
        IERC20TokenV06 erc20Token;
        uint256 erc20TokenAmount;
        Fee[] fees;
        address nft;
        uint256 nftId;
        Property[] nftProperties;
    }

    // All fields align with those of NFTOrder
    struct ERC721Order {
        TradeDirection direction;
        address maker;
        address taker;
        uint256 expiry;
        uint256 nonce;
        IERC20TokenV06 erc20Token;
        uint256 erc20TokenAmount;
        Fee[] fees;
        IERC721Token erc721Token;
        uint256 erc721TokenId;
        Property[] erc721TokenProperties;
    }

    // All fields except `erc1155TokenAmount` align
    // with those of NFTOrder
    struct ERC1155Order {
        TradeDirection direction;
        address maker;
        address taker;
        uint256 expiry;
        uint256 nonce;
        IERC20TokenV06 erc20Token;
        uint256 erc20TokenAmount;
        Fee[] fees;
        IERC1155Token erc1155Token;
        uint256 erc1155TokenId;
        Property[] erc1155TokenProperties;
        // End of fields shared with NFTOrder
        uint128 erc1155TokenAmount;
    }

    struct OrderInfo {
        bytes32 orderHash;
        OrderStatus status;
        // `orderAmount` is 1 for all ERC721Orders, and
        // `erc1155TokenAmount` for ERC1155Orders.
        uint128 orderAmount;
        // The remaining amount of the ERC721/ERC1155 asset
        // that can be filled for the order.
        uint128 remainingAmount;
    }

    // The type hash for ERC721 orders, which is:
    // keccak256(abi.encodePacked(
    //     "ERC721Order(",
    //       "uint8 direction,",
    //       "address maker,",
    //       "address taker,",
    //       "uint256 expiry,",
    //       "uint256 nonce,",
    //       "address erc20Token,",
    //       "uint256 erc20TokenAmount,",
    //       "Fee[] fees,",
    //       "address erc721Token,",
    //       "uint256 erc721TokenId,",
    //       "Property[] erc721TokenProperties",
    //     ")",
    //     "Fee(",
    //       "address recipient,",
    //       "uint256 amount,",
    //       "bytes feeData",
    //     ")",
    //     "Property(",
    //       "address propertyValidator,",
    //       "bytes propertyData",
    //     ")"
    // ))
    uint256 private constant _ERC_721_ORDER_TYPEHASH =
        0x2de32b2b090da7d8ab83ca4c85ba2eb6957bc7f6c50cb4ae1995e87560d808ed;

    // The type hash for ERC1155 orders, which is:
    // keccak256(abi.encodePacked(
    //     "ERC1155Order(",
    //       "uint8 direction,",
    //       "address maker,",
    //       "address taker,",
    //       "uint256 expiry,",
    //       "uint256 nonce,",
    //       "address erc20Token,",
    //       "uint256 erc20TokenAmount,",
    //       "Fee[] fees,",
    //       "address erc1155Token,",
    //       "uint256 erc1155TokenId,",
    //       "Property[] erc1155TokenProperties,",
    //       "uint128 erc1155TokenAmount",
    //     ")",
    //     "Fee(",
    //       "address recipient,",
    //       "uint256 amount,",
    //       "bytes feeData",
    //     ")",
    //     "Property(",
    //       "address propertyValidator,",
    //       "bytes propertyData",
    //     ")"
    // ))
    uint256 private constant _ERC_1155_ORDER_TYPEHASH =
        0x930490b1bcedd2e5139e22c761fafd52e533960197c2283f3922c7fd8c880be9;

    // keccak256(abi.encodePacked(
    //     "Fee(",
    //       "address recipient,",
    //       "uint256 amount,",
    //       "bytes feeData",
    //     ")"
    // ))
    uint256 private constant _FEE_TYPEHASH = 0xe68c29f1b4e8cce0bbcac76eb1334bdc1dc1f293a517c90e9e532340e1e94115;

    // keccak256(abi.encodePacked(
    //     "Property(",
    //       "address propertyValidator,",
    //       "bytes propertyData",
    //     ")"
    // ))
    uint256 private constant _PROPERTY_TYPEHASH = 0x6292cf854241cb36887e639065eca63b3af9f7f70270cebeda4c29b6d3bc65e8;

    // keccak256("");
    bytes32 private constant _EMPTY_ARRAY_KECCAK256 =
        0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

    // keccak256(abi.encodePacked(keccak256(abi.encode(
    //     _PROPERTY_TYPEHASH,
    //     address(0),
    //     keccak256("")
    // ))));
    bytes32 private constant _NULL_PROPERTY_STRUCT_HASH =
        0x720ee400a9024f6a49768142c339bf09d2dd9056ab52d20fbe7165faba6e142d;

    uint256 private constant ADDRESS_MASK = (1 << 160) - 1;

    // ERC721Order and NFTOrder fields are aligned, so
    // we can safely cast an ERC721Order to an NFTOrder.
    function asNFTOrder(ERC721Order memory erc721Order) internal pure returns (NFTOrder memory nftOrder) {
        assembly {
            nftOrder := erc721Order
        }
    }

    // ERC1155Order and NFTOrder fields are aligned with
    // the exception of the last field `erc1155TokenAmount`
    // in ERC1155Order, so we can safely cast an ERC1155Order
    // to an NFTOrder.
    function asNFTOrder(ERC1155Order memory erc1155Order) internal pure returns (NFTOrder memory nftOrder) {
        assembly {
            nftOrder := erc1155Order
        }
    }

    // ERC721Order and NFTOrder fields are aligned, so
    // we can safely cast an MFTOrder to an ERC721Order.
    function asERC721Order(NFTOrder memory nftOrder) internal pure returns (ERC721Order memory erc721Order) {
        assembly {
            erc721Order := nftOrder
        }
    }

    // NOTE: This is only safe if `nftOrder` was previously
    // cast from an `ERC1155Order` and the original
    // `erc1155TokenAmount` memory word has not been corrupted!
    function asERC1155Order(NFTOrder memory nftOrder) internal pure returns (ERC1155Order memory erc1155Order) {
        assembly {
            erc1155Order := nftOrder
        }
    }

    
    
    
    function getERC721OrderStructHash(ERC721Order memory order) internal pure returns (bytes32 structHash) {
        bytes32 propertiesHash = _propertiesHash(order.erc721TokenProperties);
        bytes32 feesHash = _feesHash(order.fees);

        // Hash in place, equivalent to:
        // return keccak256(abi.encode(
        //     _ERC_721_ORDER_TYPEHASH,
        //     order.direction,
        //     order.maker,
        //     order.taker,
        //     order.expiry,
        //     order.nonce,
        //     order.erc20Token,
        //     order.erc20TokenAmount,
        //     feesHash,
        //     order.erc721Token,
        //     order.erc721TokenId,
        //     propertiesHash
        // ));
        assembly {
            if lt(order, 32) {
                invalid()
            } // Don't underflow memory.

            let typeHashPos := sub(order, 32) // order - 32
            let feesHashPos := add(order, 224) // order + (32 * 7)
            let propertiesHashPos := add(order, 320) // order + (32 * 10)

            let typeHashMemBefore := mload(typeHashPos)
            let feeHashMemBefore := mload(feesHashPos)
            let propertiesHashMemBefore := mload(propertiesHashPos)

            mstore(typeHashPos, _ERC_721_ORDER_TYPEHASH)
            mstore(feesHashPos, feesHash)
            mstore(propertiesHashPos, propertiesHash)
            structHash := keccak256(
                typeHashPos,
                384 /* 32 * 12 */
            )

            mstore(typeHashPos, typeHashMemBefore)
            mstore(feesHashPos, feeHashMemBefore)
            mstore(propertiesHashPos, propertiesHashMemBefore)
        }
        return structHash;
    }

    
    
    
    function getERC1155OrderStructHash(ERC1155Order memory order) internal pure returns (bytes32 structHash) {
        bytes32 propertiesHash = _propertiesHash(order.erc1155TokenProperties);
        bytes32 feesHash = _feesHash(order.fees);

        // Hash in place, equivalent to:
        // return keccak256(abi.encode(
        //     _ERC_1155_ORDER_TYPEHASH,
        //     order.direction,
        //     order.maker,
        //     order.taker,
        //     order.expiry,
        //     order.nonce,
        //     order.erc20Token,
        //     order.erc20TokenAmount,
        //     feesHash,
        //     order.erc1155Token,
        //     order.erc1155TokenId,
        //     propertiesHash,
        //     order.erc1155TokenAmount
        // ));
        assembly {
            if lt(order, 32) {
                invalid()
            } // Don't underflow memory.

            let typeHashPos := sub(order, 32) // order - 32
            let feesHashPos := add(order, 224) // order + (32 * 7)
            let propertiesHashPos := add(order, 320) // order + (32 * 10)

            let typeHashMemBefore := mload(typeHashPos)
            let feesHashMemBefore := mload(feesHashPos)
            let propertiesHashMemBefore := mload(propertiesHashPos)

            mstore(typeHashPos, _ERC_1155_ORDER_TYPEHASH)
            mstore(feesHashPos, feesHash)
            mstore(propertiesHashPos, propertiesHash)
            structHash := keccak256(
                typeHashPos,
                416 /* 32 * 12 */
            )

            mstore(typeHashPos, typeHashMemBefore)
            mstore(feesHashPos, feesHashMemBefore)
            mstore(propertiesHashPos, propertiesHashMemBefore)
        }
        return structHash;
    }

    // Hashes the `properties` arrayB as part of computing the
    // EIP-712 hash of an `ERC721Order` or `ERC1155Order`.
    function _propertiesHash(Property[] memory properties) private pure returns (bytes32 propertiesHash) {
        uint256 numProperties = properties.length;
        // We give `properties.length == 0` and `properties.length == 1`
        // special treatment because we expect these to be the most common.
        if (numProperties == 0) {
            propertiesHash = _EMPTY_ARRAY_KECCAK256;
        } else if (numProperties == 1) {
            Property memory property = properties[0];
            if (address(property.propertyValidator) == address(0) && property.propertyData.length == 0) {
                propertiesHash = _NULL_PROPERTY_STRUCT_HASH;
            } else {
                // propertiesHash = keccak256(abi.encodePacked(keccak256(abi.encode(
                //     _PROPERTY_TYPEHASH,
                //     properties[0].propertyValidator,
                //     keccak256(properties[0].propertyData)
                // ))));
                bytes32 dataHash = keccak256(property.propertyData);
                assembly {
                    // Load free memory pointer
                    let mem := mload(64)
                    mstore(mem, _PROPERTY_TYPEHASH)
                    // property.propertyValidator
                    mstore(add(mem, 32), and(ADDRESS_MASK, mload(property)))
                    // keccak256(property.propertyData)
                    mstore(add(mem, 64), dataHash)
                    mstore(mem, keccak256(mem, 96))
                    propertiesHash := keccak256(mem, 32)
                }
            }
        } else {
            bytes32[] memory propertyStructHashArray = new bytes32[](numProperties);
            for (uint256 i = 0; i < numProperties; i++) {
                propertyStructHashArray[i] = keccak256(
                    abi.encode(
                        _PROPERTY_TYPEHASH,
                        properties[i].propertyValidator,
                        keccak256(properties[i].propertyData)
                    )
                );
            }
            assembly {
                propertiesHash := keccak256(add(propertyStructHashArray, 32), mul(numProperties, 32))
            }
        }
    }

    // Hashes the `fees` arrayB as part of computing the
    // EIP-712 hash of an `ERC721Order` or `ERC1155Order`.
    function _feesHash(Fee[] memory fees) private pure returns (bytes32 feesHash) {
        uint256 numFees = fees.length;
        // We give `fees.length == 0` and `fees.length == 1`
        // special treatment because we expect these to be the most common.
        if (numFees == 0) {
            feesHash = _EMPTY_ARRAY_KECCAK256;
        } else if (numFees == 1) {
            // feesHash = keccak256(abi.encodePacked(keccak256(abi.encode(
            //     _FEE_TYPEHASH,
            //     fees[0].recipient,
            //     fees[0].amount,
            //     keccak256(fees[0].feeData)
            // ))));
            Fee memory fee = fees[0];
            bytes32 dataHash = keccak256(fee.feeData);
            assembly {
                // Load free memory pointer
                let mem := mload(64)
                mstore(mem, _FEE_TYPEHASH)
                // fee.recipient
                mstore(add(mem, 32), and(ADDRESS_MASK, mload(fee)))
                // fee.amount
                mstore(add(mem, 64), mload(add(fee, 32)))
                // keccak256(fee.feeData)
                mstore(add(mem, 96), dataHash)
                mstore(mem, keccak256(mem, 128))
                feesHash := keccak256(mem, 32)
            }
        } else {
            bytes32[] memory feeStructHashArray = new bytes32[](numFees);
            for (uint256 i = 0; i < numFees; i++) {
                feeStructHashArray[i] = keccak256(
                    abi.encode(_FEE_TYPEHASH, fees[i].recipient, fees[i].amount, keccak256(fees[i].feeData))
                );
            }
            assembly {
                feesHash := keccak256(add(feeStructHashArray, 32), mul(numFees, 32))
            }
        }
    }
}

// 
/*

  Copyright 2022 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6;


interface IERC1155Token {
    
    ///      including zero value transfers as well as minting or burning.
    /// Operator will always be msg.sender.
    /// Either event from address `0x0` signifies a minting operation.
    /// An event to address `0x0` signifies a burning or melting operation.
    /// The total value transferred from address 0x0 minus the total value transferred to 0x0 may
    /// be used by clients and exchanges to be added to the "circulating supply" for a given token ID.
    /// To define a token ID with no initial balance, the contract SHOULD emit the TransferSingle event
    /// from `0x0` to `0x0`, with the token creator as `_operator`.
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    
    ///      including zero value transfers as well as minting or burning.
    ///Operator will always be msg.sender.
    /// Either event from address `0x0` signifies a minting operation.
    /// An event to address `0x0` signifies a burning or melting operation.
    /// The total value transferred from address 0x0 minus the total value transferred to 0x0 may
    /// be used by clients and exchanges to be added to the "circulating supply" for a given token ID.
    /// To define multiple token IDs with no initial balance, this SHOULD emit the TransferBatch event
    /// from `0x0` to `0x0`, with the token creator as `_operator`.
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    
    /// URIs are defined in RFC 3986.
    /// The URI MUST point a JSON file that conforms to the "ERC-1155 Metadata JSON Schema".
    event URI(string value, uint256 indexed id);

    
    
    /// Caller must be approved to manage the _from account's tokens (see isApprovedForAll).
    /// MUST throw if `_to` is the zero address.
    /// MUST throw if balance of sender for token `_id` is lower than the `_value` sent.
    /// MUST throw on any other error.
    /// When transfer is complete, this function MUST check if `_to` is a smart contract (code size > 0).
    /// If so, it MUST call `onERC1155Received` on `_to` and revert if the return value
    /// is not `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`.
    
    
    
    
    
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external;

    
    
    /// Caller must be approved to manage the _from account's tokens (see isApprovedForAll).
    /// MUST throw if `_to` is the zero address.
    /// MUST throw if length of `_ids` is not the same as length of `_values`.
    ///  MUST throw if any of the balance of sender for token `_ids` is lower than the respective `_values` sent.
    /// MUST throw on any other error.
    /// When transfer is complete, this function MUST check if `_to` is a smart contract (code size > 0).
    /// If so, it MUST call `onERC1155BatchReceived` on `_to` and revert if the return value
    /// is not `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`.
    
    
    
    
    
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external;

    
    
    
    
    function setApprovalForAll(address operator, bool approved) external;

    
    
    
    
    function isApprovedForAll(address owner, address operator) external view returns (bool isApproved);

    
    
    
    
    function balanceOf(address owner, uint256 id) external view returns (uint256 balance);

    
    
    
    
    function balanceOfBatch(address[] calldata owners, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory balances_);
}

// 
/*

  Copyright 2021 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6;

interface IERC721Token {
    
    ///      This event emits when NFTs are created (`from` == 0) and destroyed
    ///      (`to` == 0). Exception: during contract creation, any number of NFTs
    ///      may be created and assigned without emitting Transfer. At the time of
    ///      any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    
    ///      reaffirmed. The zero address indicates there is no approved address.
    ///      When a Transfer event emits, this also indicates that the approved
    ///      address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    
    ///      The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    
    
    ///      perator, or the approved address for this NFT. Throws if `_from` is
    ///      not the current owner. Throws if `_to` is the zero address. Throws if
    ///      `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///      checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///      `onERC721Received` on `_to` and throws if the return value is not
    ///      `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    
    
    
    
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    ) external;

    
    
    ///      except this function just sets data to "".
    
    
    
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    
    
    ///      Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///      operator of the current owner.
    
    
    function approve(address _approved, uint256 _tokenId) external;

    
    ///         all of `msg.sender`'s assets
    
    ///      multiple operators per owner.
    
    
    function setApprovalForAll(address _operator, bool _approved) external;

    
    
    ///      function throws for queries about the zero address.
    
    
    function balanceOf(address _owner) external view returns (uint256);

    
    ///         TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///         THEY MAY BE PERMANENTLY LOST
    
    ///      operator, or the approved address for this NFT. Throws if `_from` is
    ///      not the current owner. Throws if `_to` is the zero address. Throws if
    ///      `_tokenId` is not a valid NFT.
    
    
    
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    
    
    ///      about them do throw.
    
    
    function ownerOf(uint256 _tokenId) external view returns (address);

    
    
    
    
    function getApproved(uint256 _tokenId) external view returns (address);

    
    
    
    
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

// 
/*

  Copyright 2021 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6;


interface IPropertyValidator {
    
    ///      Should revert if the asset does not satisfy the specified properties.
    
    
    
    function validateProperty(
        address tokenAddress,
        uint256 tokenId,
        bytes calldata propertyData
    ) external view;
}
