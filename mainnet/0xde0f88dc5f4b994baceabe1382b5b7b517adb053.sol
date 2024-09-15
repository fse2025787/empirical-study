// SPDX-License-Identifier: Apache-2.0
pragma experimental ABIEncoderV2;


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








abstract contract FixinEIP712 {

    
    bytes32 public immutable EIP712_DOMAIN_SEPARATOR;

    constructor(address zeroExAddress) internal {
        // Compute `EIP712_DOMAIN_SEPARATOR`
        {
            uint256 chainId;
            assembly { chainId := chainid() }
            EIP712_DOMAIN_SEPARATOR = keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain("
                            "string name,"
                            "string version,"
                            "uint256 chainId,"
                            "address verifyingContract"
                        ")"
                    ),
                    keccak256("ZeroEx"),
                    keccak256("1.0.0"),
                    chainId,
                    zeroExAddress
                )
            );
        }
    }

    function _getEIP712Hash(bytes32 structHash)
        internal
        view
        returns (bytes32 eip712Hash)
    {
        return keccak256(abi.encodePacked(
            hex"1901",
            EIP712_DOMAIN_SEPARATOR,
            structHash
        ));
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







abstract contract FixinTokenSpender {

    // Mask of the lower 20 bytes of a bytes32.
    uint256 constant private ADDRESS_MASK = 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;

    
    
    
    
    
    function _transferERC20TokensFrom(
        IERC20TokenV06 token,
        address owner,
        address to,
        uint256 amount
    )
        internal
    {
        require(address(token) != address(this), "FixinTokenSpender/CANNOT_INVOKE_SELF");

        assembly {
            let ptr := mload(0x40) // free memory pointer

            // selector for transferFrom(address,address,uint256)
            mstore(ptr, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr, 0x04), and(owner, ADDRESS_MASK))
            mstore(add(ptr, 0x24), and(to, ADDRESS_MASK))
            mstore(add(ptr, 0x44), amount)

            let success := call(
                gas(),
                and(token, ADDRESS_MASK),
                0,
                ptr,
                0x64,
                ptr,
                32
            )

            let rdsize := returndatasize()

            // Check for ERC20 success. ERC20 tokens should return a boolean,
            // but some don't. We accept 0-length return data as success, or at
            // least 32 bytes that starts with a 32-byte boolean true.
            success := and(
                success,                             // call itself succeeded
                or(
                    iszero(rdsize),                  // no return data, or
                    and(
                        iszero(lt(rdsize, 32)),      // at least 32 bytes
                        eq(mload(ptr), 1)            // starts with uint256(1)
                    )
                )
            )

            if iszero(success) {
                returndatacopy(ptr, 0, rdsize)
                revert(ptr, rdsize)
            }
        }
    }

    
    
    
    
    function _transferERC20Tokens(
        IERC20TokenV06 token,
        address to,
        uint256 amount
    )
        internal
    {
        require(address(token) != address(this), "FixinTokenSpender/CANNOT_INVOKE_SELF");

        assembly {
            let ptr := mload(0x40) // free memory pointer

            // selector for transfer(address,uint256)
            mstore(ptr, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr, 0x04), and(to, ADDRESS_MASK))
            mstore(add(ptr, 0x24), amount)

            let success := call(
                gas(),
                and(token, ADDRESS_MASK),
                0,
                ptr,
                0x44,
                ptr,
                32
            )

            let rdsize := returndatasize()

            // Check for ERC20 success. ERC20 tokens should return a boolean,
            // but some don't. We accept 0-length return data as success, or at
            // least 32 bytes that starts with a 32-byte boolean true.
            success := and(
                success,                             // call itself succeeded
                or(
                    iszero(rdsize),                  // no return data, or
                    and(
                        iszero(lt(rdsize, 32)),      // at least 32 bytes
                        eq(mload(ptr), 1)            // starts with uint256(1)
                    )
                )
            )

            if iszero(success) {
                returndatacopy(ptr, 0, rdsize)
                revert(ptr, rdsize)
            }
        }
    }

    
    ///      pulled from `owner` by this address.
    
    
    
    function _getSpendableERC20BalanceOf(
        IERC20TokenV06 token,
        address owner
    )
        internal
        view
        returns (uint256)
    {
        return LibSafeMathV06.min256(
            token.allowance(owner, address(this)),
            token.balanceOf(owner)
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

    
    
    
    event OrderCancelled(
        bytes32 orderHash,
        address maker
    );

    
    
    
    
    
    ///        have.
    event PairCancelledLimitOrders(
        address maker,
        address makerToken,
        address takerToken,
        uint256 minValidSalt
    );

    
    
    
    
    
    ///        have.
    event PairCancelledRfqOrders(
        address maker,
        address makerToken,
        address takerToken,
        uint256 minValidSalt
    );

    
    ///      orders with a given txOrigin.
    
    
    
    event RfqOrderOriginsAllowed(
        address origin,
        address[] addrs,
        bool allowed
    );

    
    
    
    
    event OrderSignerRegistered(
        address maker,
        address signer,
        bool allowed
    );
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













abstract contract NativeOrdersInfo is
    FixinEIP712,
    FixinTokenSpender
{
    using LibSafeMathV06 for uint256;
    using LibRichErrorsV06 for bytes;

    // @dev Params for `_getActualFillableTakerTokenAmount()`.
    struct GetActualFillableTakerTokenAmountParams {
        address maker;
        IERC20TokenV06 makerToken;
        uint128 orderMakerAmount;
        uint128 orderTakerAmount;
        LibNativeOrder.OrderInfo orderInfo;
    }

    
    uint256 private constant HIGH_BIT = 1 << 255;

    constructor(
        address zeroExAddress
    )
        internal
        FixinEIP712(zeroExAddress)
    {
        // solhint-disable no-empty-blocks
    }

    
    
    
    function getLimitOrderInfo(LibNativeOrder.LimitOrder memory order)
        public
        view
        returns (LibNativeOrder.OrderInfo memory orderInfo)
    {
        // Recover maker and compute order hash.
        orderInfo.orderHash = getLimitOrderHash(order);
        uint256 minValidSalt = LibNativeOrdersStorage.getStorage()
            .limitOrdersMakerToMakerTokenToTakerTokenToMinValidOrderSalt
                [order.maker]
                [address(order.makerToken)]
                [address(order.takerToken)];
        _populateCommonOrderInfoFields(
            orderInfo,
            order.takerAmount,
            order.expiry,
            order.salt,
            minValidSalt
        );
    }

    
    
    
    function getRfqOrderInfo(LibNativeOrder.RfqOrder memory order)
        public
        view
        returns (LibNativeOrder.OrderInfo memory orderInfo)
    {
        // Recover maker and compute order hash.
        orderInfo.orderHash = getRfqOrderHash(order);
        uint256 minValidSalt = LibNativeOrdersStorage.getStorage()
            .rfqOrdersMakerToMakerTokenToTakerTokenToMinValidOrderSalt
                [order.maker]
                [address(order.makerToken)]
                [address(order.takerToken)];
        _populateCommonOrderInfoFields(
            orderInfo,
            order.takerAmount,
            order.expiry,
            order.salt,
            minValidSalt
        );

        // Check for missing txOrigin.
        if (order.txOrigin == address(0)) {
            orderInfo.status = LibNativeOrder.OrderStatus.INVALID;
        }
    }

    
    
    
    function getLimitOrderHash(LibNativeOrder.LimitOrder memory order)
        public
        view
        returns (bytes32 orderHash)
    {
        return _getEIP712Hash(
            LibNativeOrder.getLimitOrderStructHash(order)
        );
    }

    
    
    
    function getRfqOrderHash(LibNativeOrder.RfqOrder memory order)
        public
        view
        returns (bytes32 orderHash)
    {
        return _getEIP712Hash(
            LibNativeOrder.getRfqOrderStructHash(order)
        );
    }

    
    ///      Fillable amount is determined using balances and allowances of the maker.
    
    
    
    
    ///         based on maker funds, in taker tokens.
    
    function getLimitOrderRelevantState(
        LibNativeOrder.LimitOrder memory order,
        LibSignature.Signature calldata signature
    )
        public
        view
        returns (
            LibNativeOrder.OrderInfo memory orderInfo,
            uint128 actualFillableTakerTokenAmount,
            bool isSignatureValid
        )
    {
        orderInfo = getLimitOrderInfo(order);
        actualFillableTakerTokenAmount = _getActualFillableTakerTokenAmount(
            GetActualFillableTakerTokenAmountParams({
                maker: order.maker,
                makerToken: order.makerToken,
                orderMakerAmount: order.makerAmount,
                orderTakerAmount: order.takerAmount,
                orderInfo: orderInfo
            })
        );
        address signerOfHash = LibSignature.getSignerOfHash(orderInfo.orderHash, signature);
        isSignatureValid =
            (order.maker == signerOfHash) ||
            isValidOrderSigner(order.maker, signerOfHash);
    }

    
    ///      Fillable amount is determined using balances and allowances of the maker.
    
    
    
    
    ///         based on maker funds, in taker tokens.
    
    function getRfqOrderRelevantState(
        LibNativeOrder.RfqOrder memory order,
        LibSignature.Signature memory signature
    )
        public
        view
        returns (
            LibNativeOrder.OrderInfo memory orderInfo,
            uint128 actualFillableTakerTokenAmount,
            bool isSignatureValid
        )
    {
        orderInfo = getRfqOrderInfo(order);
        actualFillableTakerTokenAmount = _getActualFillableTakerTokenAmount(
            GetActualFillableTakerTokenAmountParams({
                maker: order.maker,
                makerToken: order.makerToken,
                orderMakerAmount: order.makerAmount,
                orderTakerAmount: order.takerAmount,
                orderInfo: orderInfo
            })
        );
        address signerOfHash = LibSignature.getSignerOfHash(orderInfo.orderHash, signature);
        isSignatureValid =
            (order.maker == signerOfHash) ||
            isValidOrderSigner(order.maker, signerOfHash);
    }

    
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
        )
    {
        require(
            orders.length == signatures.length,
            "NativeOrdersFeature/MISMATCHED_ARRAY_LENGTHS"
        );
        orderInfos = new LibNativeOrder.OrderInfo[](orders.length);
        actualFillableTakerTokenAmounts = new uint128[](orders.length);
        isSignatureValids = new bool[](orders.length);
        for (uint256 i = 0; i < orders.length; ++i) {
            try
                this.getLimitOrderRelevantState(orders[i], signatures[i])
                    returns (
                        LibNativeOrder.OrderInfo memory orderInfo,
                        uint128 actualFillableTakerTokenAmount,
                        bool isSignatureValid
                    )
            {
                orderInfos[i] = orderInfo;
                actualFillableTakerTokenAmounts[i] = actualFillableTakerTokenAmount;
                isSignatureValids[i] = isSignatureValid;
            }
            catch {}
        }
    }

    
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
        )
    {
        require(
            orders.length == signatures.length,
            "NativeOrdersFeature/MISMATCHED_ARRAY_LENGTHS"
        );
        orderInfos = new LibNativeOrder.OrderInfo[](orders.length);
        actualFillableTakerTokenAmounts = new uint128[](orders.length);
        isSignatureValids = new bool[](orders.length);
        for (uint256 i = 0; i < orders.length; ++i) {
            try
                this.getRfqOrderRelevantState(orders[i], signatures[i])
                    returns (
                        LibNativeOrder.OrderInfo memory orderInfo,
                        uint128 actualFillableTakerTokenAmount,
                        bool isSignatureValid
                    )
            {
                orderInfos[i] = orderInfo;
                actualFillableTakerTokenAmounts[i] = actualFillableTakerTokenAmount;
                isSignatureValids[i] = isSignatureValid;
            }
            catch {}
        }
    }

    
    ///      `orderInfo`, which use the same code path for both limit and
    ///      RFQ orders.
    
    
    
    
    
    function _populateCommonOrderInfoFields(
        LibNativeOrder.OrderInfo memory orderInfo,
        uint128 takerAmount,
        uint64 expiry,
        uint256 salt,
        uint256 minValidSalt
    )
        private
        view
    {
        LibNativeOrdersStorage.Storage storage stor =
            LibNativeOrdersStorage.getStorage();

        // Get the filled and direct cancel state.
        {
            // The high bit of the raw taker token filled amount will be set
            // if the order was cancelled.
            uint256 rawTakerTokenFilledAmount =
                stor.orderHashToTakerTokenFilledAmount[orderInfo.orderHash];
            orderInfo.takerTokenFilledAmount = uint128(rawTakerTokenFilledAmount);
            if (orderInfo.takerTokenFilledAmount >= takerAmount) {
                orderInfo.status = LibNativeOrder.OrderStatus.FILLED;
                return;
            }
            if (rawTakerTokenFilledAmount & HIGH_BIT != 0) {
                orderInfo.status = LibNativeOrder.OrderStatus.CANCELLED;
                return;
            }
        }

        // Check for expiration.
        if (expiry <= uint64(block.timestamp)) {
            orderInfo.status = LibNativeOrder.OrderStatus.EXPIRED;
            return;
        }

        // Check if the order was cancelled by salt.
        if (minValidSalt > salt) {
            orderInfo.status = LibNativeOrder.OrderStatus.CANCELLED;
            return;
        }
        orderInfo.status = LibNativeOrder.OrderStatus.FILLABLE;
    }

    
    ///      based on maker allowance and balances.
    function _getActualFillableTakerTokenAmount(
        GetActualFillableTakerTokenAmountParams memory params
    )
        private
        view
        returns (uint128 actualFillableTakerTokenAmount)
    {
        if (params.orderMakerAmount == 0 || params.orderTakerAmount == 0) {
            // Empty order.
            return 0;
        }
        if (params.orderInfo.status != LibNativeOrder.OrderStatus.FILLABLE) {
            // Not fillable.
            return 0;
        }

        // Get the fillable maker amount based on the order quantities and
        // previously filled amount
        uint256 fillableMakerTokenAmount = LibMathV06.getPartialAmountFloor(
            uint256(
                params.orderTakerAmount
                - params.orderInfo.takerTokenFilledAmount
            ),
            uint256(params.orderTakerAmount),
            uint256(params.orderMakerAmount)
        );
        // Clamp it to the amount of maker tokens we can spend on behalf of the
        // maker.
        fillableMakerTokenAmount = LibSafeMathV06.min256(
            fillableMakerTokenAmount,
            _getSpendableERC20BalanceOf(params.makerToken, params.maker)
        );
        // Convert to taker token amount.
        return LibMathV06.getPartialAmountCeil(
            fillableMakerTokenAmount,
            uint256(params.orderMakerAmount),
            uint256(params.orderTakerAmount)
        ).safeDowncastToUint128();
    }

    
    
    
    function isValidOrderSigner(
        address maker,
        address signer
    )
        public
        view
        returns (bool isValid)
    {
        // returns false if it the mapping doesn't exist
        return LibNativeOrdersStorage.getStorage()
            .orderSignerRegistry
                [maker]
                [signer];
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










abstract contract FixinProtocolFees {

    
    uint32 public immutable PROTOCOL_FEE_MULTIPLIER;
    
    FeeCollectorController private immutable FEE_COLLECTOR_CONTROLLER;
    
    bytes32 private immutable FEE_COLLECTOR_INIT_CODE_HASH;
    
    IEtherTokenV06 private immutable WETH;
    
    IStaking private immutable STAKING;

    constructor(
        IEtherTokenV06 weth,
        IStaking staking,
        FeeCollectorController feeCollectorController,
        uint32 protocolFeeMultiplier
    )
        internal
    {
        FEE_COLLECTOR_CONTROLLER = feeCollectorController;
        FEE_COLLECTOR_INIT_CODE_HASH =
            feeCollectorController.FEE_COLLECTOR_INIT_CODE_HASH();
        WETH = weth;
        STAKING = staking;
        PROTOCOL_FEE_MULTIPLIER = protocolFeeMultiplier;
    }

    
    ///        The fee is stored in a per-pool fee collector contract.
    
    
    function _collectProtocolFee(bytes32 poolId)
        internal
        returns (uint256 ethProtocolFeePaid)
    {
        uint256 protocolFeePaid = _getSingleProtocolFee();
        if (protocolFeePaid == 0) {
            // Nothing to do.
            return 0;
        }
        FeeCollector feeCollector = _getFeeCollector(poolId);
        (bool success,) = address(feeCollector).call{value: protocolFeePaid}("");
        require(success, "FixinProtocolFees/ETHER_TRANSFER_FALIED");
        return protocolFeePaid;
    }

    
    
    function _transferFeesForPool(bytes32 poolId)
        internal
    {
        // This will create a FeeCollector contract (if necessary) and wrap
        // fees for the pool ID.
        FeeCollector feeCollector =
            FEE_COLLECTOR_CONTROLLER.prepareFeeCollectorToPayFees(poolId);
        // All fees in the fee collector should be in WETH now.
        uint256 bal = WETH.balanceOf(address(feeCollector));
        if (bal > 1) {
            // Leave 1 wei behind to avoid high SSTORE cost of zero-->non-zero.
            STAKING.payProtocolFee(
                address(feeCollector),
                address(feeCollector),
                bal - 1);
        }
    }

    
    
    function _getFeeCollector(bytes32 poolId)
        internal
        view
        returns (FeeCollector)
    {
        return FeeCollector(LibFeeCollector.getFeeCollectorAddress(
            address(FEE_COLLECTOR_CONTROLLER),
            FEE_COLLECTOR_INIT_CODE_HASH,
            poolId
        ));
    }

    
    
    function _getSingleProtocolFee()
        internal
        view
        returns (uint256 protocolFeeAmount)
    {
        return uint256(PROTOCOL_FEE_MULTIPLIER) * tx.gasprice;
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










abstract contract FixinCommon {

    using LibRichErrorsV06 for bytes;

    
    address internal immutable _implementation;

    
    modifier onlySelf() virtual {
        if (msg.sender != address(this)) {
            LibCommonRichErrors.OnlyCallableBySelfError(msg.sender).rrevert();
        }
        _;
    }

    
    modifier onlyOwner() virtual {
        {
            address owner = IOwnableFeature(address(this)).owner();
            if (msg.sender != owner) {
                LibOwnableRichErrors.OnlyOwnerError(
                    msg.sender,
                    owner
                ).rrevert();
            }
        }
        _;
    }

    constructor() internal {
        // Remember this feature's original address.
        _implementation = address(this);
    }

    
    ///      Can and should only be called within a `migrate()`.
    
    ///        is at `_implementation`.
    function _registerFeatureFunction(bytes4 selector)
        internal
    {
        ISimpleFunctionRegistryFeature(address(this)).extend(selector, _implementation);
    }

    
    
    
    
    
    function _encodeVersion(uint32 major, uint32 minor, uint32 revision)
        internal
        pure
        returns (uint256 encodedVersion)
    {
        return (uint256(major) << 64) | (uint256(minor) << 32) | uint256(revision);
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












abstract contract NativeOrdersCancellation is
    INativeOrdersEvents,
    NativeOrdersInfo
{
    using LibRichErrorsV06 for bytes;

    
    uint256 private constant HIGH_BIT = 1 << 255;

    constructor(
        address zeroExAddress
    )
        internal
        NativeOrdersInfo(zeroExAddress)
    {
        // solhint-disable no-empty-blocks
    }

    
    ///      Silently succeeds if the order has already been cancelled.
    
    function cancelLimitOrder(LibNativeOrder.LimitOrder memory order)
        public
    {
        bytes32 orderHash = getLimitOrderHash(order);
        if (msg.sender != order.maker && !isValidOrderSigner(order.maker, msg.sender)) {
            LibNativeOrdersRichErrors.OnlyOrderMakerAllowed(
                orderHash,
                msg.sender,
                order.maker
            ).rrevert();
        }
        _cancelOrderHash(orderHash, order.maker);
    }

    
    ///      Silently succeeds if the order has already been cancelled.
    
    function cancelRfqOrder(LibNativeOrder.RfqOrder memory order)
        public
    {
        bytes32 orderHash = getRfqOrderHash(order);
        if (msg.sender != order.maker && !isValidOrderSigner(order.maker, msg.sender)) {
            LibNativeOrdersRichErrors.OnlyOrderMakerAllowed(
                orderHash,
                msg.sender,
                order.maker
            ).rrevert();
        }
        _cancelOrderHash(orderHash, order.maker);
    }

    
    ///      Silently succeeds if the order has already been cancelled.
    
    function batchCancelLimitOrders(LibNativeOrder.LimitOrder[] memory orders)
        public
    {
        for (uint256 i = 0; i < orders.length; ++i) {
            cancelLimitOrder(orders[i]);
        }
    }

    
    ///      Silently succeeds if the order has already been cancelled.
    
    function batchCancelRfqOrders(LibNativeOrder.RfqOrder[] memory orders)
        public
    {
        for (uint256 i = 0; i < orders.length; ++i) {
            cancelRfqOrder(orders[i]);
        }
    }

    
    ///      than the value provided. The caller must be the maker. Subsequent
    ///      calls to this function with the same caller and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    function cancelPairLimitOrders(
        IERC20TokenV06 makerToken,
        IERC20TokenV06 takerToken,
        uint256 minValidSalt
    )
        public
    {
        _cancelPairLimitOrders(msg.sender, makerToken, takerToken, minValidSalt);
    }

    
    ///      than the value provided. The caller must be a signer registered to the maker.
    ///      Subsequent calls to this function with the same caller and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    
    function cancelPairLimitOrdersWithSigner(
        address maker,
        IERC20TokenV06 makerToken,
        IERC20TokenV06 takerToken,
        uint256 minValidSalt
    )
        public
    {
        // verify that the signer is authorized for the maker
        if (!isValidOrderSigner(maker, msg.sender)) {
            LibNativeOrdersRichErrors.InvalidSignerError(
                maker,
                msg.sender
            ).rrevert();
        }

        _cancelPairLimitOrders(maker, makerToken, takerToken, minValidSalt);
    }

    
    ///      than the value provided. The caller must be the maker. Subsequent
    ///      calls to this function with the same caller and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    function batchCancelPairLimitOrders(
        IERC20TokenV06[] memory makerTokens,
        IERC20TokenV06[] memory takerTokens,
        uint256[] memory minValidSalts
    )
        public
    {
        require(
            makerTokens.length == takerTokens.length &&
            makerTokens.length == minValidSalts.length,
            "NativeOrdersFeature/MISMATCHED_PAIR_ORDERS_ARRAY_LENGTHS"
        );

        for (uint256 i = 0; i < makerTokens.length; ++i) {
            _cancelPairLimitOrders(
                msg.sender,
                makerTokens[i],
                takerTokens[i],
                minValidSalts[i]
            );
        }
    }

    
    ///      than the value provided. The caller must be a signer registered to the maker.
    ///      Subsequent calls to this function with the same caller and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    
    function batchCancelPairLimitOrdersWithSigner(
        address maker,
        IERC20TokenV06[] memory makerTokens,
        IERC20TokenV06[] memory takerTokens,
        uint256[] memory minValidSalts
    )
        public
    {
        require(
            makerTokens.length == takerTokens.length &&
            makerTokens.length == minValidSalts.length,
            "NativeOrdersFeature/MISMATCHED_PAIR_ORDERS_ARRAY_LENGTHS"
        );

        if (!isValidOrderSigner(maker, msg.sender)) {
            LibNativeOrdersRichErrors.InvalidSignerError(
                maker,
                msg.sender
            ).rrevert();
        }

        for (uint256 i = 0; i < makerTokens.length; ++i) {
            _cancelPairLimitOrders(
                maker,
                makerTokens[i],
                takerTokens[i],
                minValidSalts[i]
            );
        }
    }

    
    ///      than the value provided. The caller must be the maker. Subsequent
    ///      calls to this function with the same caller and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    function cancelPairRfqOrders(
        IERC20TokenV06 makerToken,
        IERC20TokenV06 takerToken,
        uint256 minValidSalt
    )
        public
    {
        _cancelPairRfqOrders(msg.sender, makerToken, takerToken, minValidSalt);
    }

    
    ///      than the value provided. The caller must be a signer registered to the maker.
    ///      Subsequent calls to this function with the same caller and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    
    function cancelPairRfqOrdersWithSigner(
        address maker,
        IERC20TokenV06 makerToken,
        IERC20TokenV06 takerToken,
        uint256 minValidSalt
    )
        public
    {
        if (!isValidOrderSigner(maker, msg.sender)) {
            LibNativeOrdersRichErrors.InvalidSignerError(
                maker,
                msg.sender
            ).rrevert();
        }

        _cancelPairRfqOrders(maker, makerToken, takerToken, minValidSalt);
    }

    
    ///      than the value provided. The caller must be the maker. Subsequent
    ///      calls to this function with the same caller and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    function batchCancelPairRfqOrders(
        IERC20TokenV06[] memory makerTokens,
        IERC20TokenV06[] memory takerTokens,
        uint256[] memory minValidSalts
    )
        public
    {
        require(
            makerTokens.length == takerTokens.length &&
            makerTokens.length == minValidSalts.length,
            "NativeOrdersFeature/MISMATCHED_PAIR_ORDERS_ARRAY_LENGTHS"
        );

        for (uint256 i = 0; i < makerTokens.length; ++i) {
            _cancelPairRfqOrders(
                msg.sender,
                makerTokens[i],
                takerTokens[i],
                minValidSalts[i]
            );
        }
    }

    
    ///      than the values provided. The caller must be a signer registered to the maker.
    ///      Subsequent calls to this function with the same caller and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    
    function batchCancelPairRfqOrdersWithSigner(
        address maker,
        IERC20TokenV06[] memory makerTokens,
        IERC20TokenV06[] memory takerTokens,
        uint256[] memory minValidSalts
    )
        public
    {
        require(
            makerTokens.length == takerTokens.length &&
            makerTokens.length == minValidSalts.length,
            "NativeOrdersFeature/MISMATCHED_PAIR_ORDERS_ARRAY_LENGTHS"
        );

        if (!isValidOrderSigner(maker, msg.sender)) {
            LibNativeOrdersRichErrors.InvalidSignerError(
                maker,
                msg.sender
            ).rrevert();
        }

        for (uint256 i = 0; i < makerTokens.length; ++i) {
            _cancelPairRfqOrders(
                maker,
                makerTokens[i],
                takerTokens[i],
                minValidSalts[i]
            );
        }
    }

    
    
    
    function _cancelOrderHash(bytes32 orderHash, address maker)
        private
    {
        LibNativeOrdersStorage.Storage storage stor =
            LibNativeOrdersStorage.getStorage();
        // Set the high bit on the raw taker token fill amount to indicate
        // a cancel. It's OK to cancel twice.
        stor.orderHashToTakerTokenFilledAmount[orderHash] |= HIGH_BIT;

        emit OrderCancelled(orderHash, maker);
    }

    
    ///      than the value provided.
    
    
    
    
    function _cancelPairRfqOrders(
        address maker,
        IERC20TokenV06 makerToken,
        IERC20TokenV06 takerToken,
        uint256 minValidSalt
    )
        private
    {
        LibNativeOrdersStorage.Storage storage stor =
            LibNativeOrdersStorage.getStorage();

        uint256 oldMinValidSalt =
            stor.rfqOrdersMakerToMakerTokenToTakerTokenToMinValidOrderSalt
                [maker]
                [address(makerToken)]
                [address(takerToken)];

        // New min salt must >= the old one.
        if (oldMinValidSalt > minValidSalt) {
            LibNativeOrdersRichErrors.
                CancelSaltTooLowError(minValidSalt, oldMinValidSalt)
                    .rrevert();
        }

        stor.rfqOrdersMakerToMakerTokenToTakerTokenToMinValidOrderSalt
            [maker]
            [address(makerToken)]
            [address(takerToken)] = minValidSalt;

        emit PairCancelledRfqOrders(
            maker,
            address(makerToken),
            address(takerToken),
            minValidSalt
        );
    }

    
    ///      than the value provided.
    
    
    
    
    function _cancelPairLimitOrders(
        address maker,
        IERC20TokenV06 makerToken,
        IERC20TokenV06 takerToken,
        uint256 minValidSalt
    )
        private
    {
        LibNativeOrdersStorage.Storage storage stor =
            LibNativeOrdersStorage.getStorage();

        uint256 oldMinValidSalt =
            stor.limitOrdersMakerToMakerTokenToTakerTokenToMinValidOrderSalt
                [maker]
                [address(makerToken)]
                [address(takerToken)];

        // New min salt must >= the old one.
        if (oldMinValidSalt > minValidSalt) {
            LibNativeOrdersRichErrors.
                CancelSaltTooLowError(minValidSalt, oldMinValidSalt)
                    .rrevert();
        }

        stor.limitOrdersMakerToMakerTokenToTakerTokenToMinValidOrderSalt
            [maker]
            [address(makerToken)]
            [address(takerToken)] = minValidSalt;

        emit PairCancelledLimitOrders(
            maker,
            address(makerToken),
            address(takerToken),
            minValidSalt
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











abstract contract NativeOrdersProtocolFees is
    FixinProtocolFees
{
    using LibSafeMathV06 for uint256;
    using LibRichErrorsV06 for bytes;

    constructor(
        IEtherTokenV06 weth,
        IStaking staking,
        FeeCollectorController feeCollectorController,
        uint32 protocolFeeMultiplier
    )
        internal
        FixinProtocolFees(weth, staking, feeCollectorController, protocolFeeMultiplier)
    {
        // solhint-disable no-empty-blocks
    }

    
    ///      the staking contract.
    
    function transferProtocolFeesForPools(bytes32[] calldata poolIds)
        external
    {
        for (uint256 i = 0; i < poolIds.length; ++i) {
            _transferFeesForPool(poolIds[i]);
        }
    }

    
    ///      gas price to arrive at the required protocol fee to fill a native order.
    
    function getProtocolFeeMultiplier()
        external
        view
        returns (uint32 multiplier)
    {
        return PROTOCOL_FEE_MULTIPLIER;
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




interface IAuthorizableV06 is
    IOwnableV06
{
    // Event logged when a new address is authorized.
    event AuthorizedAddressAdded(
        address indexed target,
        address indexed caller
    );

    // Event logged when a currently authorized address is unauthorized.
    event AuthorizedAddressRemoved(
        address indexed target,
        address indexed caller
    );

    
    
    function addAuthorizedAddress(address target)
        external;

    
    
    function removeAuthorizedAddress(address target)
        external;

    
    
    
    function removeAuthorizedAddressAtIndex(
        address target,
        uint256 index
    )
        external;

    
    
    function getAuthorizedAddresses()
        external
        view
        returns (address[] memory authorizedAddresses);

    
    
    
    function authorized(address addr) external view returns (bool isAuthorized);

    
    
    
    function authorities(uint256 idx) external view returns (address addr);

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






contract OwnableV06 is
    IOwnableV06
{
    
    
    address public override owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        _assertSenderIsOwner();
        _;
    }

    
    
    function transferOwnership(address newOwner)
        public
        override
        onlyOwner
    {
        if (newOwner == address(0)) {
            LibRichErrorsV06.rrevert(LibOwnableRichErrorsV06.TransferOwnerToZeroError());
        } else {
            owner = newOwner;
            emit OwnershipTransferred(msg.sender, newOwner);
        }
    }

    function _assertSenderIsOwner()
        internal
        view
    {
        if (msg.sender != owner) {
            LibRichErrorsV06.rrevert(LibOwnableRichErrorsV06.OnlyOwnerError(
                msg.sender,
                owner
            ));
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




interface IFeature {

    // solhint-disable func-name-mixedcase

    
    function FEATURE_NAME() external view returns (string memory name);

    
    function FEATURE_VERSION() external view returns (uint256 version);
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
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    
    
    
    
    function transfer(address to, uint256 value)
        external
        returns (bool);

    
    
    
    
    
    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        external
        returns (bool);

    
    
    
    
    function approve(address spender, uint256 value)
        external
        returns (bool);

    
    
    function totalSupply()
        external
        view
        returns (uint256);

    
    
    
    function balanceOf(address owner)
        external
        view
        returns (uint256);

    
    
    
    
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    
    function decimals()
        external
        view
        returns (uint8);
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



















abstract contract NativeOrdersSettlement is
    INativeOrdersEvents,
    NativeOrdersCancellation,
    NativeOrdersProtocolFees,
    FixinCommon
{
    using LibSafeMathV06 for uint128;
    using LibRichErrorsV06 for bytes;

    
    struct SettleOrderInfo {
        // Order hash.
        bytes32 orderHash;
        // Maker of the order.
        address maker;
        // The address holding the taker tokens.
        address payer;
        // Recipient of the maker tokens.
        address recipient;
        // Maker token.
        IERC20TokenV06 makerToken;
        // Taker token.
        IERC20TokenV06 takerToken;
        // Maker token amount.
        uint128 makerAmount;
        // Taker token amount.
        uint128 takerAmount;
        // Maximum taker token amount to fill.
        uint128 takerTokenFillAmount;
        // How much taker token amount has already been filled in this order.
        uint128 takerTokenFilledAmount;
    }

    
    struct FillLimitOrderPrivateParams {
        // The limit order.
        LibNativeOrder.LimitOrder order;
        // The order signature.
        LibSignature.Signature signature;
        // Maximum taker token to fill this order with.
        uint128 takerTokenFillAmount;
        // The order taker.
        address taker;
        // The order sender.
        address sender;
    }

    
    struct FillRfqOrderPrivateParams {
        LibNativeOrder.RfqOrder order;
        // The order signature.
        LibSignature.Signature signature;
        // Maximum taker token to fill this order with.
        uint128 takerTokenFillAmount;
        // The order taker.
        address taker;
        // Whether to use the Exchange Proxy's balance
        // of taker tokens.
        bool useSelfBalance;
        // The recipient of the maker tokens.
        address recipient;
    }

    // @dev Fill results returned by `_fillLimitOrderPrivate()` and
    ///     `_fillRfqOrderPrivate()`.
    struct FillNativeOrderResults {
        uint256 ethProtocolFeePaid;
        uint128 takerTokenFilledAmount;
        uint128 makerTokenFilledAmount;
        uint128 takerTokenFeeFilledAmount;
    }

    constructor(
        address zeroExAddress,
        IEtherTokenV06 weth,
        IStaking staking,
        FeeCollectorController feeCollectorController,
        uint32 protocolFeeMultiplier
    )
        public
        NativeOrdersCancellation(zeroExAddress)
        NativeOrdersProtocolFees(weth, staking, feeCollectorController, protocolFeeMultiplier)
    {
        // solhint-disable no-empty-blocks
    }

    
    
    ///      attached to this call. Any unspent ETH will be refunded to
    ///      the caller.
    
    
    
    
    function fillLimitOrder(
        LibNativeOrder.LimitOrder memory order,
        LibSignature.Signature memory signature,
        uint128 takerTokenFillAmount
    )
        public
        payable
        returns (uint128 takerTokenFilledAmount, uint128 makerTokenFilledAmount)
    {
        FillNativeOrderResults memory results =
            _fillLimitOrderPrivate(FillLimitOrderPrivateParams({
                order: order,
                signature: signature,
                takerTokenFillAmount: takerTokenFillAmount,
                taker: msg.sender,
                sender: msg.sender
            }));
        LibNativeOrder.refundExcessProtocolFeeToSender(results.ethProtocolFeePaid);
        (takerTokenFilledAmount, makerTokenFilledAmount) = (
            results.takerTokenFilledAmount,
            results.makerTokenFilledAmount
        );
    }

    
    ///      The taker will be the caller. ETH should be attached to pay the
    ///      protocol fee.
    
    
    
    
    
    function fillRfqOrder(
        LibNativeOrder.RfqOrder memory order,
        LibSignature.Signature memory signature,
        uint128 takerTokenFillAmount
    )
        public
        returns (uint128 takerTokenFilledAmount, uint128 makerTokenFilledAmount)
    {
        FillNativeOrderResults memory results =
            _fillRfqOrderPrivate(FillRfqOrderPrivateParams({
                order: order,
                signature: signature,
                takerTokenFillAmount: takerTokenFillAmount,
                taker: msg.sender,
                useSelfBalance: false,
                recipient: msg.sender
            }));
        (takerTokenFilledAmount, makerTokenFilledAmount) = (
            results.takerTokenFilledAmount,
            results.makerTokenFilledAmount
        );
    }

    
    ///      The taker will be the caller. ETH protocol fees can be
    ///      attached to this call. Any unspent ETH will be refunded to
    ///      the caller.
    
    
    
    
    function fillOrKillLimitOrder(
        LibNativeOrder.LimitOrder memory order,
        LibSignature.Signature memory signature,
        uint128 takerTokenFillAmount
    )
        public
        payable
        returns (uint128 makerTokenFilledAmount)
    {
        FillNativeOrderResults memory results =
            _fillLimitOrderPrivate(FillLimitOrderPrivateParams({
                order: order,
                signature: signature,
                takerTokenFillAmount: takerTokenFillAmount,
                taker: msg.sender,
                sender: msg.sender
            }));
        // Must have filled exactly the amount requested.
        if (results.takerTokenFilledAmount < takerTokenFillAmount) {
            LibNativeOrdersRichErrors.FillOrKillFailedError(
                getLimitOrderHash(order),
                results.takerTokenFilledAmount,
                takerTokenFillAmount
            ).rrevert();
        }
        LibNativeOrder.refundExcessProtocolFeeToSender(results.ethProtocolFeePaid);
        makerTokenFilledAmount = results.makerTokenFilledAmount;
    }

    
    ///      The taker will be the caller. ETH protocol fees can be
    ///      attached to this call. Any unspent ETH will be refunded to
    ///      the caller.
    
    
    
    
    function fillOrKillRfqOrder(
        LibNativeOrder.RfqOrder memory order,
        LibSignature.Signature memory signature,
        uint128 takerTokenFillAmount
    )
        public
        returns (uint128 makerTokenFilledAmount)
    {
        FillNativeOrderResults memory results =
            _fillRfqOrderPrivate(FillRfqOrderPrivateParams({
                order: order,
                signature: signature,
                takerTokenFillAmount: takerTokenFillAmount,
                taker: msg.sender,
                useSelfBalance: false,
                recipient: msg.sender
            }));
        // Must have filled exactly the amount requested.
        if (results.takerTokenFilledAmount < takerTokenFillAmount) {
            LibNativeOrdersRichErrors.FillOrKillFailedError(
                getRfqOrderHash(order),
                results.takerTokenFilledAmount,
                takerTokenFillAmount
            ).rrevert();
        }
        makerTokenFilledAmount = results.makerTokenFilledAmount;
    }

    
    ///      attached to this call.
    
    
    
    
    
    
    
    function _fillLimitOrder(
        LibNativeOrder.LimitOrder memory order,
        LibSignature.Signature memory signature,
        uint128 takerTokenFillAmount,
        address taker,
        address sender
    )
        public
        virtual
        payable
        onlySelf
        returns (uint128 takerTokenFilledAmount, uint128 makerTokenFilledAmount)
    {
        FillNativeOrderResults memory results =
            _fillLimitOrderPrivate(FillLimitOrderPrivateParams(
                order,
                signature,
                takerTokenFillAmount,
                taker,
                sender
            ));
        (takerTokenFilledAmount, makerTokenFilledAmount) = (
            results.takerTokenFilledAmount,
            results.makerTokenFilledAmount
        );
    }

    
    
    
    
    
    
    ///        balance of taker tokens to fill the order.
    
    
    
    function _fillRfqOrder(
        LibNativeOrder.RfqOrder memory order,
        LibSignature.Signature memory signature,
        uint128 takerTokenFillAmount,
        address taker,
        bool useSelfBalance,
        address recipient
    )
        public
        virtual
        onlySelf
        returns (uint128 takerTokenFilledAmount, uint128 makerTokenFilledAmount)
    {
        FillNativeOrderResults memory results =
            _fillRfqOrderPrivate(FillRfqOrderPrivateParams(
                order,
                signature,
                takerTokenFillAmount,
                taker,
                useSelfBalance,
                recipient
            ));
        (takerTokenFilledAmount, makerTokenFilledAmount) = (
            results.takerTokenFilledAmount,
            results.makerTokenFilledAmount
        );
    }

    
    ///      specifies the message sender as its txOrigin.
    
    
    function registerAllowedRfqOrigins(
        address[] memory origins,
        bool allowed
    )
        external
    {
        require(msg.sender == tx.origin,
            "NativeOrdersFeature/NO_CONTRACT_ORIGINS");

        LibNativeOrdersStorage.Storage storage stor =
            LibNativeOrdersStorage.getStorage();

        for (uint256 i = 0; i < origins.length; i++) {
            stor.originRegistry[msg.sender][origins[i]] = allowed;
        }

        emit RfqOrderOriginsAllowed(msg.sender, origins, allowed);
    }

    
    
    
    function _fillLimitOrderPrivate(FillLimitOrderPrivateParams memory params)
        private
        returns (FillNativeOrderResults memory results)
    {
        LibNativeOrder.OrderInfo memory orderInfo = getLimitOrderInfo(params.order);

        // Must be fillable.
        if (orderInfo.status != LibNativeOrder.OrderStatus.FILLABLE) {
            LibNativeOrdersRichErrors.OrderNotFillableError(
                orderInfo.orderHash,
                uint8(orderInfo.status)
            ).rrevert();
        }

        // Must be fillable by the taker.
        if (params.order.taker != address(0) && params.order.taker != params.taker) {
            LibNativeOrdersRichErrors.OrderNotFillableByTakerError(
                orderInfo.orderHash,
                params.taker,
                params.order.taker
            ).rrevert();
        }

        // Must be fillable by the sender.
        if (params.order.sender != address(0) && params.order.sender != params.sender) {
            LibNativeOrdersRichErrors.OrderNotFillableBySenderError(
                orderInfo.orderHash,
                params.sender,
                params.order.sender
            ).rrevert();
        }

        // Signature must be valid for the order.
        {
            address signer = LibSignature.getSignerOfHash(
                orderInfo.orderHash,
                params.signature
            );
            if (signer != params.order.maker && !isValidOrderSigner(params.order.maker, signer)) {
                LibNativeOrdersRichErrors.OrderNotSignedByMakerError(
                    orderInfo.orderHash,
                    signer,
                    params.order.maker
                ).rrevert();
            }
        }

        // Pay the protocol fee.
        results.ethProtocolFeePaid = _collectProtocolFee(params.order.pool);

        // Settle between the maker and taker.
        (results.takerTokenFilledAmount, results.makerTokenFilledAmount) = _settleOrder(
            SettleOrderInfo({
                orderHash: orderInfo.orderHash,
                maker: params.order.maker,
                payer: params.taker,
                recipient: params.taker,
                makerToken: IERC20TokenV06(params.order.makerToken),
                takerToken: IERC20TokenV06(params.order.takerToken),
                makerAmount: params.order.makerAmount,
                takerAmount: params.order.takerAmount,
                takerTokenFillAmount: params.takerTokenFillAmount,
                takerTokenFilledAmount: orderInfo.takerTokenFilledAmount
            })
        );

        // Pay the fee recipient.
        if (params.order.takerTokenFeeAmount > 0) {
            results.takerTokenFeeFilledAmount = uint128(LibMathV06.getPartialAmountFloor(
                results.takerTokenFilledAmount,
                params.order.takerAmount,
                params.order.takerTokenFeeAmount
            ));
            _transferERC20TokensFrom(
                params.order.takerToken,
                params.taker,
                params.order.feeRecipient,
                uint256(results.takerTokenFeeFilledAmount)
            );
        }

        emit LimitOrderFilled(
            orderInfo.orderHash,
            params.order.maker,
            params.taker,
            params.order.feeRecipient,
            address(params.order.makerToken),
            address(params.order.takerToken),
            results.takerTokenFilledAmount,
            results.makerTokenFilledAmount,
            results.takerTokenFeeFilledAmount,
            results.ethProtocolFeePaid,
            params.order.pool
        );
    }

    
    
    
    function _fillRfqOrderPrivate(FillRfqOrderPrivateParams memory params)
        private
        returns (FillNativeOrderResults memory results)
    {
        LibNativeOrder.OrderInfo memory orderInfo = getRfqOrderInfo(params.order);

        // Must be fillable.
        if (orderInfo.status != LibNativeOrder.OrderStatus.FILLABLE) {
            LibNativeOrdersRichErrors.OrderNotFillableError(
                orderInfo.orderHash,
                uint8(orderInfo.status)
            ).rrevert();
        }

        {
            LibNativeOrdersStorage.Storage storage stor =
                LibNativeOrdersStorage.getStorage();

            // Must be fillable by the tx.origin.
            if (
                params.order.txOrigin != tx.origin &&
                !stor.originRegistry[params.order.txOrigin][tx.origin]
            ) {
                LibNativeOrdersRichErrors.OrderNotFillableByOriginError(
                    orderInfo.orderHash,
                    tx.origin,
                    params.order.txOrigin
                ).rrevert();
            }
        }

        // Must be fillable by the taker.
        if (params.order.taker != address(0) && params.order.taker != params.taker) {
            LibNativeOrdersRichErrors.OrderNotFillableByTakerError(
                orderInfo.orderHash,
                params.taker,
                params.order.taker
            ).rrevert();
        }

        // Signature must be valid for the order.
        {
            address signer = LibSignature.getSignerOfHash(
                orderInfo.orderHash,
                params.signature
            );
            if (
                signer != params.order.maker &&
                !isValidOrderSigner(params.order.maker, signer)
            ) {
                LibNativeOrdersRichErrors.OrderNotSignedByMakerError(
                    orderInfo.orderHash,
                    signer,
                    params.order.maker
                ).rrevert();
            }
        }

        // Settle between the maker and taker.
        (results.takerTokenFilledAmount, results.makerTokenFilledAmount) = _settleOrder(
            SettleOrderInfo({
                orderHash: orderInfo.orderHash,
                maker: params.order.maker,
                payer: params.useSelfBalance ? address(this) : params.taker,
                recipient: params.recipient,
                makerToken: IERC20TokenV06(params.order.makerToken),
                takerToken: IERC20TokenV06(params.order.takerToken),
                makerAmount: params.order.makerAmount,
                takerAmount: params.order.takerAmount,
                takerTokenFillAmount: params.takerTokenFillAmount,
                takerTokenFilledAmount: orderInfo.takerTokenFilledAmount
            })
        );

        emit RfqOrderFilled(
            orderInfo.orderHash,
            params.order.maker,
            params.taker,
            address(params.order.makerToken),
            address(params.order.takerToken),
            results.takerTokenFilledAmount,
            results.makerTokenFilledAmount,
            params.order.pool
        );
    }

    
    
    
    
    function _settleOrder(SettleOrderInfo memory settleInfo)
        private
        returns (uint128 takerTokenFilledAmount, uint128 makerTokenFilledAmount)
    {
        // Clamp the taker token fill amount to the fillable amount.
        takerTokenFilledAmount = LibSafeMathV06.min128(
            settleInfo.takerTokenFillAmount,
            settleInfo.takerAmount.safeSub128(settleInfo.takerTokenFilledAmount)
        );
        // Compute the maker token amount.
        // This should never overflow because the values are all clamped to
        // (2^128-1).
        makerTokenFilledAmount = uint128(LibMathV06.getPartialAmountFloor(
            uint256(takerTokenFilledAmount),
            uint256(settleInfo.takerAmount),
            uint256(settleInfo.makerAmount)
        ));

        if (takerTokenFilledAmount == 0 || makerTokenFilledAmount == 0) {
            // Nothing to do.
            return (0, 0);
        }

        // Update filled state for the order.
        LibNativeOrdersStorage
            .getStorage()
            .orderHashToTakerTokenFilledAmount[settleInfo.orderHash] =
            // OK to overwrite the whole word because we shouldn't get to this
            // function if the order is cancelled.
                settleInfo.takerTokenFilledAmount.safeAdd128(takerTokenFilledAmount);

        if (settleInfo.payer == address(this)) {
            // Transfer this -> maker.
            _transferERC20Tokens(
                settleInfo.takerToken,
                settleInfo.maker,
                takerTokenFilledAmount
            );
        } else {
            // Transfer taker -> maker.
            _transferERC20TokensFrom(
                settleInfo.takerToken,
                settleInfo.payer,
                settleInfo.maker,
                takerTokenFilledAmount
            );
        }

        // Transfer maker -> recipient.
        _transferERC20TokensFrom(
            settleInfo.makerToken,
            settleInfo.maker,
            settleInfo.recipient,
            makerTokenFilledAmount
        );
    }

    
    
    
    function registerAllowedOrderSigner(
        address signer,
        bool allowed
    )
        external
    {
        LibNativeOrdersStorage.Storage storage stor =
            LibNativeOrdersStorage.getStorage();

        stor.orderSignerRegistry[msg.sender][signer] = allowed;

        emit OrderSignerRegistered(msg.sender, signer, allowed);
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
contract AuthorizableV06 is
    OwnableV06,
    IAuthorizableV06
{
    
    modifier onlyAuthorized {
        _assertSenderIsAuthorized();
        _;
    }

    // @dev Whether an address is authorized to call privileged functions.
    // @param 0 Address to query.
    // @return 0 Whether the address is authorized.
    mapping (address => bool) public override authorized;
    // @dev Whether an address is authorized to call privileged functions.
    // @param 0 Index of authorized address.
    // @return 0 Authorized address.
    address[] public override authorities;

    
    constructor()
        public
        OwnableV06()
    {}

    
    
    function addAuthorizedAddress(address target)
        external
        override
        onlyOwner
    {
        _addAuthorizedAddress(target);
    }

    
    
    function removeAuthorizedAddress(address target)
        external
        override
        onlyOwner
    {
        if (!authorized[target]) {
            LibRichErrorsV06.rrevert(LibAuthorizableRichErrorsV06.TargetNotAuthorizedError(target));
        }
        for (uint256 i = 0; i < authorities.length; i++) {
            if (authorities[i] == target) {
                _removeAuthorizedAddressAtIndex(target, i);
                break;
            }
        }
    }

    
    
    
    function removeAuthorizedAddressAtIndex(
        address target,
        uint256 index
    )
        external
        override
        onlyOwner
    {
        _removeAuthorizedAddressAtIndex(target, index);
    }

    
    
    function getAuthorizedAddresses()
        external
        override
        view
        returns (address[] memory)
    {
        return authorities;
    }

    
    function _assertSenderIsAuthorized()
        internal
        view
    {
        if (!authorized[msg.sender]) {
            LibRichErrorsV06.rrevert(LibAuthorizableRichErrorsV06.SenderNotAuthorizedError(msg.sender));
        }
    }

    
    
    function _addAuthorizedAddress(address target)
        internal
    {
        // Ensure that the target is not the zero address.
        if (target == address(0)) {
            LibRichErrorsV06.rrevert(LibAuthorizableRichErrorsV06.ZeroCantBeAuthorizedError());
        }

        // Ensure that the target is not already authorized.
        if (authorized[target]) {
            LibRichErrorsV06.rrevert(LibAuthorizableRichErrorsV06.TargetAlreadyAuthorizedError(target));
        }

        authorized[target] = true;
        authorities.push(target);
        emit AuthorizedAddressAdded(target, msg.sender);
    }

    
    
    
    function _removeAuthorizedAddressAtIndex(
        address target,
        uint256 index
    )
        internal
    {
        if (!authorized[target]) {
            LibRichErrorsV06.rrevert(LibAuthorizableRichErrorsV06.TargetNotAuthorizedError(target));
        }
        if (index >= authorities.length) {
            LibRichErrorsV06.rrevert(LibAuthorizableRichErrorsV06.IndexOutOfBoundsError(
                index,
                authorities.length
            ));
        }
        if (authorities[index] != target) {
            LibRichErrorsV06.rrevert(LibAuthorizableRichErrorsV06.AuthorizedAddressMismatchError(
                authorities[index],
                target
            ));
        }

        delete authorized[target];
        authorities[index] = authorities[authorities.length - 1];
        authorities.pop();
        emit AuthorizedAddressRemoved(target, msg.sender);
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









contract NativeOrdersFeature is
    IFeature,
    NativeOrdersSettlement
{
    
    string public constant override FEATURE_NAME = "LimitOrders";
    
    uint256 public immutable override FEATURE_VERSION = _encodeVersion(1, 3, 0);

    constructor(
        address zeroExAddress,
        IEtherTokenV06 weth,
        IStaking staking,
        FeeCollectorController feeCollectorController,
        uint32 protocolFeeMultiplier
    )
        public
        NativeOrdersSettlement(
            zeroExAddress,
            weth,
            staking,
            feeCollectorController,
            protocolFeeMultiplier
        )
    {
        // solhint-disable no-empty-blocks
    }

    
    ///      Should be delegatecalled by `Migrate.migrate()`.
    
    function migrate()
        external
        returns (bytes4 success)
    {
        _registerFeatureFunction(this.transferProtocolFeesForPools.selector);
        _registerFeatureFunction(this.fillLimitOrder.selector);
        _registerFeatureFunction(this.fillRfqOrder.selector);
        _registerFeatureFunction(this.fillOrKillLimitOrder.selector);
        _registerFeatureFunction(this.fillOrKillRfqOrder.selector);
        _registerFeatureFunction(this._fillLimitOrder.selector);
        _registerFeatureFunction(this._fillRfqOrder.selector);
        _registerFeatureFunction(this.cancelLimitOrder.selector);
        _registerFeatureFunction(this.cancelRfqOrder.selector);
        _registerFeatureFunction(this.batchCancelLimitOrders.selector);
        _registerFeatureFunction(this.batchCancelRfqOrders.selector);
        _registerFeatureFunction(this.cancelPairLimitOrders.selector);
        _registerFeatureFunction(this.cancelPairLimitOrdersWithSigner.selector);
        _registerFeatureFunction(this.batchCancelPairLimitOrders.selector);
        _registerFeatureFunction(this.batchCancelPairLimitOrdersWithSigner.selector);
        _registerFeatureFunction(this.cancelPairRfqOrders.selector);
        _registerFeatureFunction(this.cancelPairRfqOrdersWithSigner.selector);
        _registerFeatureFunction(this.batchCancelPairRfqOrders.selector);
        _registerFeatureFunction(this.batchCancelPairRfqOrdersWithSigner.selector);
        _registerFeatureFunction(this.getLimitOrderInfo.selector);
        _registerFeatureFunction(this.getRfqOrderInfo.selector);
        _registerFeatureFunction(this.getLimitOrderHash.selector);
        _registerFeatureFunction(this.getRfqOrderHash.selector);
        _registerFeatureFunction(this.getProtocolFeeMultiplier.selector);
        _registerFeatureFunction(this.registerAllowedRfqOrigins.selector);
        _registerFeatureFunction(this.getLimitOrderRelevantState.selector);
        _registerFeatureFunction(this.getRfqOrderRelevantState.selector);
        _registerFeatureFunction(this.batchGetLimitOrderRelevantStates.selector);
        _registerFeatureFunction(this.batchGetRfqOrderRelevantStates.selector);
        _registerFeatureFunction(this.registerAllowedOrderSigner.selector);
        _registerFeatureFunction(this.isValidOrderSigner.selector);
        return LibMigrate.MIGRATE_SUCCESS;
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






library LibMigrate {

    
    ///      This is `keccack('MIGRATE_SUCCESS')`.
    bytes4 internal constant MIGRATE_SUCCESS = 0x2c64c5ef;

    using LibRichErrorsV06 for bytes;

    
    
    
    function delegatecallMigrateFunction(
        address target,
        bytes memory data
    )
        internal
    {
        (bool success, bytes memory resultData) = target.delegatecall(data);
        if (!success ||
            resultData.length != 32 ||
            abi.decode(resultData, (bytes4)) != MIGRATE_SUCCESS)
        {
            LibOwnableRichErrors.MigrateCallFailedError(target, resultData).rrevert();
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


library LibRichErrorsV06 {

    // bytes4(keccak256("Error(string)"))
    bytes4 internal constant STANDARD_ERROR_SELECTOR = 0x08c379a0;

    // solhint-disable func-name-mixedcase
    
    ///      This is the same payload that would be included by a `revert(string)`
    ///      solidity statement. It has the function signature `Error(string)`.
    
    
    function StandardError(string memory message)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            STANDARD_ERROR_SELECTOR,
            bytes(message)
        );
    }
    // solhint-enable func-name-mixedcase

    
    
    function rrevert(bytes memory errorData)
        internal
        pure
    {
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


library LibOwnableRichErrors {

    // solhint-disable func-name-mixedcase

    function OnlyOwnerError(
        address sender,
        address owner
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("OnlyOwnerError(address,address)")),
            sender,
            owner
        );
    }

    function TransferOwnerToZeroError()
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("TransferOwnerToZeroError()"))
        );
    }

    function MigrateCallFailedError(address target, bytes memory resultData)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("MigrateCallFailedError(address,bytes)")),
            target,
            resultData
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









interface INativeOrdersFeature is
    INativeOrdersEvents
{

    
    ///      the staking contract.
    
    function transferProtocolFeesForPools(bytes32[] calldata poolIds)
        external;

    
    
    ///      attached to this call. Any unspent ETH will be refunded to
    ///      the caller.
    
    
    
    
    function fillLimitOrder(
        LibNativeOrder.LimitOrder calldata order,
        LibSignature.Signature calldata signature,
        uint128 takerTokenFillAmount
    )
        external
        payable
        returns (uint128 takerTokenFilledAmount, uint128 makerTokenFilledAmount);

    
    ///      The taker will be the caller.
    
    
    
    
    
    function fillRfqOrder(
        LibNativeOrder.RfqOrder calldata order,
        LibSignature.Signature calldata signature,
        uint128 takerTokenFillAmount
    )
        external
        returns (uint128 takerTokenFilledAmount, uint128 makerTokenFilledAmount);

    
    ///      The taker will be the caller. ETH protocol fees can be
    ///      attached to this call. Any unspent ETH will be refunded to
    ///      the caller.
    
    
    
    
    function fillOrKillLimitOrder(
        LibNativeOrder.LimitOrder calldata order,
        LibSignature.Signature calldata signature,
        uint128 takerTokenFillAmount
    )
        external
        payable
        returns (uint128 makerTokenFilledAmount);

    
    ///      The taker will be the caller.
    
    
    
    
    function fillOrKillRfqOrder(
        LibNativeOrder.RfqOrder calldata order,
        LibSignature.Signature calldata signature,
        uint128 takerTokenFillAmount
    )
        external
        returns (uint128 makerTokenFilledAmount);

    
    ///      attached to this call. Any unspent ETH will be refunded to
    ///      `msg.sender` (not `sender`).
    
    
    
    
    
    
    
    function _fillLimitOrder(
        LibNativeOrder.LimitOrder calldata order,
        LibSignature.Signature calldata signature,
        uint128 takerTokenFillAmount,
        address taker,
        address sender
    )
        external
        payable
        returns (uint128 takerTokenFilledAmount, uint128 makerTokenFilledAmount);

    
    
    
    
    
    
    ///        balance of taker tokens to fill the order.
    
    
    
    function _fillRfqOrder(
        LibNativeOrder.RfqOrder calldata order,
        LibSignature.Signature calldata signature,
        uint128 takerTokenFillAmount,
        address taker,
        bool useSelfBalance,
        address recipient
    )
        external
        returns (uint128 takerTokenFilledAmount, uint128 makerTokenFilledAmount);

    
    ///      Silently succeeds if the order has already been cancelled.
    
    function cancelLimitOrder(LibNativeOrder.LimitOrder calldata order)
        external;

    
    ///      Silently succeeds if the order has already been cancelled.
    
    function cancelRfqOrder(LibNativeOrder.RfqOrder calldata order)
        external;

    
    ///      specifies the message sender as its txOrigin.
    
    
    function registerAllowedRfqOrigins(address[] memory origins, bool allowed)
        external;

    
    ///      Silently succeeds if the order has already been cancelled.
    
    function batchCancelLimitOrders(LibNativeOrder.LimitOrder[] calldata orders)
        external;

    
    ///      Silently succeeds if the order has already been cancelled.
    
    function batchCancelRfqOrders(LibNativeOrder.RfqOrder[] calldata orders)
        external;

    
    ///      than the value provided. The caller must be the maker. Subsequent
    ///      calls to this function with the same caller and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    function cancelPairLimitOrders(
        IERC20TokenV06 makerToken,
        IERC20TokenV06 takerToken,
        uint256 minValidSalt
    )
        external;

    
    ///      than the value provided. The caller must be a signer registered to the maker.
    ///      Subsequent calls to this function with the same maker and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    
    function cancelPairLimitOrdersWithSigner(
        address maker,
        IERC20TokenV06 makerToken,
        IERC20TokenV06 takerToken,
        uint256 minValidSalt
    )
        external;

    
    ///      than the values provided. The caller must be the maker. Subsequent
    ///      calls to this function with the same caller and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    function batchCancelPairLimitOrders(
        IERC20TokenV06[] calldata makerTokens,
        IERC20TokenV06[] calldata takerTokens,
        uint256[] calldata minValidSalts
    )
        external;

    
    ///      than the values provided. The caller must be a signer registered to the maker.
    ///      Subsequent calls to this function with the same maker and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    
    function batchCancelPairLimitOrdersWithSigner(
        address maker,
        IERC20TokenV06[] memory makerTokens,
        IERC20TokenV06[] memory takerTokens,
        uint256[] memory minValidSalts
    )
        external;

    
    ///      than the value provided. The caller must be the maker. Subsequent
    ///      calls to this function with the same caller and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    function cancelPairRfqOrders(
        IERC20TokenV06 makerToken,
        IERC20TokenV06 takerToken,
        uint256 minValidSalt
    )
        external;

    
    ///      than the value provided. The caller must be a signer registered to the maker.
    ///      Subsequent calls to this function with the same maker and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    
    function cancelPairRfqOrdersWithSigner(
        address maker,
        IERC20TokenV06 makerToken,
        IERC20TokenV06 takerToken,
        uint256 minValidSalt
    )
        external;

    
    ///      than the values provided. The caller must be the maker. Subsequent
    ///      calls to this function with the same caller and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    function batchCancelPairRfqOrders(
        IERC20TokenV06[] calldata makerTokens,
        IERC20TokenV06[] calldata takerTokens,
        uint256[] calldata minValidSalts
    )
        external;

    
    ///      than the values provided. The caller must be a signer registered to the maker.
    ///      Subsequent calls to this function with the same maker and pair require the
    ///      new salt to be >= the old salt.
    
    
    
    
    function batchCancelPairRfqOrdersWithSigner(
        address maker,
        IERC20TokenV06[] memory makerTokens,
        IERC20TokenV06[] memory takerTokens,
        uint256[] memory minValidSalts
    )
        external;

    
    
    
    function getLimitOrderInfo(LibNativeOrder.LimitOrder calldata order)
        external
        view
        returns (LibNativeOrder.OrderInfo memory orderInfo);

    
    
    
    function getRfqOrderInfo(LibNativeOrder.RfqOrder calldata order)
        external
        view
        returns (LibNativeOrder.OrderInfo memory orderInfo);

    
    
    
    function getLimitOrderHash(LibNativeOrder.LimitOrder calldata order)
        external
        view
        returns (bytes32 orderHash);

    
    
    
    function getRfqOrderHash(LibNativeOrder.RfqOrder calldata order)
        external
        view
        returns (bytes32 orderHash);

    
    ///      gas price to arrive at the required protocol fee to fill a native order.
    
    function getProtocolFeeMultiplier()
        external
        view
        returns (uint32 multiplier);

    
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
    
    function getRfqOrderRelevantState(
        LibNativeOrder.RfqOrder calldata order,
        LibSignature.Signature calldata signature
    )
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
    
    
    function registerAllowedOrderSigner(
        address signer,
        bool allowed
    )
        external;

    
    
    
    function isValidOrderSigner(
        address maker,
        address signer
    )
        external
        view
        returns (bool isAllowed);
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
    uint256 private constant ETH_SIGN_HASH_PREFIX =
        0x19457468657265756d205369676e6564204d6573736167653a0a333200000000;
    
    ///      The valid range is given by fig (282) of the yellow paper.
    uint256 private constant ECDSA_SIGNATURE_R_LIMIT =
        uint256(0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141);
    
    ///      The valid range is given by fig (283) of the yellow paper.
    uint256 private constant ECDSA_SIGNATURE_S_LIMIT = ECDSA_SIGNATURE_R_LIMIT / 2 + 1;

    
    enum SignatureType {
        ILLEGAL,
        INVALID,
        EIP712,
        ETHSIGN
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
    
    
    
    function getSignerOfHash(
        bytes32 hash,
        Signature memory signature
    )
        internal
        pure
        returns (address recovered)
    {
        // Ensure this is a signature type that can be validated against a hash.
        _validateHashCompatibleSignature(hash, signature);

        if (signature.signatureType == SignatureType.EIP712) {
            // Signed using EIP712
            recovered = ecrecover(
                hash,
                signature.v,
                signature.r,
                signature.s
            );
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
            recovered = ecrecover(
                ethSignHash,
                signature.v,
                signature.r,
                signature.s
            );
        }
        // `recovered` can be null if the signature values are out of range.
        if (recovered == address(0)) {
            LibSignatureRichErrors.SignatureValidationError(
                LibSignatureRichErrors.SignatureValidationErrorCodes.BAD_SIGNATURE_DATA,
                hash
            ).rrevert();
        }
    }

    
    
    
    function _validateHashCompatibleSignature(
        bytes32 hash,
        Signature memory signature
    )
        private
        pure
    {
        // Ensure the r and s are within malleability limits.
        if (uint256(signature.r) >= ECDSA_SIGNATURE_R_LIMIT ||
            uint256(signature.s) >= ECDSA_SIGNATURE_S_LIMIT)
        {
            LibSignatureRichErrors.SignatureValidationError(
                LibSignatureRichErrors.SignatureValidationErrorCodes.BAD_SIGNATURE_DATA,
                hash
            ).rrevert();
        }

        // Always illegal signature.
        if (signature.signatureType == SignatureType.ILLEGAL) {
            LibSignatureRichErrors.SignatureValidationError(
                LibSignatureRichErrors.SignatureValidationErrorCodes.ILLEGAL,
                hash
            ).rrevert();
        }

        // Always invalid.
        if (signature.signatureType == SignatureType.INVALID) {
            LibSignatureRichErrors.SignatureValidationError(
                LibSignatureRichErrors.SignatureValidationErrorCodes.ALWAYS_INVALID,
                hash
            ).rrevert();
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
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("SignatureValidationError(uint8,bytes32,address,bytes)")),
            code,
            hash,
            signerAddress,
            signature
        );
    }

    function SignatureValidationError(
        SignatureValidationErrorCodes code,
        bytes32 hash
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("SignatureValidationError(uint8,bytes32)")),
            code,
            hash
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
    uint256 private constant _LIMIT_ORDER_TYPEHASH =
        0xce918627cb55462ddbb85e73de69a8b322f2bc88f4507c52fcad6d4c33c29d49;

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
    uint256 private constant _RFQ_ORDER_TYPEHASH =
        0xe593d3fdfa8b60e5e17a1b2204662ecbe15c23f2084b9ad5bae40359540a7da9;

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
    uint256 private constant _OTC_ORDER_TYPEHASH =
        0x2f754524de756ae72459efbe1ec88c19a745639821de528ac3fb88f9e65e35c8;

    
    
    
    function getLimitOrderStructHash(LimitOrder memory order)
        internal
        pure
        returns (bytes32 structHash)
    {
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

    
    
    
    function getRfqOrderStructHash(RfqOrder memory order)
        internal
        pure
        returns (bytes32 structHash)
    {
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

    
    
    
    function getOtcOrderStructHash(OtcOrder memory order)
        internal
        pure
        returns (bytes32 structHash)
    {
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

    
    
    function refundExcessProtocolFeeToSender(uint256 ethProtocolFeePaid)
        internal
    {
        if (msg.value > ethProtocolFeePaid && msg.sender != address(this)) {
            uint256 refundAmount = msg.value.safeSub(ethProtocolFeePaid);
            (bool success,) = msg
                .sender
                .call{value: refundAmount}("");
            if (!success) {
                LibNativeOrdersRichErrors.ProtocolFeeRefundFailed(
                    msg.sender,
                    refundAmount
                ).rrevert();
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





library LibSafeMathV06 {

    function safeMul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        if (c / a != b) {
            LibRichErrorsV06.rrevert(LibSafeMathRichErrorsV06.Uint256BinOpError(
                LibSafeMathRichErrorsV06.BinOpErrorCodes.MULTIPLICATION_OVERFLOW,
                a,
                b
            ));
        }
        return c;
    }

    function safeDiv(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        if (b == 0) {
            LibRichErrorsV06.rrevert(LibSafeMathRichErrorsV06.Uint256BinOpError(
                LibSafeMathRichErrorsV06.BinOpErrorCodes.DIVISION_BY_ZERO,
                a,
                b
            ));
        }
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        if (b > a) {
            LibRichErrorsV06.rrevert(LibSafeMathRichErrorsV06.Uint256BinOpError(
                LibSafeMathRichErrorsV06.BinOpErrorCodes.SUBTRACTION_UNDERFLOW,
                a,
                b
            ));
        }
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = a + b;
        if (c < a) {
            LibRichErrorsV06.rrevert(LibSafeMathRichErrorsV06.Uint256BinOpError(
                LibSafeMathRichErrorsV06.BinOpErrorCodes.ADDITION_OVERFLOW,
                a,
                b
            ));
        }
        return c;
    }

    function max256(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a < b ? a : b;
    }

    function safeMul128(uint128 a, uint128 b)
        internal
        pure
        returns (uint128)
    {
        if (a == 0) {
            return 0;
        }
        uint128 c = a * b;
        if (c / a != b) {
            LibRichErrorsV06.rrevert(LibSafeMathRichErrorsV06.Uint256BinOpError(
                LibSafeMathRichErrorsV06.BinOpErrorCodes.MULTIPLICATION_OVERFLOW,
                a,
                b
            ));
        }
        return c;
    }

    function safeDiv128(uint128 a, uint128 b)
        internal
        pure
        returns (uint128)
    {
        if (b == 0) {
            LibRichErrorsV06.rrevert(LibSafeMathRichErrorsV06.Uint256BinOpError(
                LibSafeMathRichErrorsV06.BinOpErrorCodes.DIVISION_BY_ZERO,
                a,
                b
            ));
        }
        uint128 c = a / b;
        return c;
    }

    function safeSub128(uint128 a, uint128 b)
        internal
        pure
        returns (uint128)
    {
        if (b > a) {
            LibRichErrorsV06.rrevert(LibSafeMathRichErrorsV06.Uint256BinOpError(
                LibSafeMathRichErrorsV06.BinOpErrorCodes.SUBTRACTION_UNDERFLOW,
                a,
                b
            ));
        }
        return a - b;
    }

    function safeAdd128(uint128 a, uint128 b)
        internal
        pure
        returns (uint128)
    {
        uint128 c = a + b;
        if (c < a) {
            LibRichErrorsV06.rrevert(LibSafeMathRichErrorsV06.Uint256BinOpError(
                LibSafeMathRichErrorsV06.BinOpErrorCodes.ADDITION_OVERFLOW,
                a,
                b
            ));
        }
        return c;
    }

    function max128(uint128 a, uint128 b)
        internal
        pure
        returns (uint128)
    {
        return a >= b ? a : b;
    }

    function min128(uint128 a, uint128 b)
        internal
        pure
        returns (uint128)
    {
        return a < b ? a : b;
    }

    function safeDowncastToUint128(uint256 a)
        internal
        pure
        returns (uint128)
    {
        if (a > type(uint128).max) {
            LibRichErrorsV06.rrevert(LibSafeMathRichErrorsV06.Uint256DowncastError(
                LibSafeMathRichErrorsV06.DowncastErrorCodes.VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT128,
                a
            ));
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
    bytes4 internal constant UINT256_BINOP_ERROR_SELECTOR =
        0xe946c1bb;

    // bytes4(keccak256("Uint256DowncastError(uint8,uint256)"))
    bytes4 internal constant UINT256_DOWNCAST_ERROR_SELECTOR =
        0xc996af7b;

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
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            UINT256_BINOP_ERROR_SELECTOR,
            errorCode,
            a,
            b
        );
    }

    function Uint256DowncastError(
        DowncastErrorCodes errorCode,
        uint256 a
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            UINT256_DOWNCAST_ERROR_SELECTOR,
            errorCode,
            a
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


library LibNativeOrdersRichErrors {

    // solhint-disable func-name-mixedcase

    function ProtocolFeeRefundFailed(
        address receiver,
        uint256 refundAmount
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("ProtocolFeeRefundFailed(address,uint256)")),
            receiver,
            refundAmount
        );
    }

    function OrderNotFillableByOriginError(
        bytes32 orderHash,
        address txOrigin,
        address orderTxOrigin
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("OrderNotFillableByOriginError(bytes32,address,address)")),
            orderHash,
            txOrigin,
            orderTxOrigin
        );
    }

    function OrderNotFillableError(
        bytes32 orderHash,
        uint8 orderStatus
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("OrderNotFillableError(bytes32,uint8)")),
            orderHash,
            orderStatus
        );
    }

    function OrderNotSignedByMakerError(
        bytes32 orderHash,
        address signer,
        address maker
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("OrderNotSignedByMakerError(bytes32,address,address)")),
            orderHash,
            signer,
            maker
        );
    }

    function InvalidSignerError(
        address maker,
        address signer
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("InvalidSignerError(address,address)")),
            maker,
            signer
        );
    }

    function OrderNotFillableBySenderError(
        bytes32 orderHash,
        address sender,
        address orderSender
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
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
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("OrderNotFillableByTakerError(bytes32,address,address)")),
            orderHash,
            taker,
            orderTaker
        );
    }

    function CancelSaltTooLowError(
        uint256 minValidSalt,
        uint256 oldMinValidSalt
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("CancelSaltTooLowError(uint256,uint256)")),
            minValidSalt,
            oldMinValidSalt
        );
    }

    function FillOrKillFailedError(
        bytes32 orderHash,
        uint256 takerTokenFilledAmount,
        uint256 takerTokenFillAmount
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
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
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
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
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("BatchFillIncompleteError(bytes32,uint256,uint256)")),
            orderHash,
            takerTokenFilledAmount,
            takerTokenFillAmount
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




interface IEtherTokenV06 is
    IERC20TokenV06
{
    
    function deposit() external payable;

    
    function withdraw(uint256 amount) external;
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
    )
        internal
        pure
        returns (uint256 partialAmount)
    {
        if (isRoundingErrorFloor(
                numerator,
                denominator,
                target
        )) {
            LibRichErrorsV06.rrevert(LibMathRichErrorsV06.RoundingError(
                numerator,
                denominator,
                target
            ));
        }

        partialAmount = numerator.safeMul(target).safeDiv(denominator);
        return partialAmount;
    }

    
    ///      Reverts if rounding error is >= 0.1%
    
    
    
    
    function safeGetPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {
        if (isRoundingErrorCeil(
                numerator,
                denominator,
                target
        )) {
            LibRichErrorsV06.rrevert(LibMathRichErrorsV06.RoundingError(
                numerator,
                denominator,
                target
            ));
        }

        // safeDiv computes `floor(a / b)`. We use the identity (a, b integer):
        //       ceil(a / b) = floor((a + b - 1) / b)
        // To implement `ceil(a / b)` using safeDiv.
        partialAmount = numerator.safeMul(target)
            .safeAdd(denominator.safeSub(1))
            .safeDiv(denominator);

        return partialAmount;
    }

    
    
    
    
    
    function getPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {
        partialAmount = numerator.safeMul(target).safeDiv(denominator);
        return partialAmount;
    }

    
    
    
    
    
    function getPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {
        // safeDiv computes `floor(a / b)`. We use the identity (a, b integer):
        //       ceil(a / b) = floor((a + b - 1) / b)
        // To implement `ceil(a / b)` using safeDiv.
        partialAmount = numerator.safeMul(target)
            .safeAdd(denominator.safeSub(1))
            .safeDiv(denominator);

        return partialAmount;
    }

    
    
    
    
    
    function isRoundingErrorFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bool isError)
    {
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
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        isError = remainder.safeMul(1000) >= numerator.safeMul(target);
        return isError;
    }

    
    
    
    
    
    function isRoundingErrorCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bool isError)
    {
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
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
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
    bytes internal constant DIVISION_BY_ZERO_ERROR =
        hex"a791837c";

    // bytes4(keccak256("RoundingError(uint256,uint256,uint256)"))
    bytes4 internal constant ROUNDING_ERROR_SELECTOR =
        0x339f3de2;

    // solhint-disable func-name-mixedcase
    function DivisionByZeroError()
        internal
        pure
        returns (bytes memory)
    {
        return DIVISION_BY_ZERO_ERROR;
    }

    function RoundingError(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            ROUNDING_ERROR_SELECTOR,
            numerator,
            denominator,
            target
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


library LibCommonRichErrors {

    // solhint-disable func-name-mixedcase

    function OnlyCallableBySelfError(address sender)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("OnlyCallableBySelfError(address)")),
            sender
        );
    }

    function IllegalReentrancyError(bytes4 selector, uint256 reentrancyFlags)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("IllegalReentrancyError(bytes4,uint256)")),
            selector,
            reentrancyFlags
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





// solhint-disable no-empty-blocks

interface IOwnableFeature is
    IOwnableV06
{
    
    
    
    
    event Migrated(address caller, address migrator, address newOwner);

    
    ///      The result of the function being called should be the magic bytes
    ///      0x2c64c5ef (`keccack('MIGRATE_SUCCESS')`). Only callable by the owner.
    ///      The owner will be temporarily set to `address(this)` inside the call.
    ///      Before returning, the owner will be set to `newOwner`.
    
    
    
    function migrate(address target, bytes calldata data, address newOwner) external;
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
    function getRollbackLength(bytes4 selector)
        external
        view
        returns (uint256 rollbackLength);

    
    
    
    
    ///         index `idx`.
    function getRollbackEntryAtIndex(bytes4 selector, uint256 idx)
        external
        view
        returns (address impl);
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






library LibNativeOrdersStorage {

    
    struct Storage {
        // How much taker token has been filled in order.
        // The lower `uint128` is the taker token fill amount.
        // The high bit will be `1` if the order was directly cancelled.
        mapping(bytes32 => uint256) orderHashToTakerTokenFilledAmount;
        // The minimum valid order salt for a given maker and order pair (maker, taker)
        // for limit orders.
        mapping(address => mapping(address => mapping(address => uint256)))
            limitOrdersMakerToMakerTokenToTakerTokenToMinValidOrderSalt;
        // The minimum valid order salt for a given maker and order pair (maker, taker)
        // for RFQ orders.
        mapping(address => mapping(address => mapping(address => uint256)))
            rfqOrdersMakerToMakerTokenToTakerTokenToMinValidOrderSalt;
        // For a given order origin, which tx.origin addresses are allowed to
        // fill the order.
        mapping(address => mapping(address => bool)) originRegistry;
        // For a given maker address, which addresses are allowed to
        // sign on its behalf.
        mapping(address => mapping(address => bool)) orderSignerRegistry;
    }

    
    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.NativeOrders
        );
        // Dip into assembly to change the slot pointed to by the local
        // variable `stor`.
        // See https://solidity.readthedocs.io/en/v0.6.8/assembly.html?highlight=slot#access-to-external-variables-functions-and-libraries
        assembly { stor_slot := storageSlot }
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




library LibStorage {

    
    ///      This gives us a maximum of 2**128 inline fields in each bucket.
    uint256 private constant STORAGE_SLOT_EXP = 128;

    
    ///      WARNING: APPEND-ONLY.
    enum StorageId {
        Proxy,
        SimpleFunctionRegistry,
        Ownable,
        TokenSpender,
        TransformERC20,
        MetaTransactions,
        ReentrancyGuard,
        NativeOrders,
        OtcOrders
    }

    
    ///     slots to storage bucket variables to ensure they do not overlap.
    ///     See: https://solidity.readthedocs.io/en/v0.6.6/assembly.html#access-to-external-variables-functions-and-libraries
    
    
    function getStorageSlot(StorageId storageId)
        internal
        pure
        returns (uint256 slot)
    {
        // This should never overflow with a reasonable `STORAGE_SLOT_EXP`
        // because Solidity will do a range check on `storageId` during the cast.
        return (uint256(storageId) + 1) << STORAGE_SLOT_EXP;
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

interface IStaking {
    function joinStakingPoolAsMaker(bytes32) external;
    function payProtocolFee(address, address, uint256) external payable;
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







contract FeeCollector is AuthorizableV06 {
    
    receive() external payable { }

    constructor() public {
        _addAuthorizedAddress(msg.sender);
    }

    
    ///        can call this.
    
    
    
    function initialize(
        IEtherTokenV06 weth,
        IStaking staking,
        bytes32 poolId
    )
        external
        onlyAuthorized
    {
        weth.approve(address(staking), type(uint256).max);
        staking.joinStakingPoolAsMaker(poolId);
    }

    
    
    function convertToWeth(
        IEtherTokenV06 weth
    )
        external
        onlyAuthorized
    {
        if (address(this).balance > 0) {
            weth.deposit{value: address(this).balance}();
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


library LibAuthorizableRichErrorsV06 {

    // bytes4(keccak256("AuthorizedAddressMismatchError(address,address)"))
    bytes4 internal constant AUTHORIZED_ADDRESS_MISMATCH_ERROR_SELECTOR =
        0x140a84db;

    // bytes4(keccak256("IndexOutOfBoundsError(uint256,uint256)"))
    bytes4 internal constant INDEX_OUT_OF_BOUNDS_ERROR_SELECTOR =
        0xe9f83771;

    // bytes4(keccak256("SenderNotAuthorizedError(address)"))
    bytes4 internal constant SENDER_NOT_AUTHORIZED_ERROR_SELECTOR =
        0xb65a25b9;

    // bytes4(keccak256("TargetAlreadyAuthorizedError(address)"))
    bytes4 internal constant TARGET_ALREADY_AUTHORIZED_ERROR_SELECTOR =
        0xde16f1a0;

    // bytes4(keccak256("TargetNotAuthorizedError(address)"))
    bytes4 internal constant TARGET_NOT_AUTHORIZED_ERROR_SELECTOR =
        0xeb5108a2;

    // bytes4(keccak256("ZeroCantBeAuthorizedError()"))
    bytes internal constant ZERO_CANT_BE_AUTHORIZED_ERROR_BYTES =
        hex"57654fe4";

    // solhint-disable func-name-mixedcase
    function AuthorizedAddressMismatchError(
        address authorized,
        address target
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            AUTHORIZED_ADDRESS_MISMATCH_ERROR_SELECTOR,
            authorized,
            target
        );
    }

    function IndexOutOfBoundsError(
        uint256 index,
        uint256 length
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            INDEX_OUT_OF_BOUNDS_ERROR_SELECTOR,
            index,
            length
        );
    }

    function SenderNotAuthorizedError(address sender)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            SENDER_NOT_AUTHORIZED_ERROR_SELECTOR,
            sender
        );
    }

    function TargetAlreadyAuthorizedError(address target)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            TARGET_ALREADY_AUTHORIZED_ERROR_SELECTOR,
            target
        );
    }

    function TargetNotAuthorizedError(address target)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            TARGET_NOT_AUTHORIZED_ERROR_SELECTOR,
            target
        );
    }

    function ZeroCantBeAuthorizedError()
        internal
        pure
        returns (bytes memory)
    {
        return ZERO_CANT_BE_AUTHORIZED_ERROR_BYTES;
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


library LibOwnableRichErrorsV06 {

    // bytes4(keccak256("OnlyOwnerError(address,address)"))
    bytes4 internal constant ONLY_OWNER_ERROR_SELECTOR =
        0x1de45ad1;

    // bytes4(keccak256("TransferOwnerToZeroError()"))
    bytes internal constant TRANSFER_OWNER_TO_ZERO_ERROR_BYTES =
        hex"e69edc3e";

    // solhint-disable func-name-mixedcase
    function OnlyOwnerError(
        address sender,
        address owner
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            ONLY_OWNER_ERROR_SELECTOR,
            sender,
            owner
        );
    }

    function TransferOwnerToZeroError()
        internal
        pure
        returns (bytes memory)
    {
        return TRANSFER_OWNER_TO_ZERO_ERROR_BYTES;
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









contract FeeCollectorController {

    
    bytes32 public immutable FEE_COLLECTOR_INIT_CODE_HASH;
    
    IEtherTokenV06 private immutable WETH;
    
    IStaking private immutable STAKING;

    constructor(
        IEtherTokenV06 weth,
        IStaking staking
    )
        public
    {
        FEE_COLLECTOR_INIT_CODE_HASH = keccak256(type(FeeCollector).creationCode);
        WETH = weth;
        STAKING = staking;
    }

    
    ///      and wrap its ETH into WETH. Anyone may call this.
    
    
    function prepareFeeCollectorToPayFees(bytes32 poolId)
        external
        returns (FeeCollector feeCollector)
    {
        feeCollector = getFeeCollector(poolId);
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(feeCollector)
        }

        if (codeSize == 0) {
            // Create and initialize the contract if necessary.
            new FeeCollector{salt: bytes32(poolId)}();
            feeCollector.initialize(WETH, STAKING, poolId);
        }

        if (address(feeCollector).balance > 1) {
            feeCollector.convertToWeth(WETH);
        }

        return feeCollector;
    }

    
    ///      will not actually exist until `prepareFeeCollectorToPayFees()`
    ///      has been called once.
    
    
    function getFeeCollector(bytes32 poolId)
        public
        view
        returns (FeeCollector feeCollector)
    {
        return FeeCollector(LibFeeCollector.getFeeCollectorAddress(
            address(this),
            FEE_COLLECTOR_INIT_CODE_HASH,
            poolId
        ));
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




library LibFeeCollector {

    
    
    
    
    function getFeeCollectorAddress(address controller, bytes32 initCodeHash, bytes32 poolId)
        internal
        pure
        returns (address payable feeCollectorAddress)
    {
        // Compute the CREATE2 address for the fee collector.
        return address(uint256(keccak256(abi.encodePacked(
            byte(0xff),
            controller,
            poolId, // pool ID is salt
            initCodeHash
        ))));
    }
}
