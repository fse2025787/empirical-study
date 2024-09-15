pragma experimental ABIEncoderV2;


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

pragma solidity ^0.5.9;





contract ReentrancyGuard {

    // Locked state of mutex.
    bool private _locked = false;

    
    ///      before function execution and unlocked after.
    modifier nonReentrant() {
        _lockMutexOrThrowIfAlreadyLocked();
        _;
        _unlockMutex();
    }

    function _lockMutexOrThrowIfAlreadyLocked()
        internal
    {
        // Ensure mutex is unlocked.
        if (_locked) {
            LibRichErrors.rrevert(
                LibReentrancyGuardRichErrors.IllegalReentrancyError()
            );
        }
        // Lock mutex.
        _locked = true;
    }

    function _unlockMutex()
        internal
    {
        // Unlock mutex.
        _locked = false;
    }
}

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

pragma solidity ^0.5.9;




contract LibEIP712ExchangeDomain {

    // EIP712 Exchange Domain Name value
    string constant internal _EIP712_EXCHANGE_DOMAIN_NAME = "0x Protocol";

    // EIP712 Exchange Domain Version value
    string constant internal _EIP712_EXCHANGE_DOMAIN_VERSION = "3.0.0";

    // solhint-disable var-name-mixedcase
    
    
    bytes32 public EIP712_EXCHANGE_DOMAIN_HASH;
    // solhint-enable var-name-mixedcase

    
    
    constructor (
        uint256 chainId,
        address verifyingContractAddressIfExists
    )
        public
    {
        address verifyingContractAddress = verifyingContractAddressIfExists == address(0) ? address(this) : verifyingContractAddressIfExists;
        EIP712_EXCHANGE_DOMAIN_HASH = LibEIP712.hashEIP712Domain(
            _EIP712_EXCHANGE_DOMAIN_NAME,
            _EIP712_EXCHANGE_DOMAIN_VERSION,
            chainId,
            verifyingContractAddress
        );
    }
}

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

pragma solidity ^0.5.9;






contract ISignatureValidator {

   // Allowed signature types.
    enum SignatureType {
        Illegal,                     // 0x00, default value
        Invalid,                     // 0x01
        EIP712,                      // 0x02
        EthSign,                     // 0x03
        Wallet,                      // 0x04
        Validator,                   // 0x05
        PreSigned,                   // 0x06
        EIP1271Wallet,               // 0x07
        NSignatureTypes              // 0x08, number of signature types. Always leave at end.
    }

    event SignatureValidatorApproval(
        address indexed signerAddress,     // Address that approves or disapproves a contract to verify signatures.
        address indexed validatorAddress,  // Address of signature validator contract.
        bool isApproved                    // Approval or disapproval of validator contract.
    );

    
    ///      After presigning a hash, the preSign signature type will become valid for that hash and signer.
    
    function preSign(bytes32 hash)
        external
        payable;

    
    
    
    function setSignatureValidatorApproval(
        address validatorAddress,
        bool approval
    )
        external
        payable;

    
    
    
    
    function isValidHashSignature(
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        public
        view
        returns (bool isValid);

    
    
    
    
    function isValidOrderSignature(
        LibOrder.Order memory order,
        bytes memory signature
    )
        public
        view
        returns (bool isValid);

    
    
    
    
    function isValidTransactionSignature(
        LibZeroExTransaction.ZeroExTransaction memory transaction,
        bytes memory signature
    )
        public
        view
        returns (bool isValid);

    
    ///      by the given signer.
    
    
    
    
    function _isValidOrderWithHashSignature(
        LibOrder.Order memory order,
        bytes32 orderHash,
        bytes memory signature
    )
        internal
        view
        returns (bool isValid);

    
    ///      by the given signer.
    
    
    
    
    function _isValidTransactionWithHashSignature(
        LibZeroExTransaction.ZeroExTransaction memory transaction,
        bytes32 transactionHash,
        bytes memory signature
    )
        internal
        view
        returns (bool isValid);
}

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

pragma solidity ^0.5.9;




contract Refundable is
    ReentrancyGuard
{

    // This bool is used by the refund modifier to allow for lazily evaluated refunds.
    bool internal _shouldNotRefund;

    modifier refundFinalBalance {
        _;
        _refundNonZeroBalanceIfEnabled();
    }

    modifier refundFinalBalanceNoReentry {
        _lockMutexOrThrowIfAlreadyLocked();
        _;
        _refundNonZeroBalanceIfEnabled();
        _unlockMutex();
    }

    modifier disableRefundUntilEnd {
        if (_areRefundsDisabled()) {
            _;
        } else {
            _disableRefund();
            _;
            _enableAndRefundNonZeroBalance();
        }
    }

    function _refundNonZeroBalanceIfEnabled()
        internal
    {
        if (!_areRefundsDisabled()) {
            _refundNonZeroBalance();
        }
    }

    function _refundNonZeroBalance()
        internal
    {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            msg.sender.transfer(balance);
        }
    }

    function _disableRefund()
        internal
    {
        _shouldNotRefund = true;
    }

    function _enableAndRefundNonZeroBalance()
        internal
    {
        _shouldNotRefund = false;
        _refundNonZeroBalance();
    }

    function _areRefundsDisabled()
        internal
        view
        returns (bool)
    {
        return _shouldNotRefund;
    }
}

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

pragma solidity ^0.5.9;


contract IOwnable {

    
    
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    
    function transferOwnership(address newOwner)
        public;
}

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

pragma solidity ^0.5.9;






contract Ownable is
    IOwnable
{
    
    
    address public owner;

    constructor ()
        public
    {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        _assertSenderIsOwner();
        _;
    }

    
    
    function transferOwnership(address newOwner)
        public
        onlyOwner
    {
        if (newOwner == address(0)) {
            LibRichErrors.rrevert(LibOwnableRichErrors.TransferOwnerToZeroError());
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
            LibRichErrors.rrevert(LibOwnableRichErrors.OnlyOwnerError(
                msg.sender,
                owner
            ));
        }
    }
}

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

pragma solidity ^0.5.9;


contract IAssetProxyDispatcher {

    // Logs registration of new asset proxy
    event AssetProxyRegistered(
        bytes4 id,              // Id of new registered AssetProxy.
        address assetProxy      // Address of new registered AssetProxy.
    );

    
    ///      Once an asset proxy is registered, it cannot be unregistered.
    
    function registerAssetProxy(address assetProxy)
        external;

    
    
    
    function getAssetProxy(bytes4 assetProxyId)
        external
        view
        returns (address);
}

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

pragma solidity ^0.5.9;









contract MixinAssetProxyDispatcher is
    Ownable,
    IAssetProxyDispatcher
{
    using LibBytes for bytes;

    // Mapping from Asset Proxy Id's to their respective Asset Proxy
    mapping (bytes4 => address) internal _assetProxies;

    
    ///      Once an asset proxy is registered, it cannot be unregistered.
    
    function registerAssetProxy(address assetProxy)
        external
        onlyOwner
    {
        // Ensure that no asset proxy exists with current id.
        bytes4 assetProxyId = IAssetProxy(assetProxy).getProxyId();
        address currentAssetProxy = _assetProxies[assetProxyId];
        if (currentAssetProxy != address(0)) {
            LibRichErrors.rrevert(LibExchangeRichErrors.AssetProxyExistsError(
                assetProxyId,
                currentAssetProxy
            ));
        }

        // Add asset proxy and log registration.
        _assetProxies[assetProxyId] = assetProxy;
        emit AssetProxyRegistered(
            assetProxyId,
            assetProxy
        );
    }

    
    
    
    function getAssetProxy(bytes4 assetProxyId)
        external
        view
        returns (address assetProxy)
    {
        return _assetProxies[assetProxyId];
    }

    
    
    
    
    
    
    function _dispatchTransferFrom(
        bytes32 orderHash,
        bytes memory assetData,
        address from,
        address to,
        uint256 amount
    )
        internal
    {
        // Do nothing if no amount should be transferred.
        if (amount > 0) {

            // Ensure assetData is padded to 32 bytes (excluding the id) and is at least 4 bytes long
            if (assetData.length % 32 != 4) {
                LibRichErrors.rrevert(LibExchangeRichErrors.AssetProxyDispatchError(
                    LibExchangeRichErrors.AssetProxyDispatchErrorCodes.INVALID_ASSET_DATA_LENGTH,
                    orderHash,
                    assetData
                ));
            }

            // Lookup assetProxy.
            bytes4 assetProxyId = assetData.readBytes4(0);
            address assetProxy = _assetProxies[assetProxyId];

            // Ensure that assetProxy exists
            if (assetProxy == address(0)) {
                LibRichErrors.rrevert(LibExchangeRichErrors.AssetProxyDispatchError(
                    LibExchangeRichErrors.AssetProxyDispatchErrorCodes.UNKNOWN_ASSET_PROXY,
                    orderHash,
                    assetData
                ));
            }

            // Construct the calldata for the transferFrom call.
            bytes memory proxyCalldata = abi.encodeWithSelector(
                IAssetProxy(address(0)).transferFrom.selector,
                assetData,
                from,
                to,
                amount
            );

            // Call the asset proxy's transferFrom function with the constructed calldata.
            (bool didSucceed, bytes memory returnData) = assetProxy.call(proxyCalldata);

            // If the transaction did not succeed, revert with the returned data.
            if (!didSucceed) {
                LibRichErrors.rrevert(LibExchangeRichErrors.AssetProxyTransferError(
                    orderHash,
                    assetData,
                    returnData
                ));
            }
        }
    }
}

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

pragma solidity ^0.5.9;





contract ITransactions {

    // TransactionExecution event is emitted when a ZeroExTransaction is executed.
    event TransactionExecution(bytes32 indexed transactionHash);

    
    
    
    
    function executeTransaction(
        LibZeroExTransaction.ZeroExTransaction memory transaction,
        bytes memory signature
    )
        public
        payable
        returns (bytes memory);

    
    
    
    
    function batchExecuteTransactions(
        LibZeroExTransaction.ZeroExTransaction[] memory transactions,
        bytes[] memory signatures
    )
        public
        payable
        returns (bytes[] memory);

    
    ///      If calling a fill function, this address will represent the taker.
    ///      If calling a cancel function, this address will represent the maker.
    
    ///         `msg.sender` if entry point is any other function.
    function _getCurrentContextAddress()
        internal
        view
        returns (address);
}

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

pragma solidity ^0.5.9;


contract IProtocolFees {

    // Logs updates to the protocol fee multiplier.
    event ProtocolFeeMultiplier(uint256 oldProtocolFeeMultiplier, uint256 updatedProtocolFeeMultiplier);

    // Logs updates to the protocolFeeCollector address.
    event ProtocolFeeCollectorAddress(address oldProtocolFeeCollector, address updatedProtocolFeeCollector);

    
    
    function setProtocolFeeMultiplier(uint256 updatedProtocolFeeMultiplier)
        external;

    
    
    function setProtocolFeeCollectorAddress(address updatedProtocolFeeCollector)
        external;

    
    function protocolFeeMultiplier()
        external
        view
        returns (uint256);

    
    function protocolFeeCollector()
        external
        view
        returns (address);
}

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

pragma solidity ^0.5.9;


contract LibEIP1271 {

    
    
    bytes4 constant public EIP1271_MAGIC_VALUE = 0x20c13b0b;
}

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

pragma solidity ^0.5.9;











contract MixinTransactions is
    Refundable,
    LibEIP712ExchangeDomain,
    ISignatureValidator,
    ITransactions
{
    using LibZeroExTransaction for LibZeroExTransaction.ZeroExTransaction;

    
    ///      This prevents transactions from being executed more than once.
    
    
    mapping (bytes32 => bool) public transactionsExecuted;

    
    
    address public currentContextAddress;

    
    
    
    
    function executeTransaction(
        LibZeroExTransaction.ZeroExTransaction memory transaction,
        bytes memory signature
    )
        public
        payable
        disableRefundUntilEnd
        returns (bytes memory)
    {
        return _executeTransaction(transaction, signature);
    }

    
    
    
    
    function batchExecuteTransactions(
        LibZeroExTransaction.ZeroExTransaction[] memory transactions,
        bytes[] memory signatures
    )
        public
        payable
        disableRefundUntilEnd
        returns (bytes[] memory returnData)
    {
        uint256 length = transactions.length;
        returnData = new bytes[](length);
        for (uint256 i = 0; i != length; i++) {
            returnData[i] = _executeTransaction(transactions[i], signatures[i]);
        }
        return returnData;
    }

    
    
    
    
    function _executeTransaction(
        LibZeroExTransaction.ZeroExTransaction memory transaction,
        bytes memory signature
    )
        internal
        returns (bytes memory)
    {
        bytes32 transactionHash = transaction.getTypedDataHash(EIP712_EXCHANGE_DOMAIN_HASH);

        _assertExecutableTransaction(
            transaction,
            signature,
            transactionHash
        );

        // Set the current transaction signer
        address signerAddress = transaction.signerAddress;
        _setCurrentContextAddressIfRequired(signerAddress, signerAddress);

        // Execute transaction
        transactionsExecuted[transactionHash] = true;
        (bool didSucceed, bytes memory returnData) = address(this).delegatecall(transaction.data);
        if (!didSucceed) {
            LibRichErrors.rrevert(LibExchangeRichErrors.TransactionExecutionError(
                transactionHash,
                returnData
            ));
        }

        // Reset current transaction signer if it was previously updated
        _setCurrentContextAddressIfRequired(signerAddress, address(0));

        emit TransactionExecution(transactionHash);

        return returnData;
    }

    
    
    
    
    function _assertExecutableTransaction(
        LibZeroExTransaction.ZeroExTransaction memory transaction,
        bytes memory signature,
        bytes32 transactionHash
    )
        internal
        view
    {
        // Check transaction is not expired
        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp >= transaction.expirationTimeSeconds) {
            LibRichErrors.rrevert(LibExchangeRichErrors.TransactionError(
                LibExchangeRichErrors.TransactionErrorCodes.EXPIRED,
                transactionHash
            ));
        }

        // Validate that transaction is executed with the correct gasPrice
        uint256 requiredGasPrice = transaction.gasPrice;
        if (tx.gasprice != requiredGasPrice) {
            LibRichErrors.rrevert(LibExchangeRichErrors.TransactionGasPriceError(
                transactionHash,
                tx.gasprice,
                requiredGasPrice
            ));
        }

        // Prevent `executeTransaction` from being called when context is already set
        address currentContextAddress_ = currentContextAddress;
        if (currentContextAddress_ != address(0)) {
            LibRichErrors.rrevert(LibExchangeRichErrors.TransactionInvalidContextError(
                transactionHash,
                currentContextAddress_
            ));
        }

        // Validate transaction has not been executed
        if (transactionsExecuted[transactionHash]) {
            LibRichErrors.rrevert(LibExchangeRichErrors.TransactionError(
                LibExchangeRichErrors.TransactionErrorCodes.ALREADY_EXECUTED,
                transactionHash
            ));
        }

        // Validate signature
        // Transaction always valid if signer is sender of transaction
        address signerAddress = transaction.signerAddress;
        if (signerAddress != msg.sender && !_isValidTransactionWithHashSignature(
                transaction,
                transactionHash,
                signature
            )
        ) {
            LibRichErrors.rrevert(LibExchangeRichErrors.SignatureError(
                LibExchangeRichErrors.SignatureErrorCodes.BAD_TRANSACTION_SIGNATURE,
                transactionHash,
                signerAddress,
                signature
            ));
        }
    }

    
    
    
    function _setCurrentContextAddressIfRequired(
        address signerAddress,
        address contextAddress
    )
        internal
    {
        if (signerAddress != msg.sender) {
            currentContextAddress = contextAddress;
        }
    }

    
    ///      If calling a fill function, this address will represent the taker.
    ///      If calling a cancel function, this address will represent the maker.
    
    ///         `msg.sender` if entry point is any other function.
    function _getCurrentContextAddress()
        internal
        view
        returns (address)
    {
        address currentContextAddress_ = currentContextAddress;
        address contextAddress = currentContextAddress_ == address(0) ? msg.sender : currentContextAddress_;
        return contextAddress;
    }
}

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

pragma solidity ^0.5.9;






contract IExchangeCore {

    // Fill event is emitted whenever an order is filled.
    event Fill(
        address indexed makerAddress,         // Address that created the order.
        address indexed feeRecipientAddress,  // Address that received fees.
        bytes makerAssetData,                 // Encoded data specific to makerAsset.
        bytes takerAssetData,                 // Encoded data specific to takerAsset.
        bytes makerFeeAssetData,              // Encoded data specific to makerFeeAsset.
        bytes takerFeeAssetData,              // Encoded data specific to takerFeeAsset.
        bytes32 indexed orderHash,            // EIP712 hash of order (see LibOrder.getTypedDataHash).
        address takerAddress,                 // Address that filled the order.
        address senderAddress,                // Address that called the Exchange contract (msg.sender).
        uint256 makerAssetFilledAmount,       // Amount of makerAsset sold by maker and bought by taker.
        uint256 takerAssetFilledAmount,       // Amount of takerAsset sold by taker and bought by maker.
        uint256 makerFeePaid,                 // Amount of makerFeeAssetData paid to feeRecipient by maker.
        uint256 takerFeePaid,                 // Amount of takerFeeAssetData paid to feeRecipient by taker.
        uint256 protocolFeePaid               // Amount of eth or weth paid to the staking contract.
    );

    // Cancel event is emitted whenever an individual order is cancelled.
    event Cancel(
        address indexed makerAddress,         // Address that created the order.
        address indexed feeRecipientAddress,  // Address that would have recieved fees if order was filled.
        bytes makerAssetData,                 // Encoded data specific to makerAsset.
        bytes takerAssetData,                 // Encoded data specific to takerAsset.
        address senderAddress,                // Address that called the Exchange contract (msg.sender).
        bytes32 indexed orderHash             // EIP712 hash of order (see LibOrder.getTypedDataHash).
    );

    // CancelUpTo event is emitted whenever `cancelOrdersUpTo` is executed succesfully.
    event CancelUpTo(
        address indexed makerAddress,         // Orders cancelled must have been created by this address.
        address indexed orderSenderAddress,   // Orders cancelled must have a `senderAddress` equal to this address.
        uint256 orderEpoch                    // Orders with specified makerAddress and senderAddress with a salt less than this value are considered cancelled.
    );

    
    ///      and senderAddress equal to msg.sender (or null address if msg.sender == makerAddress).
    
    function cancelOrdersUpTo(uint256 targetOrderEpoch)
        external
        payable;

    
    
    
    
    
    function fillOrder(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        payable
        returns (LibFillResults.FillResults memory fillResults);

    
    
    function setFeesManager(address newFeesManager) external;

    
    
    function cancelOrder(LibOrder.Order memory order)
        public
        payable;

    
    
    
    ///                   See LibOrder.OrderInfo for a complete description.
    function getOrderInfo(LibOrder.Order memory order)
        public
        view
        returns (LibOrder.OrderInfo memory orderInfo);
}

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

pragma solidity ^0.5.9;








contract MixinProtocolFees is
    IProtocolFees,
    Ownable
{
    
    
    uint256 public protocolFeeMultiplier;

    
    
    address public protocolFeeCollector;

    
    
    function setProtocolFeeMultiplier(uint256 updatedProtocolFeeMultiplier)
        external
        onlyOwner
    {
        emit ProtocolFeeMultiplier(protocolFeeMultiplier, updatedProtocolFeeMultiplier);
        protocolFeeMultiplier = updatedProtocolFeeMultiplier;
    }

    
    
    function setProtocolFeeCollectorAddress(address updatedProtocolFeeCollector)
        external
        onlyOwner
    {
        _setProtocolFeeCollectorAddress(updatedProtocolFeeCollector);
    }

    
    ///      Only callable by owner.
    function detachProtocolFeeCollector()
        external
        onlyOwner
    {
        _setProtocolFeeCollectorAddress(address(0));
    }

    
    
    function _setProtocolFeeCollectorAddress(address updatedProtocolFeeCollector)
        internal
    {
        emit ProtocolFeeCollectorAddress(protocolFeeCollector, updatedProtocolFeeCollector);
        protocolFeeCollector = updatedProtocolFeeCollector;
    }

    
    
    
    
    
    function _paySingleProtocolFee(
        bytes32 orderHash,
        uint256 protocolFee,
        address makerAddress,
        address takerAddress
    )
        internal
        returns (bool)
    {
        address feeCollector = protocolFeeCollector;
        if (feeCollector != address(0)) {
            _payProtocolFeeToFeeCollector(
                orderHash,
                feeCollector,
                address(this).balance,
                protocolFee,
                makerAddress,
                takerAddress
            );
            return true;
        } else {
            return false;
        }
    }

    
    
    
    
    
    
    
    function _payTwoProtocolFees(
        bytes32 orderHash1,
        bytes32 orderHash2,
        uint256 protocolFee,
        address makerAddress1,
        address makerAddress2,
        address takerAddress
    )
        internal
        returns (bool)
    {
        address feeCollector = protocolFeeCollector;
        if (feeCollector != address(0)) {
            // Since the `BALANCE` opcode costs 400 gas, we choose to calculate this value by hand rather than calling it twice.
            uint256 exchangeBalance = address(this).balance;

            // Pay protocol fee and attribute to first maker
            uint256 valuePaid = _payProtocolFeeToFeeCollector(
                orderHash1,
                feeCollector,
                exchangeBalance,
                protocolFee,
                makerAddress1,
                takerAddress
            );

            // Pay protocol fee and attribute to second maker
            _payProtocolFeeToFeeCollector(
                orderHash2,
                feeCollector,
                exchangeBalance - valuePaid,
                protocolFee,
                makerAddress2,
                takerAddress
            );
            return true;
        } else {
            return false;
        }
    }

    
    
    
    
    
    
    
    function _payProtocolFeeToFeeCollector(
        bytes32 orderHash,
        address feeCollector,
        uint256 exchangeBalance,
        uint256 protocolFee,
        address makerAddress,
        address takerAddress
    )
        internal
        returns (uint256 valuePaid)
    {
        // Do not send a value with the call if the exchange has an insufficient balance
        // The protocolFeeCollector contract will fallback to charging WETH
        if (exchangeBalance >= protocolFee) {
            valuePaid = protocolFee;
        }
        bytes memory payProtocolFeeData = abi.encodeWithSelector(
            IStaking(address(0)).payProtocolFee.selector,
            makerAddress,
            takerAddress,
            protocolFee
        );
        // solhint-disable-next-line avoid-call-value
        (bool didSucceed, bytes memory returnData) = feeCollector.call.value(valuePaid)(payProtocolFeeData);
        if (!didSucceed) {
            LibRichErrors.rrevert(LibExchangeRichErrors.PayProtocolFeeError(
                orderHash,
                protocolFee,
                makerAddress,
                takerAddress,
                returnData
            ));
        }
        return valuePaid;
    }
}

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

pragma solidity ^0.5.9;
















contract MixinSignatureValidator is
    LibEIP712ExchangeDomain,
    LibEIP1271,
    ISignatureValidator,
    MixinTransactions
{
    using LibBytes for bytes;
    using LibOrder for LibOrder.Order;
    using LibZeroExTransaction for LibZeroExTransaction.ZeroExTransaction;

    // Magic bytes to be returned by `Wallet` signature type validators.
    // bytes4(keccak256("isValidWalletSignature(bytes32,address,bytes)"))
    bytes4 private constant LEGACY_WALLET_MAGIC_VALUE = 0xb0671381;

    
    
    
    
    mapping (bytes32 => mapping (address => bool)) public preSigned;

    
    
    
    
    mapping (address => mapping (address => bool)) public allowedValidators;

    
    ///      After presigning a hash, the preSign signature type will become valid for that hash and signer.
    
    function preSign(bytes32 hash)
        external
        payable
        refundFinalBalanceNoReentry
    {
        address signerAddress = _getCurrentContextAddress();
        preSigned[hash][signerAddress] = true;
    }

    
    ///      using the `Validator` signature type.
    
    
    function setSignatureValidatorApproval(
        address validatorAddress,
        bool approval
    )
        external
        payable
        refundFinalBalanceNoReentry
    {
        address signerAddress = _getCurrentContextAddress();
        allowedValidators[signerAddress][validatorAddress] = approval;
        emit SignatureValidatorApproval(
            signerAddress,
            validatorAddress,
            approval
        );
    }

    
    
    
    
    
    function isValidHashSignature(
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        public
        view
        returns (bool isValid)
    {
        SignatureType signatureType = _readValidSignatureType(
            hash,
            signerAddress,
            signature
        );
        // Only hash-compatible signature types can be handled by this
        // function.
        if (
            signatureType == SignatureType.Validator ||
            signatureType == SignatureType.EIP1271Wallet
        ) {
            LibRichErrors.rrevert(LibExchangeRichErrors.SignatureError(
                LibExchangeRichErrors.SignatureErrorCodes.INAPPROPRIATE_SIGNATURE_TYPE,
                hash,
                signerAddress,
                signature
            ));
        }
        isValid = _validateHashSignatureTypes(
            signatureType,
            hash,
            signerAddress,
            signature
        );
        return isValid;
    }

    
    
    
    
    function isValidOrderSignature(
        LibOrder.Order memory order,
        bytes memory signature
    )
        public
        view
        returns (bool isValid)
    {
        bytes32 orderHash = order.getTypedDataHash(EIP712_EXCHANGE_DOMAIN_HASH);
        isValid = _isValidOrderWithHashSignature(
            order,
            orderHash,
            signature
        );
        return isValid;
    }

    
    
    
    
    function isValidTransactionSignature(
        LibZeroExTransaction.ZeroExTransaction memory transaction,
        bytes memory signature
    )
        public
        view
        returns (bool isValid)
    {
        bytes32 transactionHash = transaction.getTypedDataHash(EIP712_EXCHANGE_DOMAIN_HASH);
        isValid = _isValidTransactionWithHashSignature(
            transaction,
            transactionHash,
            signature
        );
        return isValid;
    }

    
    ///      by the given signer.
    
    
    
    
    function _isValidOrderWithHashSignature(
        LibOrder.Order memory order,
        bytes32 orderHash,
        bytes memory signature
    )
        internal
        view
        returns (bool isValid)
    {
        address signerAddress = order.makerAddress;
        SignatureType signatureType = _readValidSignatureType(
            orderHash,
            signerAddress,
            signature
        );
        if (signatureType == SignatureType.Validator) {
            // The entire order is verified by a validator contract.
            isValid = _validateBytesWithValidator(
                _encodeEIP1271OrderWithHash(order, orderHash),
                orderHash,
                signerAddress,
                signature
            );
        } else if (signatureType == SignatureType.EIP1271Wallet) {
            // The entire order is verified by a wallet contract.
            isValid = _validateBytesWithWallet(
                _encodeEIP1271OrderWithHash(order, orderHash),
                signerAddress,
                signature
            );
        } else {
            // Otherwise, it's one of the hash-only signature types.
            isValid = _validateHashSignatureTypes(
                signatureType,
                orderHash,
                signerAddress,
                signature
            );
        }
        return isValid;
    }

    
    ///      by the given signer.
    
    
    
    
    function _isValidTransactionWithHashSignature(
        LibZeroExTransaction.ZeroExTransaction memory transaction,
        bytes32 transactionHash,
        bytes memory signature
    )
        internal
        view
        returns (bool isValid)
    {
        address signerAddress = transaction.signerAddress;
        SignatureType signatureType = _readValidSignatureType(
            transactionHash,
            signerAddress,
            signature
        );
        if (signatureType == SignatureType.Validator) {
            // The entire transaction is verified by a validator contract.
            isValid = _validateBytesWithValidator(
                _encodeEIP1271TransactionWithHash(transaction, transactionHash),
                transactionHash,
                signerAddress,
                signature
            );
        } else if (signatureType == SignatureType.EIP1271Wallet) {
            // The entire transaction is verified by a wallet contract.
            isValid = _validateBytesWithWallet(
                _encodeEIP1271TransactionWithHash(transaction, transactionHash),
                signerAddress,
                signature
            );
        } else {
            // Otherwise, it's one of the hash-only signature types.
            isValid = _validateHashSignatureTypes(
                signatureType,
                transactionHash,
                signerAddress,
                signature
            );
        }
        return isValid;
    }

    /// Validates a hash-only signature type
    /// (anything but `Validator` and `EIP1271Wallet`).
    function _validateHashSignatureTypes(
        SignatureType signatureType,
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        private
        view
        returns (bool isValid)
    {
        // Always invalid signature.
        // Like Illegal, this is always implicitly available and therefore
        // offered explicitly. It can be implicitly created by providing
        // a correctly formatted but incorrect signature.
        if (signatureType == SignatureType.Invalid) {
            if (signature.length != 1) {
                LibRichErrors.rrevert(LibExchangeRichErrors.SignatureError(
                    LibExchangeRichErrors.SignatureErrorCodes.INVALID_LENGTH,
                    hash,
                    signerAddress,
                    signature
                ));
            }
            isValid = false;

        // Signature using EIP712
        } else if (signatureType == SignatureType.EIP712) {
            if (signature.length != 66) {
                LibRichErrors.rrevert(LibExchangeRichErrors.SignatureError(
                    LibExchangeRichErrors.SignatureErrorCodes.INVALID_LENGTH,
                    hash,
                    signerAddress,
                    signature
                ));
            }
            uint8 v = uint8(signature[0]);
            bytes32 r = signature.readBytes32(1);
            bytes32 s = signature.readBytes32(33);
            address recovered = ecrecover(
                hash,
                v,
                r,
                s
            );
            isValid = signerAddress == recovered;

        // Signed using web3.eth_sign
        } else if (signatureType == SignatureType.EthSign) {
            if (signature.length != 66) {
                LibRichErrors.rrevert(LibExchangeRichErrors.SignatureError(
                    LibExchangeRichErrors.SignatureErrorCodes.INVALID_LENGTH,
                    hash,
                    signerAddress,
                    signature
                ));
            }
            uint8 v = uint8(signature[0]);
            bytes32 r = signature.readBytes32(1);
            bytes32 s = signature.readBytes32(33);
            address recovered = ecrecover(
                keccak256(abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    hash
                )),
                v,
                r,
                s
            );
            isValid = signerAddress == recovered;

        // Signature verified by wallet contract.
        } else if (signatureType == SignatureType.Wallet) {
            isValid = _validateHashWithWallet(
                hash,
                signerAddress,
                signature
            );

        // Otherwise, signatureType == SignatureType.PreSigned
        } else {
            assert(signatureType == SignatureType.PreSigned);
            // Signer signed hash previously using the preSign function.
            isValid = preSigned[hash][signerAddress];
        }
        return isValid;
    }

    
    function _readSignatureType(
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        private
        pure
        returns (SignatureType)
    {
        if (signature.length == 0) {
            LibRichErrors.rrevert(LibExchangeRichErrors.SignatureError(
                LibExchangeRichErrors.SignatureErrorCodes.INVALID_LENGTH,
                hash,
                signerAddress,
                signature
            ));
        }
        return SignatureType(uint8(signature[signature.length - 1]));
    }

    
    function _readValidSignatureType(
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        private
        pure
        returns (SignatureType signatureType)
    {
        // Read the signatureType from the signature
        signatureType = _readSignatureType(
            hash,
            signerAddress,
            signature
        );

        // Disallow address zero because ecrecover() returns zero on failure.
        if (signerAddress == address(0)) {
            LibRichErrors.rrevert(LibExchangeRichErrors.SignatureError(
                LibExchangeRichErrors.SignatureErrorCodes.INVALID_SIGNER,
                hash,
                signerAddress,
                signature
            ));
        }

        // Ensure signature is supported
        if (uint8(signatureType) >= uint8(SignatureType.NSignatureTypes)) {
            LibRichErrors.rrevert(LibExchangeRichErrors.SignatureError(
                LibExchangeRichErrors.SignatureErrorCodes.UNSUPPORTED,
                hash,
                signerAddress,
                signature
            ));
        }

        // Always illegal signature.
        // This is always an implicit option since a signer can create a
        // signature array with invalid type or length. We may as well make
        // it an explicit option. This aids testing and analysis. It is
        // also the initialization value for the enum type.
        if (signatureType == SignatureType.Illegal) {
            LibRichErrors.rrevert(LibExchangeRichErrors.SignatureError(
                LibExchangeRichErrors.SignatureErrorCodes.ILLEGAL,
                hash,
                signerAddress,
                signature
            ));
        }

        return signatureType;
    }

    
    ///      an EIP1271 compliant `isValidSignature` function.
    function _encodeEIP1271OrderWithHash(
        LibOrder.Order memory order,
        bytes32 orderHash
    )
        private
        pure
        returns (bytes memory encoded)
    {
        return abi.encodeWithSelector(
            IEIP1271Data(address(0)).OrderWithHash.selector,
            order,
            orderHash
        );
    }

    
    ///      an EIP1271 compliant `isValidSignature` function.
    function _encodeEIP1271TransactionWithHash(
        LibZeroExTransaction.ZeroExTransaction memory transaction,
        bytes32 transactionHash
    )
        private
        pure
        returns (bytes memory encoded)
    {
        return abi.encodeWithSelector(
            IEIP1271Data(address(0)).ZeroExTransactionWithHash.selector,
            transaction,
            transactionHash
        );
    }

    
    
    
    ///                      and defines its own signature verification method.
    
    
    function _validateHashWithWallet(
        bytes32 hash,
        address walletAddress,
        bytes memory signature
    )
        private
        view
        returns (bool)
    {
        // Backup length of signature
        uint256 signatureLength = signature.length;
        // Temporarily remove signatureType byte from end of signature
        signature.writeLength(signatureLength - 1);
        // Encode the call data.
        bytes memory callData = abi.encodeWithSelector(
            IWallet(address(0)).isValidSignature.selector,
            hash,
            signature
        );
        // Restore the original signature length
        signature.writeLength(signatureLength);
        // Static call the verification function.
        (bool didSucceed, bytes memory returnData) = walletAddress.staticcall(callData);
        // Return the validity of the signature if the call was successful
        if (didSucceed && returnData.length == 32) {
            return returnData.readBytes4(0) == LEGACY_WALLET_MAGIC_VALUE;
        }
        // Revert if the call was unsuccessful
        LibRichErrors.rrevert(LibExchangeRichErrors.SignatureWalletError(
            hash,
            walletAddress,
            signature,
            returnData
        ));
    }

    
    ///      contract, where the wallet address is also the signer address.
    
    
    
    
    function _validateBytesWithWallet(
        bytes memory data,
        address walletAddress,
        bytes memory signature
    )
        private
        view
        returns (bool isValid)
    {
        isValid = _staticCallEIP1271WalletWithReducedSignatureLength(
            walletAddress,
            data,
            signature,
            1  // The last byte of the signature (signatureType) is removed before making the staticcall
        );
        return isValid;
    }

    
    ///      whose address is encoded in the signature.
    
    
    
    
    
    function _validateBytesWithValidator(
        bytes memory data,
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        private
        view
        returns (bool isValid)
    {
        uint256 signatureLength = signature.length;
        if (signatureLength < 21) {
            LibRichErrors.rrevert(LibExchangeRichErrors.SignatureError(
                LibExchangeRichErrors.SignatureErrorCodes.INVALID_LENGTH,
                hash,
                signerAddress,
                signature
            ));
        }
        // The validator address is appended to the signature before the signatureType.
        // Read the validator address from the signature.
        address validatorAddress = signature.readAddress(signatureLength - 21);
        // Ensure signer has approved validator.
        if (!allowedValidators[signerAddress][validatorAddress]) {
            LibRichErrors.rrevert(LibExchangeRichErrors.SignatureValidatorNotApprovedError(
                signerAddress,
                validatorAddress
            ));
        }
        isValid = _staticCallEIP1271WalletWithReducedSignatureLength(
            validatorAddress,
            data,
            signature,
            21  // The last 21 bytes of the signature (validatorAddress + signatureType) are removed before making the staticcall
        );
        return isValid;
    }

    
    
    
    
    ///                  off of the signature before calling `isValidSignature`.
    
    
    function _staticCallEIP1271WalletWithReducedSignatureLength(
        address verifyingContractAddress,
        bytes memory data,
        bytes memory signature,
        uint256 ignoredSignatureBytesLen
    )
        private
        view
        returns (bool)
    {
        // Backup length of the signature
        uint256 signatureLength = signature.length;
        // Temporarily remove bytes from signature end
        signature.writeLength(signatureLength - ignoredSignatureBytesLen);
        bytes memory callData = abi.encodeWithSelector(
            IEIP1271Wallet(address(0)).isValidSignature.selector,
            data,
            signature
        );
        // Restore original signature length
        signature.writeLength(signatureLength);
        // Static call the verification function
        (bool didSucceed, bytes memory returnData) = verifyingContractAddress.staticcall(callData);
        // Return the validity of the signature if the call was successful
        if (didSucceed && returnData.length == 32) {
            return returnData.readBytes4(0) == EIP1271_MAGIC_VALUE;
        }
        // Revert if the call was unsuccessful
        LibRichErrors.rrevert(LibExchangeRichErrors.EIP1271SignatureError(
            verifyingContractAddress,
            data,
            signature,
            returnData
        ));
    }
}

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

pragma solidity ^0.5.9;






contract IMatchOrders {

    
    ///      Each order is filled at their respective price point, and
    ///      the matcher receives a profit denominated in the left maker asset.
    
    
    
    
    
    function batchMatchOrders(
        LibOrder.Order[] memory leftOrders,
        LibOrder.Order[] memory rightOrders,
        bytes[] memory leftSignatures,
        bytes[] memory rightSignatures
    )
        public
        payable
        returns (LibFillResults.BatchMatchedFillResults memory batchMatchedFillResults);

    
    ///      Each order is maximally filled at their respective price point, and
    ///      the matcher receives a profit denominated in either the left maker asset,
    ///      right maker asset, or a combination of both.
    
    
    
    
    
    function batchMatchOrdersWithMaximalFill(
        LibOrder.Order[] memory leftOrders,
        LibOrder.Order[] memory rightOrders,
        bytes[] memory leftSignatures,
        bytes[] memory rightSignatures
    )
        public
        payable
        returns (LibFillResults.BatchMatchedFillResults memory batchMatchedFillResults);

    
    ///      Each order is filled at their respective price point. However, the calculations are
    ///      carried out as though the orders are both being filled at the right order's price point.
    ///      The profit made by the left order goes to the taker (who matched the two orders).
    
    
    
    
    
    function matchOrders(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        bytes memory leftSignature,
        bytes memory rightSignature
    )
        public
        payable
        returns (LibFillResults.MatchedFillResults memory matchedFillResults);

    
    ///      Each order is maximally filled at their respective price point, and
    ///      the matcher receives a profit denominated in either the left maker asset,
    ///      right maker asset, or a combination of both.
    
    
    
    
    
    function matchOrdersWithMaximalFill(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        bytes memory leftSignature,
        bytes memory rightSignature
    )
        public
        payable
        returns (LibFillResults.MatchedFillResults memory matchedFillResults);
}


contract MixinExchangeCore is
    IExchangeCore,
    Refundable,
    LibEIP712ExchangeDomain,
    MixinAssetProxyDispatcher,
    MixinProtocolFees,
    MixinSignatureValidator
{
    using LibOrder for LibOrder.Order;
    using LibSafeMath for uint256;
    using LibBytes for bytes;

    
    
    
    mapping (bytes32 => uint256) public filled;

    
    
    
    mapping (bytes32 => bool) public cancelled;

    
    address public feesManager;

    
    ///      Orders with specified senderAddress and with a salt less than their epoch are considered cancelled
    
    
    
    mapping (address => mapping (address => uint256)) public orderEpoch;

    
    ///      and senderAddress equal to msg.sender (or null address if msg.sender == makerAddress).
    
    function cancelOrdersUpTo(uint256 targetOrderEpoch)
        external
        payable
        refundFinalBalanceNoReentry
    {
        address makerAddress = _getCurrentContextAddress();
        // If this function is called via `executeTransaction`, we only update the orderEpoch for the makerAddress/msg.sender combination.
        // This allows external filter contracts to add rules to how orders are cancelled via this function.
        address orderSenderAddress = makerAddress == msg.sender ? address(0) : msg.sender;

        // orderEpoch is initialized to 0, so to cancelUpTo we need salt + 1
        uint256 newOrderEpoch = targetOrderEpoch + 1;
        uint256 oldOrderEpoch = orderEpoch[makerAddress][orderSenderAddress];

        // Ensure orderEpoch is monotonically increasing
        if (newOrderEpoch <= oldOrderEpoch) {
            LibRichErrors.rrevert(LibExchangeRichErrors.OrderEpochError(
                makerAddress,
                orderSenderAddress,
                oldOrderEpoch
            ));
        }

        // Update orderEpoch
        orderEpoch[makerAddress][orderSenderAddress] = newOrderEpoch;
        emit CancelUpTo(
            makerAddress,
            orderSenderAddress,
            newOrderEpoch
        );
    }

    
    
    function setFeesManager(address newFeesManager) external onlyOwner {
        feesManager = newFeesManager;
    }

    
    
    
    
    
    function fillOrder(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        payable
        refundFinalBalanceNoReentry
        returns (LibFillResults.FillResults memory fillResults)
    {
        fillResults = _fillOrder(
            order,
            takerAssetFillAmount,
            signature
        );
        return fillResults;
    }

    
    
    function cancelOrder(LibOrder.Order memory order)
        public
        payable
        refundFinalBalanceNoReentry
    {
        _cancelOrder(order);
    }

    
    
    
    ///         See LibOrder.OrderInfo for a complete description.
    function getOrderInfo(LibOrder.Order memory order)
        public
        view
        returns (LibOrder.OrderInfo memory orderInfo)
    {
        // Compute the order hash and fetch the amount of takerAsset that has already been filled
        (orderInfo.orderHash, orderInfo.orderTakerAssetFilledAmount) = _getOrderHashAndFilledAmount(order);

        // If order.makerAssetAmount is zero, we also reject the order.
        // While the Exchange contract handles them correctly, they create
        // edge cases in the supporting infrastructure because they have
        // an 'infinite' price when computed by a simple division.
        if (order.makerAssetAmount == 0) {
            orderInfo.orderStatus = LibOrder.OrderStatus.INVALID_MAKER_ASSET_AMOUNT;
            return orderInfo;
        }

        // If order.takerAssetAmount is zero, then the order will always
        // be considered filled because 0 == takerAssetAmount == orderTakerAssetFilledAmount
        // Instead of distinguishing between unfilled and filled zero taker
        // amount orders, we choose not to support them.
        if (order.takerAssetAmount == 0) {
            orderInfo.orderStatus = LibOrder.OrderStatus.INVALID_TAKER_ASSET_AMOUNT;
            return orderInfo;
        }

        // Validate order availability
        if (orderInfo.orderTakerAssetFilledAmount >= order.takerAssetAmount) {
            orderInfo.orderStatus = LibOrder.OrderStatus.FULLY_FILLED;
            return orderInfo;
        }

        // Validate order expiration
        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp >= order.expirationTimeSeconds) {
            orderInfo.orderStatus = LibOrder.OrderStatus.EXPIRED;
            return orderInfo;
        }

        // Check if order has been cancelled
        if (cancelled[orderInfo.orderHash]) {
            orderInfo.orderStatus = LibOrder.OrderStatus.CANCELLED;
            return orderInfo;
        }
        if (orderEpoch[order.makerAddress][order.senderAddress] > order.salt) {
            orderInfo.orderStatus = LibOrder.OrderStatus.CANCELLED;
            return orderInfo;
        }

        // All other statuses are ruled out: order is Fillable
        orderInfo.orderStatus = LibOrder.OrderStatus.FILLABLE;
        return orderInfo;
    }

    
    
    
    
    
    function _fillOrder(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        internal
        returns (LibFillResults.FillResults memory fillResults)
    {
        // Fetch order info
        LibOrder.OrderInfo memory orderInfo = getOrderInfo(order);

        // Fetch taker address
        address takerAddress = _getCurrentContextAddress();

        // Assert that the order is fillable by taker
        _assertFillableOrder(
            order,
            orderInfo,
            takerAddress,
            signature
        );

        // Get amount of takerAsset to fill
        uint256 remainingTakerAssetAmount = order.takerAssetAmount.safeSub(orderInfo.orderTakerAssetFilledAmount);
        uint256 takerAssetFilledAmount = LibSafeMath.min256(takerAssetFillAmount, remainingTakerAssetAmount);

        // Compute proportional fill amounts
        fillResults = LibFillResults.calculateFillResults(
            order,
            takerAssetFilledAmount,
            protocolFeeMultiplier,
            tx.gasprice
        );

        bytes32 orderHash = orderInfo.orderHash;

        // Update exchange internal state
        _updateFilledState(
            order,
            takerAddress,
            orderHash,
            orderInfo.orderTakerAssetFilledAmount,
            fillResults
        );

        // Settle order
        _settleOrder(
            orderHash,
            order,
            takerAddress,
            fillResults
        );

        return fillResults;
    }

    
    ///      Throws if order is invalid or sender does not have permission to cancel.
    
    function _cancelOrder(LibOrder.Order memory order)
        internal
    {
        // Fetch current order status
        LibOrder.OrderInfo memory orderInfo = getOrderInfo(order);

        // Validate context
        _assertValidCancel(order, orderInfo);

        // Noop if order is already unfillable
        if (orderInfo.orderStatus != LibOrder.OrderStatus.FILLABLE) {
            return;
        }

        // Perform cancel
        _updateCancelledState(order, orderInfo.orderHash);
    }

    
    
    
    
    function _updateFilledState(
        LibOrder.Order memory order,
        address takerAddress,
        bytes32 orderHash,
        uint256 orderTakerAssetFilledAmount,
        LibFillResults.FillResults memory fillResults
    )
        internal
    {
        // Update state
        filled[orderHash] = orderTakerAssetFilledAmount.safeAdd(fillResults.takerAssetFilledAmount);

        emit Fill(
            order.makerAddress,
            order.feeRecipientAddress,
            order.makerAssetData,
            order.takerAssetData,
            order.makerFeeAssetData,
            order.takerFeeAssetData,
            orderHash,
            takerAddress,
            msg.sender,
            fillResults.makerAssetFilledAmount,
            fillResults.takerAssetFilledAmount,
            fillResults.makerFeePaid,
            fillResults.takerFeePaid,
            fillResults.protocolFeePaid
        );
    }

    
    ///      State is only updated if the order is currently fillable.
    ///      Otherwise, updating state would have no effect.
    
    
    function _updateCancelledState(
        LibOrder.Order memory order,
        bytes32 orderHash
    )
        internal
    {
        // Perform cancel
        cancelled[orderHash] = true;

        // Log cancel
        emit Cancel(
            order.makerAddress,
            order.feeRecipientAddress,
            order.makerAssetData,
            order.takerAssetData,
            msg.sender,
            orderHash
        );
    }

    
    
    
    
    
    function _assertFillableOrder(
        LibOrder.Order memory order,
        LibOrder.OrderInfo memory orderInfo,
        address takerAddress,
        bytes memory signature
    )
        internal
        view
    {
        // An order can only be filled if its status is FILLABLE.
        if (orderInfo.orderStatus != LibOrder.OrderStatus.FILLABLE) {
            LibRichErrors.rrevert(LibExchangeRichErrors.OrderStatusError(
                orderInfo.orderHash,
                LibOrder.OrderStatus(orderInfo.orderStatus)
            ));
        }

        // Validate sender is allowed to fill this order
        if (order.senderAddress != address(0)) {
            if (order.senderAddress != msg.sender) {
                LibRichErrors.rrevert(LibExchangeRichErrors.ExchangeInvalidContextError(
                    LibExchangeRichErrors.ExchangeContextErrorCodes.INVALID_SENDER,
                    orderInfo.orderHash,
                    msg.sender
                ));
            }
        }

        // Validate taker is allowed to fill this order
        if (order.takerAddress != address(0)) {
            if (order.takerAddress != takerAddress) {
                LibRichErrors.rrevert(LibExchangeRichErrors.ExchangeInvalidContextError(
                    LibExchangeRichErrors.ExchangeContextErrorCodes.INVALID_TAKER,
                    orderInfo.orderHash,
                    takerAddress
                ));
            }
        }

        // Validate signature
        if (!_isValidOrderWithHashSignature(
                order,
                orderInfo.orderHash,
                signature
            )
        ) {
            LibRichErrors.rrevert(LibExchangeRichErrors.SignatureError(
                LibExchangeRichErrors.SignatureErrorCodes.BAD_ORDER_SIGNATURE,
                orderInfo.orderHash,
                order.makerAddress,
                signature
            ));
        }
    }

    
    
    
    function _assertValidCancel(
        LibOrder.Order memory order,
        LibOrder.OrderInfo memory orderInfo
    )
        internal
        view
    {
        // Validate sender is allowed to cancel this order
        if (order.senderAddress != address(0)) {
            if (order.senderAddress != msg.sender) {
                LibRichErrors.rrevert(LibExchangeRichErrors.ExchangeInvalidContextError(
                    LibExchangeRichErrors.ExchangeContextErrorCodes.INVALID_SENDER,
                    orderInfo.orderHash,
                    msg.sender
                ));
            }
        }

        // Validate transaction signed by maker
        address makerAddress = _getCurrentContextAddress();
        if (order.makerAddress != makerAddress) {
            LibRichErrors.rrevert(LibExchangeRichErrors.ExchangeInvalidContextError(
                LibExchangeRichErrors.ExchangeContextErrorCodes.INVALID_MAKER,
                orderInfo.orderHash,
                makerAddress
            ));
        }
    }

    function _getMakerAssetId(bytes memory assetData) internal returns (uint256) {
        (
            ,
            uint256[] memory ids,
            ,

        ) = abi.decode(
            assetData.sliceDestructive(4, assetData.length),
            (address, uint256[], uint256[], bytes)
        );
        require(ids.length == 1, "Should be a single id");
        return ids[0];
    }

    function _getTokenAddress(bytes memory assetData) internal returns (address) {
        (
            address tokenAddress,
            ,

        ) = abi.decode(
            assetData.sliceDestructive(4, assetData.length),
            (address, address, bytes)
        );
        return tokenAddress;
    }

    
    
    
    
    
    function _settleOrder(
        bytes32 orderHash,
        LibOrder.Order memory order,
        address takerAddress,
        LibFillResults.FillResults memory fillResults
    )
        internal
    {
        uint256 taker4KMarketFee = 0;
        uint256 assetId;

        if (feesManager != address(0)) {
            assetId = _getMakerAssetId(order.makerAssetData);
            taker4KMarketFee = IFeesManager(feesManager).calculateFee(assetId, fillResults.takerAssetFilledAmount);
        }
        fillResults.takerAssetFilledAmount = fillResults.takerAssetFilledAmount.safeSub(taker4KMarketFee); 

        // Transfer taker -> maker
        _dispatchTransferFrom(
            orderHash,
            order.takerAssetData,
            takerAddress,
            order.makerAddress,
            fillResults.takerAssetFilledAmount
        );

        // Transfer maker -> taker
        _dispatchTransferFrom(
            orderHash,
            order.makerAssetData,
            order.makerAddress,
            takerAddress,
            fillResults.makerAssetFilledAmount
        );

        // Transfer taker fee -> feeRecipient
        _dispatchTransferFrom(
            orderHash,
            order.takerFeeAssetData,
            takerAddress,
            order.feeRecipientAddress,
            fillResults.takerFeePaid
        );

        // Transfer maker fee -> feeRecipient
        _dispatchTransferFrom(
            orderHash,
            order.makerFeeAssetData,
            order.makerAddress,
            order.feeRecipientAddress,
            fillResults.makerFeePaid
        );

        // Transfer taker 4K market fee -> fees manager
        _dispatchTransferFrom(
            orderHash,
            order.takerFeeAssetData,
            takerAddress,
            feesManager,
            taker4KMarketFee
        );
        
        if (feesManager != address(0)) {
            assetId = _getMakerAssetId(order.makerAssetData);
            address tokenAddress = _getTokenAddress(order.takerFeeAssetData);
            IFeesManager(feesManager).receiveFees(assetId, order.makerAddress, tokenAddress, taker4KMarketFee);
        }

        // Pay protocol fee
        bool didPayProtocolFee = _paySingleProtocolFee(
            orderHash,
            fillResults.protocolFeePaid,
            order.makerAddress,
            takerAddress
        );

        // Protocol fees are not paid if the protocolFeeCollector contract is not set
        if (!didPayProtocolFee) {
            fillResults.protocolFeePaid = 0;
        }
    }

    
    
    
    function _getOrderHashAndFilledAmount(LibOrder.Order memory order)
        internal
        view
        returns (bytes32 orderHash, uint256 orderTakerAssetFilledAmount)
    {
        orderHash = order.getTypedDataHash(EIP712_EXCHANGE_DOMAIN_HASH);
        orderTakerAssetFilledAmount = filled[orderHash];
        return (orderHash, orderTakerAssetFilledAmount);
    }
}

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

pragma solidity ^0.5.9;






contract IWrapperFunctions {

    
    
    
    
    function fillOrKillOrder(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        payable
        returns (LibFillResults.FillResults memory fillResults);

    
    
    
    
    
    function batchFillOrders(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults[] memory fillResults);

    
    
    
    
    
    function batchFillOrKillOrders(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults[] memory fillResults);

    
    
    
    
    
    function batchFillOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults[] memory fillResults);

    
    ///      If any fill reverts, the error is caught and ignored.
    ///      NOTE: This function does not enforce that the takerAsset is the same for each order.
    
    
    
    
    function marketSellOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256 takerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults memory fillResults);

    
    ///      If any fill reverts, the error is caught and ignored.
    ///      NOTE: This function does not enforce that the makerAsset is the same for each order.
    
    
    
    
    function marketBuyOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256 makerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults memory fillResults);

    
    ///      NOTE: This function does not enforce that the takerAsset is the same for each order.
    
    
    
    
    function marketSellOrdersFillOrKill(
        LibOrder.Order[] memory orders,
        uint256 takerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults memory fillResults);

    
    ///      NOTE: This function does not enforce that the makerAsset is the same for each order.
    
    
    
    
    function marketBuyOrdersFillOrKill(
        LibOrder.Order[] memory orders,
        uint256 makerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults memory fillResults);

    
    
    function batchCancelOrders(LibOrder.Order[] memory orders)
        public
        payable;
}

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
pragma solidity ^0.5.9;










contract MixinMatchOrders is
    MixinExchangeCore,
    IMatchOrders
{
    using LibBytes for bytes;
    using LibSafeMath for uint256;
    using LibOrder for LibOrder.Order;

    
    ///      Each order is filled at their respective price point, and
    ///      the matcher receives a profit denominated in the left maker asset.
    
    
    
    
    
    function batchMatchOrders(
        LibOrder.Order[] memory leftOrders,
        LibOrder.Order[] memory rightOrders,
        bytes[] memory leftSignatures,
        bytes[] memory rightSignatures
    )
        public
        payable
        refundFinalBalanceNoReentry
        returns (LibFillResults.BatchMatchedFillResults memory batchMatchedFillResults)
    {
        return _batchMatchOrders(
            leftOrders,
            rightOrders,
            leftSignatures,
            rightSignatures,
            false
        );
    }

    
    ///      Each order is maximally filled at their respective price point, and
    ///      the matcher receives a profit denominated in either the left maker asset,
    ///      right maker asset, or a combination of both.
    
    
    
    
    
    function batchMatchOrdersWithMaximalFill(
        LibOrder.Order[] memory leftOrders,
        LibOrder.Order[] memory rightOrders,
        bytes[] memory leftSignatures,
        bytes[] memory rightSignatures
    )
        public
        payable
        refundFinalBalanceNoReentry
        returns (LibFillResults.BatchMatchedFillResults memory batchMatchedFillResults)
    {
        return _batchMatchOrders(
            leftOrders,
            rightOrders,
            leftSignatures,
            rightSignatures,
            true
        );
    }

    
    ///      Each order is filled at their respective price point. However, the calculations are
    ///      carried out as though the orders are both being filled at the right order's price point.
    ///      The profit made by the left order goes to the taker (who matched the two orders).
    
    
    
    
    
    function matchOrders(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        bytes memory leftSignature,
        bytes memory rightSignature
    )
        public
        payable
        refundFinalBalanceNoReentry
        returns (LibFillResults.MatchedFillResults memory matchedFillResults)
    {
        return _matchOrders(
            leftOrder,
            rightOrder,
            leftSignature,
            rightSignature,
            false
        );
    }

    
    ///      Each order is maximally filled at their respective price point, and
    ///      the matcher receives a profit denominated in either the left maker asset,
    ///      right maker asset, or a combination of both.
    
    
    
    
    
    function matchOrdersWithMaximalFill(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        bytes memory leftSignature,
        bytes memory rightSignature
    )
        public
        payable
        refundFinalBalanceNoReentry
        returns (LibFillResults.MatchedFillResults memory matchedFillResults)
    {
        return _matchOrders(
            leftOrder,
            rightOrder,
            leftSignature,
            rightSignature,
            true
        );
    }

    
    
    
    
    
    function _assertValidMatch(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        bytes32 leftOrderHash,
        bytes32 rightOrderHash
    )
        internal
        pure
    {
        // Make sure there is a profitable spread.
        // There is a profitable spread iff the cost per unit bought (OrderA.MakerAmount/OrderA.TakerAmount) for each order is greater
        // than the profit per unit sold of the matched order (OrderB.TakerAmount/OrderB.MakerAmount).
        // This is satisfied by the equations below:
        // <leftOrder.makerAssetAmount> / <leftOrder.takerAssetAmount> >= <rightOrder.takerAssetAmount> / <rightOrder.makerAssetAmount>
        // AND
        // <rightOrder.makerAssetAmount> / <rightOrder.takerAssetAmount> >= <leftOrder.takerAssetAmount> / <leftOrder.makerAssetAmount>
        // These equations can be combined to get the following:
        if (leftOrder.makerAssetAmount.safeMul(rightOrder.makerAssetAmount) <
            leftOrder.takerAssetAmount.safeMul(rightOrder.takerAssetAmount)) {
            LibRichErrors.rrevert(LibExchangeRichErrors.NegativeSpreadError(
                leftOrderHash,
                rightOrderHash
            ));
        }
    }

    
    ///      Each order is filled at their respective price point, and
    ///      the matcher receives a profit denominated in the left maker asset.
    ///      This is the reentrant version of `batchMatchOrders` and `batchMatchOrdersWithMaximalFill`.
    
    
    
    
    
    ///                        should be done with maximal fill.
    
    function _batchMatchOrders(
        LibOrder.Order[] memory leftOrders,
        LibOrder.Order[] memory rightOrders,
        bytes[] memory leftSignatures,
        bytes[] memory rightSignatures,
        bool shouldMaximallyFillOrders
    )
        internal
        returns (LibFillResults.BatchMatchedFillResults memory batchMatchedFillResults)
    {
        // Ensure that the left and right orders have nonzero lengths.
        if (leftOrders.length == 0) {
            LibRichErrors.rrevert(LibExchangeRichErrors.BatchMatchOrdersError(
                LibExchangeRichErrors.BatchMatchOrdersErrorCodes.ZERO_LEFT_ORDERS
            ));
        }
        if (rightOrders.length == 0) {
            LibRichErrors.rrevert(LibExchangeRichErrors.BatchMatchOrdersError(
                LibExchangeRichErrors.BatchMatchOrdersErrorCodes.ZERO_RIGHT_ORDERS
            ));
        }

        // Ensure that the left and right arrays are compatible.
        if (leftOrders.length != leftSignatures.length) {
            LibRichErrors.rrevert(LibExchangeRichErrors.BatchMatchOrdersError(
                LibExchangeRichErrors.BatchMatchOrdersErrorCodes.INVALID_LENGTH_LEFT_SIGNATURES
            ));
        }
        if (rightOrders.length != rightSignatures.length) {
            LibRichErrors.rrevert(LibExchangeRichErrors.BatchMatchOrdersError(
                LibExchangeRichErrors.BatchMatchOrdersErrorCodes.INVALID_LENGTH_RIGHT_SIGNATURES
            ));
        }

        batchMatchedFillResults.left = new LibFillResults.FillResults[](leftOrders.length);
        batchMatchedFillResults.right = new LibFillResults.FillResults[](rightOrders.length);

        // Set up initial indices.
        uint256 leftIdx = 0;
        uint256 rightIdx = 0;

        // Keep local variables for orders, order filled amounts, and signatures for efficiency.
        LibOrder.Order memory leftOrder = leftOrders[0];
        LibOrder.Order memory rightOrder = rightOrders[0];
        (, uint256 leftOrderTakerAssetFilledAmount) = _getOrderHashAndFilledAmount(leftOrder);
        (, uint256 rightOrderTakerAssetFilledAmount) = _getOrderHashAndFilledAmount(rightOrder);
        LibFillResults.FillResults memory leftFillResults;
        LibFillResults.FillResults memory rightFillResults;

        // Loop infinitely (until broken inside of the loop), but keep a counter of how
        // many orders have been matched.
        for (;;) {
            // Match the two orders that are pointed to by the left and right indices
            LibFillResults.MatchedFillResults memory matchResults = _matchOrders(
                leftOrder,
                rightOrder,
                leftSignatures[leftIdx],
                rightSignatures[rightIdx],
                shouldMaximallyFillOrders
            );

            // Update the order filled amounts with the updated takerAssetFilledAmount
            leftOrderTakerAssetFilledAmount = leftOrderTakerAssetFilledAmount.safeAdd(matchResults.left.takerAssetFilledAmount);
            rightOrderTakerAssetFilledAmount = rightOrderTakerAssetFilledAmount.safeAdd(matchResults.right.takerAssetFilledAmount);

            // Aggregate the new fill results with the previous fill results for the current orders.
            leftFillResults = LibFillResults.addFillResults(
                leftFillResults,
                matchResults.left
            );
            rightFillResults = LibFillResults.addFillResults(
                rightFillResults,
                matchResults.right
            );

            // Update the profit in the left and right maker assets using the profits from
            // the match.
            batchMatchedFillResults.profitInLeftMakerAsset = batchMatchedFillResults.profitInLeftMakerAsset.safeAdd(
                matchResults.profitInLeftMakerAsset
            );
            batchMatchedFillResults.profitInRightMakerAsset = batchMatchedFillResults.profitInRightMakerAsset.safeAdd(
                matchResults.profitInRightMakerAsset
            );

            // If the leftOrder is filled, update the leftIdx, leftOrder, and leftSignature,
            // or break out of the loop if there are no more leftOrders to match.
            if (leftOrderTakerAssetFilledAmount >= leftOrder.takerAssetAmount) {
                // Update the batched fill results once the leftIdx is updated.
                batchMatchedFillResults.left[leftIdx++] = leftFillResults;
                // Clear the intermediate fill results value.
                leftFillResults = LibFillResults.FillResults(0, 0, 0, 0, 0);

                // If all of the left orders have been filled, break out of the loop.
                // Otherwise, update the current right order.
                if (leftIdx == leftOrders.length) {
                    // Update the right batched fill results
                    batchMatchedFillResults.right[rightIdx] = rightFillResults;
                    break;
                } else {
                    leftOrder = leftOrders[leftIdx];
                    (, leftOrderTakerAssetFilledAmount) = _getOrderHashAndFilledAmount(leftOrder);
                }
            }

            // If the rightOrder is filled, update the rightIdx, rightOrder, and rightSignature,
            // or break out of the loop if there are no more rightOrders to match.
            if (rightOrderTakerAssetFilledAmount >= rightOrder.takerAssetAmount) {
                // Update the batched fill results once the rightIdx is updated.
                batchMatchedFillResults.right[rightIdx++] = rightFillResults;
                // Clear the intermediate fill results value.
                rightFillResults = LibFillResults.FillResults(0, 0, 0, 0, 0);

                // If all of the right orders have been filled, break out of the loop.
                // Otherwise, update the current right order.
                if (rightIdx == rightOrders.length) {
                    // Update the left batched fill results
                    batchMatchedFillResults.left[leftIdx] = leftFillResults;
                    break;
                } else {
                    rightOrder = rightOrders[rightIdx];
                    (, rightOrderTakerAssetFilledAmount) = _getOrderHashAndFilledAmount(rightOrder);
                }
            }
        }

        // Return the fill results from the batch match
        return batchMatchedFillResults;
    }

    
    ///      Each order is filled at their respective price point. However, the calculations are
    ///      carried out as though the orders are both being filled at the right order's price point.
    ///      The profit made by the left order goes to the taker (who matched the two orders). This
    ///      function is needed to allow for reentrant order matching (used by `batchMatchOrders` and
    ///      `batchMatchOrdersWithMaximalFill`).
    
    
    
    
    
    
    function _matchOrders(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        bytes memory leftSignature,
        bytes memory rightSignature,
        bool shouldMaximallyFillOrders
    )
        internal
        returns (LibFillResults.MatchedFillResults memory matchedFillResults)
    {
        // We assume that rightOrder.takerAssetData == leftOrder.makerAssetData and rightOrder.makerAssetData == leftOrder.takerAssetData
        // by pointing these values to the same location in memory. This is cheaper than checking equality.
        // If this assumption isn't true, the match will fail at signature validation.
        rightOrder.makerAssetData = leftOrder.takerAssetData;
        rightOrder.takerAssetData = leftOrder.makerAssetData;

        // Get left & right order info
        LibOrder.OrderInfo memory leftOrderInfo = getOrderInfo(leftOrder);
        LibOrder.OrderInfo memory rightOrderInfo = getOrderInfo(rightOrder);

        // Fetch taker address
        address takerAddress = _getCurrentContextAddress();

        // Either our context is valid or we revert
        _assertFillableOrder(
            leftOrder,
            leftOrderInfo,
            takerAddress,
            leftSignature
        );
        _assertFillableOrder(
            rightOrder,
            rightOrderInfo,
            takerAddress,
            rightSignature
        );
        _assertValidMatch(
            leftOrder,
            rightOrder,
            leftOrderInfo.orderHash,
            rightOrderInfo.orderHash
        );

        // Compute proportional fill amounts
        matchedFillResults = LibFillResults.calculateMatchedFillResults(
            leftOrder,
            rightOrder,
            leftOrderInfo.orderTakerAssetFilledAmount,
            rightOrderInfo.orderTakerAssetFilledAmount,
            protocolFeeMultiplier,
            tx.gasprice,
            shouldMaximallyFillOrders
        );

        // Update exchange state
        _updateFilledState(
            leftOrder,
            takerAddress,
            leftOrderInfo.orderHash,
            leftOrderInfo.orderTakerAssetFilledAmount,
            matchedFillResults.left
        );
        _updateFilledState(
            rightOrder,
            takerAddress,
            rightOrderInfo.orderHash,
            rightOrderInfo.orderTakerAssetFilledAmount,
            matchedFillResults.right
        );

        // Settle matched orders. Succeeds or throws.
        _settleMatchedOrders(
            leftOrderInfo.orderHash,
            rightOrderInfo.orderHash,
            leftOrder,
            rightOrder,
            takerAddress,
            matchedFillResults
        );

        return matchedFillResults;
    }

    
    
    
    
    
    
    
    function _settleMatchedOrders(
        bytes32 leftOrderHash,
        bytes32 rightOrderHash,
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        address takerAddress,
        LibFillResults.MatchedFillResults memory matchedFillResults
    )
        internal
    {
        address leftMakerAddress = leftOrder.makerAddress;
        address rightMakerAddress = rightOrder.makerAddress;
        address leftFeeRecipientAddress = leftOrder.feeRecipientAddress;
        address rightFeeRecipientAddress = rightOrder.feeRecipientAddress;
        uint256 assetId;
        uint256 leftTaker4KMarketFee = 0;
        if (feesManager != address(0)) {
            assetId = _getMakerAssetId(leftOrder.makerAssetData);
            leftTaker4KMarketFee = IFeesManager(feesManager).calculateFee(assetId, matchedFillResults.left.takerAssetFilledAmount);
        }
        matchedFillResults.left.takerAssetFilledAmount = matchedFillResults.left.takerAssetFilledAmount.safeSub(leftTaker4KMarketFee); 

        uint256 rightTaker4KMarketFee = 0;
        if (feesManager != address(0)) {
            assetId = _getMakerAssetId(rightOrder.makerAssetData);
            rightTaker4KMarketFee = IFeesManager(feesManager).calculateFee(assetId, matchedFillResults.right.takerAssetFilledAmount);
        }
        matchedFillResults.right.takerAssetFilledAmount = matchedFillResults.right.takerAssetFilledAmount.safeSub(rightTaker4KMarketFee); 

        // Right maker asset -> left maker
        _dispatchTransferFrom(
            rightOrderHash,
            rightOrder.makerAssetData,
            rightMakerAddress,
            leftMakerAddress,
            matchedFillResults.left.takerAssetFilledAmount
        );

        // Left maker asset -> right maker
        _dispatchTransferFrom(
            leftOrderHash,
            leftOrder.makerAssetData,
            leftMakerAddress,
            rightMakerAddress,
            matchedFillResults.right.takerAssetFilledAmount
        );

        // Right maker fee -> right fee recipient
        _dispatchTransferFrom(
            rightOrderHash,
            rightOrder.makerFeeAssetData,
            rightMakerAddress,
            rightFeeRecipientAddress,
            matchedFillResults.right.makerFeePaid
        );

        // Left maker fee -> left fee recipient
        _dispatchTransferFrom(
            leftOrderHash,
            leftOrder.makerFeeAssetData,
            leftMakerAddress,
            leftFeeRecipientAddress,
            matchedFillResults.left.makerFeePaid
        );

        // Settle taker profits.
        _dispatchTransferFrom(
            leftOrderHash,
            leftOrder.makerAssetData,
            leftMakerAddress,
            takerAddress,
            matchedFillResults.profitInLeftMakerAsset
        );
        _dispatchTransferFrom(
            rightOrderHash,
            rightOrder.makerAssetData,
            rightMakerAddress,
            takerAddress,
            matchedFillResults.profitInRightMakerAsset
        );

        // Pay protocol fees for each maker
        bool didPayProtocolFees = _payTwoProtocolFees(
            leftOrderHash,
            rightOrderHash,
            matchedFillResults.left.protocolFeePaid,
            leftMakerAddress,
            rightMakerAddress,
            takerAddress
        );

        // Protocol fees are not paid if the protocolFeeCollector contract is not set
        if (!didPayProtocolFees) {
            matchedFillResults.left.protocolFeePaid = 0;
            matchedFillResults.right.protocolFeePaid = 0;
        }

        // Settle taker fees.
        if (
            leftFeeRecipientAddress == rightFeeRecipientAddress &&
            leftOrder.takerFeeAssetData.equals(rightOrder.takerFeeAssetData)
        ) {
            // Fee recipients and taker fee assets are identical, so we can
            // transfer them in one go.
            _dispatchTransferFrom(
                leftOrderHash,
                leftOrder.takerFeeAssetData,
                takerAddress,
                leftFeeRecipientAddress,
                matchedFillResults.left.takerFeePaid.safeAdd(matchedFillResults.right.takerFeePaid)
            );
        } else {
            // Right taker fee -> right fee recipient
            _dispatchTransferFrom(
                rightOrderHash,
                rightOrder.takerFeeAssetData,
                takerAddress,
                rightFeeRecipientAddress,
                matchedFillResults.right.takerFeePaid
            );

            // Left taker fee -> left fee recipient
            _dispatchTransferFrom(
                leftOrderHash,
                leftOrder.takerFeeAssetData,
                takerAddress,
                leftFeeRecipientAddress,
                matchedFillResults.left.takerFeePaid
            );
        }

        // Settle 4K FeesManager fees.
        if (feesManager != address(0)) {
            if (
                leftOrder.takerFeeAssetData.equals(rightOrder.takerFeeAssetData)
            ) {
                // Fee recipients and taker fee assets are identical, so we can
                // transfer them in one go.
                _dispatchTransferFrom(
                    leftOrderHash,
                    leftOrder.takerFeeAssetData,
                    takerAddress,
                    feesManager,
                    matchedFillResults.right.takerAssetFilledAmount.safeAdd(leftTaker4KMarketFee)
                );

                assetId = _getMakerAssetId(leftOrder.makerAssetData);
                address tokenAddress = _getTokenAddress(leftOrder.takerFeeAssetData);

                IFeesManager(feesManager).receiveFees(assetId, leftOrder.makerAddress,
                    tokenAddress, rightTaker4KMarketFee.safeAdd(leftTaker4KMarketFee));
            } else {
                // Right taker fee -> right fee recipient
                _dispatchTransferFrom(
                    rightOrderHash,
                    rightOrder.takerFeeAssetData,
                    takerAddress,
                    feesManager,
                    rightTaker4KMarketFee
                );

                assetId = _getMakerAssetId(rightOrder.makerAssetData);
                address tokenAddress = _getTokenAddress(rightOrder.takerFeeAssetData);

                IFeesManager(feesManager).receiveFees(assetId, rightOrder.makerAddress,
                    tokenAddress, rightTaker4KMarketFee);

                // Left taker fee -> left fee recipient
                _dispatchTransferFrom(
                    leftOrderHash,
                    leftOrder.takerFeeAssetData,
                    takerAddress,
                    feesManager,
                    leftTaker4KMarketFee
                );

                assetId = _getMakerAssetId(leftOrder.makerAssetData);
                tokenAddress = _getTokenAddress(leftOrder.takerFeeAssetData);

                IFeesManager(feesManager).receiveFees(assetId, leftOrder.makerAddress,
                    tokenAddress, leftTaker4KMarketFee);
            }
        }
    }
}

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

pragma solidity ^0.5.9;













contract MixinWrapperFunctions is
    IWrapperFunctions,
    MixinExchangeCore
{
    using LibSafeMath for uint256;

    
    
    
    
    
    function fillOrKillOrder(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        payable
        refundFinalBalanceNoReentry
        returns (LibFillResults.FillResults memory fillResults)
    {
        fillResults = _fillOrKillOrder(
            order,
            takerAssetFillAmount,
            signature
        );
        return fillResults;
    }

    
    
    
    
    
    function batchFillOrders(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        payable
        refundFinalBalanceNoReentry
        returns (LibFillResults.FillResults[] memory fillResults)
    {
        uint256 ordersLength = orders.length;
        fillResults = new LibFillResults.FillResults[](ordersLength);
        for (uint256 i = 0; i != ordersLength; i++) {
            fillResults[i] = _fillOrder(
                orders[i],
                takerAssetFillAmounts[i],
                signatures[i]
            );
        }
        return fillResults;
    }

    
    
    
    
    
    function batchFillOrKillOrders(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        payable
        refundFinalBalanceNoReentry
        returns (LibFillResults.FillResults[] memory fillResults)
    {
        uint256 ordersLength = orders.length;
        fillResults = new LibFillResults.FillResults[](ordersLength);
        for (uint256 i = 0; i != ordersLength; i++) {
            fillResults[i] = _fillOrKillOrder(
                orders[i],
                takerAssetFillAmounts[i],
                signatures[i]
            );
        }
        return fillResults;
    }

    
    
    
    
    
    function batchFillOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        payable
        disableRefundUntilEnd
        returns (LibFillResults.FillResults[] memory fillResults)
    {
        uint256 ordersLength = orders.length;
        fillResults = new LibFillResults.FillResults[](ordersLength);
        for (uint256 i = 0; i != ordersLength; i++) {
            fillResults[i] = _fillOrderNoThrow(
                orders[i],
                takerAssetFillAmounts[i],
                signatures[i]
            );
        }
        return fillResults;
    }

    
    ///      If any fill reverts, the error is caught and ignored.
    ///      NOTE: This function does not enforce that the takerAsset is the same for each order.
    
    
    
    
    function marketSellOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256 takerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        payable
        disableRefundUntilEnd
        returns (LibFillResults.FillResults memory fillResults)
    {
        uint256 ordersLength = orders.length;
        for (uint256 i = 0; i != ordersLength; i++) {

            // Calculate the remaining amount of takerAsset to sell
            uint256 remainingTakerAssetFillAmount = takerAssetFillAmount.safeSub(fillResults.takerAssetFilledAmount);

            // Attempt to sell the remaining amount of takerAsset
            LibFillResults.FillResults memory singleFillResults = _fillOrderNoThrow(
                orders[i],
                remainingTakerAssetFillAmount,
                signatures[i]
            );

            // Update amounts filled and fees paid by maker and taker
            fillResults = LibFillResults.addFillResults(fillResults, singleFillResults);

            // Stop execution if the entire amount of takerAsset has been sold
            if (fillResults.takerAssetFilledAmount >= takerAssetFillAmount) {
                break;
            }
        }
        return fillResults;
    }

    
    ///      If any fill reverts, the error is caught and ignored.
    ///      NOTE: This function does not enforce that the makerAsset is the same for each order.
    
    
    
    
    function marketBuyOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256 makerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        payable
        disableRefundUntilEnd
        returns (LibFillResults.FillResults memory fillResults)
    {
        uint256 ordersLength = orders.length;
        for (uint256 i = 0; i != ordersLength; i++) {

            // Calculate the remaining amount of makerAsset to buy
            uint256 remainingMakerAssetFillAmount = makerAssetFillAmount.safeSub(fillResults.makerAssetFilledAmount);

            // Convert the remaining amount of makerAsset to buy into remaining amount
            // of takerAsset to sell, assuming entire amount can be sold in the current order
            uint256 remainingTakerAssetFillAmount = LibMath.getPartialAmountCeil(
                orders[i].takerAssetAmount,
                orders[i].makerAssetAmount,
                remainingMakerAssetFillAmount
            );

            // Attempt to sell the remaining amount of takerAsset
            LibFillResults.FillResults memory singleFillResults = _fillOrderNoThrow(
                orders[i],
                remainingTakerAssetFillAmount,
                signatures[i]
            );

            // Update amounts filled and fees paid by maker and taker
            fillResults = LibFillResults.addFillResults(fillResults, singleFillResults);

            // Stop execution if the entire amount of makerAsset has been bought
            if (fillResults.makerAssetFilledAmount >= makerAssetFillAmount) {
                break;
            }
        }
        return fillResults;
    }

    
    ///      NOTE: This function does not enforce that the takerAsset is the same for each order.
    
    
    
    
    function marketSellOrdersFillOrKill(
        LibOrder.Order[] memory orders,
        uint256 takerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults memory fillResults)
    {
        fillResults = marketSellOrdersNoThrow(orders, takerAssetFillAmount, signatures);
        if (fillResults.takerAssetFilledAmount < takerAssetFillAmount) {
            LibRichErrors.rrevert(LibExchangeRichErrors.IncompleteFillError(
                LibExchangeRichErrors.IncompleteFillErrorCode.INCOMPLETE_MARKET_SELL_ORDERS,
                takerAssetFillAmount,
                fillResults.takerAssetFilledAmount
            ));
        }
    }

    
    ///      NOTE: This function does not enforce that the makerAsset is the same for each order.
    
    
    
    
    function marketBuyOrdersFillOrKill(
        LibOrder.Order[] memory orders,
        uint256 makerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults memory fillResults)
    {
        fillResults = marketBuyOrdersNoThrow(orders, makerAssetFillAmount, signatures);
        if (fillResults.makerAssetFilledAmount < makerAssetFillAmount) {
            LibRichErrors.rrevert(LibExchangeRichErrors.IncompleteFillError(
                LibExchangeRichErrors.IncompleteFillErrorCode.INCOMPLETE_MARKET_BUY_ORDERS,
                makerAssetFillAmount,
                fillResults.makerAssetFilledAmount
            ));
        }
    }

    
    
    function batchCancelOrders(LibOrder.Order[] memory orders)
        public
        payable
        refundFinalBalanceNoReentry
    {
        uint256 ordersLength = orders.length;
        for (uint256 i = 0; i != ordersLength; i++) {
            _cancelOrder(orders[i]);
        }
    }

    
    
    
    
    function _fillOrKillOrder(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        internal
        returns (LibFillResults.FillResults memory fillResults)
    {
        fillResults = _fillOrder(
            order,
            takerAssetFillAmount,
            signature
        );
        if (fillResults.takerAssetFilledAmount != takerAssetFillAmount) {
            LibRichErrors.rrevert(LibExchangeRichErrors.IncompleteFillError(
                LibExchangeRichErrors.IncompleteFillErrorCode.INCOMPLETE_FILL_ORDER,
                takerAssetFillAmount,
                fillResults.takerAssetFilledAmount
            ));
        }
        return fillResults;
    }

    
    ///      Returns a null FillResults instance if the transaction would otherwise revert.
    
    
    
    
    function _fillOrderNoThrow(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        internal
        returns (LibFillResults.FillResults memory fillResults)
    {
        // ABI encode calldata for `fillOrder`
        bytes memory fillOrderCalldata = abi.encodeWithSelector(
            IExchangeCore(address(0)).fillOrder.selector,
            order,
            takerAssetFillAmount,
            signature
        );

        (bool didSucceed, bytes memory returnData) = address(this).delegatecall(fillOrderCalldata);
        if (didSucceed) {
            assert(returnData.length == 160);
            fillResults = abi.decode(returnData, (LibFillResults.FillResults));
        }
        // fillResults values will be 0 by default if call was unsuccessful
        return fillResults;
    }
}

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

pragma solidity ^0.5.9;





contract MixinTransferSimulator is
    MixinAssetProxyDispatcher
{
    
    /// As they would occur through the Exchange contract. Note that this function
    /// will always revert, even if all transfers are successful. However, it may
    /// be used with eth_call or with a try/catch pattern in order to simulate
    /// the results of the transfers.
    
    
    
    
    
    /// `Error("TRANSFERS_SUCCESSFUL")` if all of the transfers were successful.
    function simulateDispatchTransferFromCalls(
        bytes[] memory assetData,
        address[] memory fromAddresses,
        address[] memory toAddresses,
        uint256[] memory amounts
    )
        public
    {
        uint256 length = assetData.length;
        for (uint256 i = 0; i != length; i++) {
            _dispatchTransferFrom(
                // The index is passed in as `orderHash` so that a failed transfer can be quickly identified when catching the error
                bytes32(i),
                assetData[i],
                fromAddresses[i],
                toAddresses[i],
                amounts[i]
            );
        }
        revert("TRANSFERS_SUCCESSFUL");
    }
}

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

pragma solidity ^0.5.9;


contract IERC20Token {

    // solhint-disable no-simple-event-func-name
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    
    
    
    
    function transfer(address _to, uint256 _value)
        external
        returns (bool);

    
    
    
    
    
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        external
        returns (bool);

    
    
    
    
    function approve(address _spender, uint256 _value)
        external
        returns (bool);

    
    
    function totalSupply()
        external
        view
        returns (uint256);

    
    
    function balanceOf(address _owner)
        external
        view
        returns (uint256);

    
    
    
    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256);
}
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

pragma solidity ^0.5.9;








// solhint-disable no-empty-blocks
// MixinAssetProxyDispatcher, MixinExchangeCore, MixinSignatureValidator,
// and MixinTransactions are all inherited via the other Mixins that are
// used.

contract Exchange is
    LibEIP712ExchangeDomain,
    MixinMatchOrders,
    MixinWrapperFunctions,
    MixinTransferSimulator
{
    
    
    constructor (uint256 chainId)
        public
        LibEIP712ExchangeDomain(chainId, address(0))
    {}
}

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

pragma solidity ^0.5.9;


library LibEIP712 {

    // Hash of the EIP712 Domain Separator Schema
    // keccak256(abi.encodePacked(
    //     "EIP712Domain(",
    //     "string name,",
    //     "string version,",
    //     "uint256 chainId,",
    //     "address verifyingContract",
    //     ")"
    // ))
    bytes32 constant internal _EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    
    
    
    
    
    function hashEIP712Domain(
        string memory name,
        string memory version,
        uint256 chainId,
        address verifyingContract
    )
        internal
        pure
        returns (bytes32 result)
    {
        bytes32 schemaHash = _EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH;

        // Assembly for more efficient computing:
        // keccak256(abi.encodePacked(
        //     _EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH,
        //     keccak256(bytes(name)),
        //     keccak256(bytes(version)),
        //     chainId,
        //     uint256(verifyingContract)
        // ))

        assembly {
            // Calculate hashes of dynamic data
            let nameHash := keccak256(add(name, 32), mload(name))
            let versionHash := keccak256(add(version, 32), mload(version))

            // Load free memory pointer
            let memPtr := mload(64)

            // Store params in memory
            mstore(memPtr, schemaHash)
            mstore(add(memPtr, 32), nameHash)
            mstore(add(memPtr, 64), versionHash)
            mstore(add(memPtr, 96), chainId)
            mstore(add(memPtr, 128), verifyingContract)

            // Compute hash
            result := keccak256(memPtr, 160)
        }
        return result;
    }

    
    
    ///                         with getDomainHash().
    
    
    function hashEIP712Message(bytes32 eip712DomainHash, bytes32 hashStruct)
        internal
        pure
        returns (bytes32 result)
    {
        // Assembly for more efficient computing:
        // keccak256(abi.encodePacked(
        //     EIP191_HEADER,
        //     EIP712_DOMAIN_HASH,
        //     hashStruct
        // ));

        assembly {
            // Load free memory pointer
            let memPtr := mload(64)

            mstore(memPtr, 0x1901000000000000000000000000000000000000000000000000000000000000)  // EIP191 header
            mstore(add(memPtr, 2), eip712DomainHash)                                            // EIP712 domain hash
            mstore(add(memPtr, 34), hashStruct)                                                 // Hash of struct

            // Compute hash
            result := keccak256(memPtr, 66)
        }
        return result;
    }
}

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

pragma solidity ^0.5.9;





library LibBytes {

    using LibBytes for bytes;

    
    
    
    ///         points to the header of the byte array which contains
    ///         the length.
    function rawAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := input
        }
        return memoryAddress;
    }

    
    
    
    function contentAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := add(input, 32)
        }
        return memoryAddress;
    }

    
    
    
    
    function memCopy(
        uint256 dest,
        uint256 source,
        uint256 length
    )
        internal
        pure
    {
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
                    for {} lt(source, sEnd) {} {
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
                    for {} slt(dest, dEnd) {} {
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
    )
        internal
        pure
        returns (bytes memory result)
    {
        // Ensure that the from and to positions are valid positions for a slice within
        // the byte array that is being used.
        if (from > to) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                from,
                to
            ));
        }
        if (to > b.length) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                to,
                b.length
            ));
        }

        // Create a new bytes structure and copy contents
        result = new bytes(to - from);
        memCopy(
            result.contentAddress(),
            b.contentAddress() + from,
            result.length
        );
        return result;
    }

    
    
    
    
    
    
    function sliceDestructive(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        // Ensure that the from and to positions are valid positions for a slice within
        // the byte array that is being used.
        if (from > to) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                from,
                to
            ));
        }
        if (to > b.length) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                to,
                b.length
            ));
        }

        // Create a new bytes structure around [from, to) in-place.
        assembly {
            result := add(b, from)
            mstore(result, sub(to, from))
        }
        return result;
    }

    
    
    
    function popLastByte(bytes memory b)
        internal
        pure
        returns (bytes1 result)
    {
        if (b.length == 0) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanZeroRequired,
                b.length,
                0
            ));
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

    
    
    
    
    function equals(
        bytes memory lhs,
        bytes memory rhs
    )
        internal
        pure
        returns (bool equal)
    {
        // Keccak gas cost is 30 + numWords * 6. This is a cheap way to compare.
        // We early exit on unequal lengths, but keccak would also correctly
        // handle this.
        return lhs.length == rhs.length && keccak256(lhs) == keccak256(rhs);
    }

    
    
    
    
    function readAddress(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (address result)
    {
        if (b.length < index + 20) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                b.length,
                index + 20 // 20 is length of address
            ));
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
    )
        internal
        pure
    {
        if (b.length < index + 20) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                b.length,
                index + 20 // 20 is length of address
            ));
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

    
    
    
    
    function readBytes32(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes32 result)
    {
        if (b.length < index + 32) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                b.length,
                index + 32
            ));
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
    )
        internal
        pure
    {
        if (b.length < index + 32) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                b.length,
                index + 32
            ));
        }

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            mstore(add(b, index), input)
        }
    }

    
    
    
    
    function readUint256(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (uint256 result)
    {
        result = uint256(readBytes32(b, index));
        return result;
    }

    
    
    
    
    function writeUint256(
        bytes memory b,
        uint256 index,
        uint256 input
    )
        internal
        pure
    {
        writeBytes32(b, index, bytes32(input));
    }

    
    
    
    
    function readBytes4(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes4 result)
    {
        if (b.length < index + 4) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsFourRequired,
                b.length,
                index + 4
            ));
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
    
    
    function writeLength(bytes memory b, uint256 length)
        internal
        pure
    {
        assembly {
            mstore(b, length)
        }
    }
}

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

pragma solidity ^0.5.9;


library LibRichErrors {

    // bytes4(keccak256("Error(string)"))
    bytes4 internal constant STANDARD_ERROR_SELECTOR =
        0x08c379a0;

    // solhint-disable func-name-mixedcase
    
    ///      This is the same payload that would be included by a `revert(string)`
    ///      solidity statement. It has the function signature `Error(string)`.
    
    
    function StandardError(
        string memory message
    )
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

pragma solidity ^0.5.9;




library LibOrder {

    using LibOrder for Order;

    // Hash for the EIP712 Order Schema:
    // keccak256(abi.encodePacked(
    //     "Order(",
    //     "address makerAddress,",
    //     "address takerAddress,",
    //     "address feeRecipientAddress,",
    //     "address senderAddress,",
    //     "uint256 makerAssetAmount,",
    //     "uint256 takerAssetAmount,",
    //     "uint256 makerFee,",
    //     "uint256 takerFee,",
    //     "uint256 expirationTimeSeconds,",
    //     "uint256 salt,",
    //     "bytes makerAssetData,",
    //     "bytes takerAssetData,",
    //     "bytes makerFeeAssetData,",
    //     "bytes takerFeeAssetData",
    //     ")"
    // ))
    bytes32 constant internal _EIP712_ORDER_SCHEMA_HASH =
        0xf80322eb8376aafb64eadf8f0d7623f22130fd9491a221e902b713cb984a7534;

    // A valid order remains fillable until it is expired, fully filled, or cancelled.
    // An order's status is unaffected by external factors, like account balances.
    enum OrderStatus {
        INVALID,                     // Default value
        INVALID_MAKER_ASSET_AMOUNT,  // Order does not have a valid maker asset amount
        INVALID_TAKER_ASSET_AMOUNT,  // Order does not have a valid taker asset amount
        FILLABLE,                    // Order is fillable
        EXPIRED,                     // Order has already expired
        FULLY_FILLED,                // Order is fully filled
        CANCELLED                    // Order has been cancelled
    }

    // solhint-disable max-line-length
    
    struct Order {
        address makerAddress;           // Address that created the order.
        address takerAddress;           // Address that is allowed to fill the order. If set to 0, any address is allowed to fill the order.
        address feeRecipientAddress;    // Address that will recieve fees when order is filled.
        address senderAddress;          // Address that is allowed to call Exchange contract methods that affect this order. If set to 0, any address is allowed to call these methods.
        uint256 makerAssetAmount;       // Amount of makerAsset being offered by maker. Must be greater than 0.
        uint256 takerAssetAmount;       // Amount of takerAsset being bid on by maker. Must be greater than 0.
        uint256 makerFee;               // Fee paid to feeRecipient by maker when order is filled.
        uint256 takerFee;               // Fee paid to feeRecipient by taker when order is filled.
        uint256 expirationTimeSeconds;  // Timestamp in seconds at which order expires.
        uint256 salt;                   // Arbitrary number to facilitate uniqueness of the order's hash.
        bytes makerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring makerAsset. The leading bytes4 references the id of the asset proxy.
        bytes takerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring takerAsset. The leading bytes4 references the id of the asset proxy.
        bytes makerFeeAssetData;        // Encoded data that can be decoded by a specified proxy contract when transferring makerFeeAsset. The leading bytes4 references the id of the asset proxy.
        bytes takerFeeAssetData;        // Encoded data that can be decoded by a specified proxy contract when transferring takerFeeAsset. The leading bytes4 references the id of the asset proxy.
    }
    // solhint-enable max-line-length

    
    struct OrderInfo {
        OrderStatus orderStatus;                    // Status that describes order's validity and fillability.
        bytes32 orderHash;                    // EIP712 typed data hash of the order (see LibOrder.getTypedDataHash).
        uint256 orderTakerAssetFilledAmount;  // Amount of order that has already been filled.
    }

    
    
    
    function getTypedDataHash(Order memory order, bytes32 eip712ExchangeDomainHash)
        internal
        pure
        returns (bytes32 orderHash)
    {
        orderHash = LibEIP712.hashEIP712Message(
            eip712ExchangeDomainHash,
            order.getStructHash()
        );
        return orderHash;
    }

    
    
    
    function getStructHash(Order memory order)
        internal
        pure
        returns (bytes32 result)
    {
        bytes32 schemaHash = _EIP712_ORDER_SCHEMA_HASH;
        bytes memory makerAssetData = order.makerAssetData;
        bytes memory takerAssetData = order.takerAssetData;
        bytes memory makerFeeAssetData = order.makerFeeAssetData;
        bytes memory takerFeeAssetData = order.takerFeeAssetData;

        // Assembly for more efficiently computing:
        // keccak256(abi.encodePacked(
        //     EIP712_ORDER_SCHEMA_HASH,
        //     uint256(order.makerAddress),
        //     uint256(order.takerAddress),
        //     uint256(order.feeRecipientAddress),
        //     uint256(order.senderAddress),
        //     order.makerAssetAmount,
        //     order.takerAssetAmount,
        //     order.makerFee,
        //     order.takerFee,
        //     order.expirationTimeSeconds,
        //     order.salt,
        //     keccak256(order.makerAssetData),
        //     keccak256(order.takerAssetData),
        //     keccak256(order.makerFeeAssetData),
        //     keccak256(order.takerFeeAssetData)
        // ));

        assembly {
            // Assert order offset (this is an internal error that should never be triggered)
            if lt(order, 32) {
                invalid()
            }

            // Calculate memory addresses that will be swapped out before hashing
            let pos1 := sub(order, 32)
            let pos2 := add(order, 320)
            let pos3 := add(order, 352)
            let pos4 := add(order, 384)
            let pos5 := add(order, 416)

            // Backup
            let temp1 := mload(pos1)
            let temp2 := mload(pos2)
            let temp3 := mload(pos3)
            let temp4 := mload(pos4)
            let temp5 := mload(pos5)

            // Hash in place
            mstore(pos1, schemaHash)
            mstore(pos2, keccak256(add(makerAssetData, 32), mload(makerAssetData)))        // store hash of makerAssetData
            mstore(pos3, keccak256(add(takerAssetData, 32), mload(takerAssetData)))        // store hash of takerAssetData
            mstore(pos4, keccak256(add(makerFeeAssetData, 32), mload(makerFeeAssetData)))  // store hash of makerFeeAssetData
            mstore(pos5, keccak256(add(takerFeeAssetData, 32), mload(takerFeeAssetData)))  // store hash of takerFeeAssetData
            result := keccak256(pos1, 480)

            // Restore
            mstore(pos1, temp1)
            mstore(pos2, temp2)
            mstore(pos3, temp3)
            mstore(pos4, temp4)
            mstore(pos5, temp5)
        }
        return result;
    }
}

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

pragma solidity ^0.5.9;






library LibFillResults {

    using LibSafeMath for uint256;

    struct BatchMatchedFillResults {
        FillResults[] left;              // Fill results for left orders
        FillResults[] right;             // Fill results for right orders
        uint256 profitInLeftMakerAsset;  // Profit taken from left makers
        uint256 profitInRightMakerAsset; // Profit taken from right makers
    }

    struct FillResults {
        uint256 makerAssetFilledAmount;  // Total amount of makerAsset(s) filled.
        uint256 takerAssetFilledAmount;  // Total amount of takerAsset(s) filled.
        uint256 makerFeePaid;            // Total amount of fees paid by maker(s) to feeRecipient(s).
        uint256 takerFeePaid;            // Total amount of fees paid by taker to feeRecipients(s).
        uint256 protocolFeePaid;         // Total amount of fees paid by taker to the staking contract.
    }

    struct MatchedFillResults {
        FillResults left;                // Amounts filled and fees paid of left order.
        FillResults right;               // Amounts filled and fees paid of right order.
        uint256 profitInLeftMakerAsset;  // Profit taken from the left maker
        uint256 profitInRightMakerAsset; // Profit taken from the right maker
    }

    
    
    
    
    
    ///        to be pure rather than view.
    
    function calculateFillResults(
        LibOrder.Order memory order,
        uint256 takerAssetFilledAmount,
        uint256 protocolFeeMultiplier,
        uint256 gasPrice
    )
        internal
        pure
        returns (FillResults memory fillResults)
    {
        // Compute proportional transfer amounts
        fillResults.takerAssetFilledAmount = takerAssetFilledAmount;
        fillResults.makerAssetFilledAmount = LibMath.safeGetPartialAmountFloor(
            takerAssetFilledAmount,
            order.takerAssetAmount,
            order.makerAssetAmount
        );
        fillResults.makerFeePaid = LibMath.safeGetPartialAmountFloor(
            takerAssetFilledAmount,
            order.takerAssetAmount,
            order.makerFee
        );
        fillResults.takerFeePaid = LibMath.safeGetPartialAmountFloor(
            takerAssetFilledAmount,
            order.takerAssetAmount,
            order.takerFee
        );

        // Compute the protocol fee that should be paid for a single fill.
        fillResults.protocolFeePaid = gasPrice.safeMul(protocolFeeMultiplier);

        return fillResults;
    }

    
    ///      Each order is filled at their respective price point. However, the calculations are
    ///      carried out as though the orders are both being filled at the right order's price point.
    ///      The profit made by the leftOrder order goes to the taker (who matched the two orders).
    
    
    
    
    
    
    ///        to be pure rather than view.
    
    ///                                  the maximal fill order matching strategy.
    
    function calculateMatchedFillResults(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        uint256 leftOrderTakerAssetFilledAmount,
        uint256 rightOrderTakerAssetFilledAmount,
        uint256 protocolFeeMultiplier,
        uint256 gasPrice,
        bool shouldMaximallyFillOrders
    )
        internal
        pure
        returns (MatchedFillResults memory matchedFillResults)
    {
        // Derive maker asset amounts for left & right orders, given store taker assert amounts
        uint256 leftTakerAssetAmountRemaining = leftOrder.takerAssetAmount.safeSub(leftOrderTakerAssetFilledAmount);
        uint256 leftMakerAssetAmountRemaining = LibMath.safeGetPartialAmountFloor(
            leftOrder.makerAssetAmount,
            leftOrder.takerAssetAmount,
            leftTakerAssetAmountRemaining
        );
        uint256 rightTakerAssetAmountRemaining = rightOrder.takerAssetAmount.safeSub(rightOrderTakerAssetFilledAmount);
        uint256 rightMakerAssetAmountRemaining = LibMath.safeGetPartialAmountFloor(
            rightOrder.makerAssetAmount,
            rightOrder.takerAssetAmount,
            rightTakerAssetAmountRemaining
        );

        // Maximally fill the orders and pay out profits to the matcher in one or both of the maker assets.
        if (shouldMaximallyFillOrders) {
            matchedFillResults = _calculateMatchedFillResultsWithMaximalFill(
                leftOrder,
                rightOrder,
                leftMakerAssetAmountRemaining,
                leftTakerAssetAmountRemaining,
                rightMakerAssetAmountRemaining,
                rightTakerAssetAmountRemaining
            );
        } else {
            matchedFillResults = _calculateMatchedFillResults(
                leftOrder,
                rightOrder,
                leftMakerAssetAmountRemaining,
                leftTakerAssetAmountRemaining,
                rightMakerAssetAmountRemaining,
                rightTakerAssetAmountRemaining
            );
        }

        // Compute fees for left order
        matchedFillResults.left.makerFeePaid = LibMath.safeGetPartialAmountFloor(
            matchedFillResults.left.makerAssetFilledAmount,
            leftOrder.makerAssetAmount,
            leftOrder.makerFee
        );
        matchedFillResults.left.takerFeePaid = LibMath.safeGetPartialAmountFloor(
            matchedFillResults.left.takerAssetFilledAmount,
            leftOrder.takerAssetAmount,
            leftOrder.takerFee
        );

        // Compute fees for right order
        matchedFillResults.right.makerFeePaid = LibMath.safeGetPartialAmountFloor(
            matchedFillResults.right.makerAssetFilledAmount,
            rightOrder.makerAssetAmount,
            rightOrder.makerFee
        );
        matchedFillResults.right.takerFeePaid = LibMath.safeGetPartialAmountFloor(
            matchedFillResults.right.takerAssetFilledAmount,
            rightOrder.takerAssetAmount,
            rightOrder.takerFee
        );

        // Compute the protocol fee that should be paid for a single fill. In this
        // case this should be made the protocol fee for both the left and right orders.
        uint256 protocolFee = gasPrice.safeMul(protocolFeeMultiplier);
        matchedFillResults.left.protocolFeePaid = protocolFee;
        matchedFillResults.right.protocolFeePaid = protocolFee;

        // Return fill results
        return matchedFillResults;
    }

    
    
    
    
    function addFillResults(
        FillResults memory fillResults1,
        FillResults memory fillResults2
    )
        internal
        pure
        returns (FillResults memory totalFillResults)
    {
        totalFillResults.makerAssetFilledAmount = fillResults1.makerAssetFilledAmount.safeAdd(fillResults2.makerAssetFilledAmount);
        totalFillResults.takerAssetFilledAmount = fillResults1.takerAssetFilledAmount.safeAdd(fillResults2.takerAssetFilledAmount);
        totalFillResults.makerFeePaid = fillResults1.makerFeePaid.safeAdd(fillResults2.makerFeePaid);
        totalFillResults.takerFeePaid = fillResults1.takerFeePaid.safeAdd(fillResults2.takerFeePaid);
        totalFillResults.protocolFeePaid = fillResults1.protocolFeePaid.safeAdd(fillResults2.protocolFeePaid);

        return totalFillResults;
    }

    
    ///      awards profit denominated in the left maker asset.
    
    
    
    
    
    
    
    function _calculateMatchedFillResults(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        uint256 leftMakerAssetAmountRemaining,
        uint256 leftTakerAssetAmountRemaining,
        uint256 rightMakerAssetAmountRemaining,
        uint256 rightTakerAssetAmountRemaining
    )
        private
        pure
        returns (MatchedFillResults memory matchedFillResults)
    {
        // Calculate fill results for maker and taker assets: at least one order will be fully filled.
        // The maximum amount the left maker can buy is `leftTakerAssetAmountRemaining`
        // The maximum amount the right maker can sell is `rightMakerAssetAmountRemaining`
        // We have two distinct cases for calculating the fill results:
        // Case 1.
        //   If the left maker can buy more than the right maker can sell, then only the right order is fully filled.
        //   If the left maker can buy exactly what the right maker can sell, then both orders are fully filled.
        // Case 2.
        //   If the left maker cannot buy more than the right maker can sell, then only the left order is fully filled.
        // Case 3.
        //   If the left maker can buy exactly as much as the right maker can sell, then both orders are fully filled.
        if (leftTakerAssetAmountRemaining > rightMakerAssetAmountRemaining) {
            // Case 1: Right order is fully filled
            matchedFillResults = _calculateCompleteRightFill(
                leftOrder,
                rightMakerAssetAmountRemaining,
                rightTakerAssetAmountRemaining
            );
        } else if (leftTakerAssetAmountRemaining < rightMakerAssetAmountRemaining) {
            // Case 2: Left order is fully filled
            matchedFillResults.left.makerAssetFilledAmount = leftMakerAssetAmountRemaining;
            matchedFillResults.left.takerAssetFilledAmount = leftTakerAssetAmountRemaining;
            matchedFillResults.right.makerAssetFilledAmount = leftTakerAssetAmountRemaining;
            // Round up to ensure the maker's exchange rate does not exceed the price specified by the order.
            // We favor the maker when the exchange rate must be rounded.
            matchedFillResults.right.takerAssetFilledAmount = LibMath.safeGetPartialAmountCeil(
                rightOrder.takerAssetAmount,
                rightOrder.makerAssetAmount,
                leftTakerAssetAmountRemaining // matchedFillResults.right.makerAssetFilledAmount
            );
        } else {
            // leftTakerAssetAmountRemaining == rightMakerAssetAmountRemaining
            // Case 3: Both orders are fully filled. Technically, this could be captured by the above cases, but
            //         this calculation will be more precise since it does not include rounding.
            matchedFillResults = _calculateCompleteFillBoth(
                leftMakerAssetAmountRemaining,
                leftTakerAssetAmountRemaining,
                rightMakerAssetAmountRemaining,
                rightTakerAssetAmountRemaining
            );
        }

        // Calculate amount given to taker
        matchedFillResults.profitInLeftMakerAsset = matchedFillResults.left.makerAssetFilledAmount.safeSub(
            matchedFillResults.right.takerAssetFilledAmount
        );

        return matchedFillResults;
    }

    
    ///      strategy.
    
    
    
    
    
    
    
    function _calculateMatchedFillResultsWithMaximalFill(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        uint256 leftMakerAssetAmountRemaining,
        uint256 leftTakerAssetAmountRemaining,
        uint256 rightMakerAssetAmountRemaining,
        uint256 rightTakerAssetAmountRemaining
    )
        private
        pure
        returns (MatchedFillResults memory matchedFillResults)
    {
        // If a maker asset is greater than the opposite taker asset, than there will be a spread denominated in that maker asset.
        bool doesLeftMakerAssetProfitExist = leftMakerAssetAmountRemaining > rightTakerAssetAmountRemaining;
        bool doesRightMakerAssetProfitExist = rightMakerAssetAmountRemaining > leftTakerAssetAmountRemaining;

        // Calculate the maximum fill results for the maker and taker assets. At least one of the orders will be fully filled.
        //
        // The maximum that the left maker can possibly buy is the amount that the right order can sell.
        // The maximum that the right maker can possibly buy is the amount that the left order can sell.
        //
        // If the left order is fully filled, profit will be paid out in the left maker asset. If the right order is fully filled,
        // the profit will be out in the right maker asset.
        //
        // There are three cases to consider:
        // Case 1.
        //   If the left maker can buy more than the right maker can sell, then only the right order is fully filled.
        // Case 2.
        //   If the right maker can buy more than the left maker can sell, then only the right order is fully filled.
        // Case 3.
        //   If the right maker can sell the max of what the left maker can buy and the left maker can sell the max of
        //   what the right maker can buy, then both orders are fully filled.
        if (leftTakerAssetAmountRemaining > rightMakerAssetAmountRemaining) {
            // Case 1: Right order is fully filled with the profit paid in the left makerAsset
            matchedFillResults = _calculateCompleteRightFill(
                leftOrder,
                rightMakerAssetAmountRemaining,
                rightTakerAssetAmountRemaining
            );
        } else if (rightTakerAssetAmountRemaining > leftMakerAssetAmountRemaining) {
            // Case 2: Left order is fully filled with the profit paid in the right makerAsset.
            matchedFillResults.left.makerAssetFilledAmount = leftMakerAssetAmountRemaining;
            matchedFillResults.left.takerAssetFilledAmount = leftTakerAssetAmountRemaining;
            // Round down to ensure the right maker's exchange rate does not exceed the price specified by the order.
            // We favor the right maker when the exchange rate must be rounded and the profit is being paid in the
            // right maker asset.
            matchedFillResults.right.makerAssetFilledAmount = LibMath.safeGetPartialAmountFloor(
                rightOrder.makerAssetAmount,
                rightOrder.takerAssetAmount,
                leftMakerAssetAmountRemaining
            );
            matchedFillResults.right.takerAssetFilledAmount = leftMakerAssetAmountRemaining;
        } else {
            // Case 3: The right and left orders are fully filled
            matchedFillResults = _calculateCompleteFillBoth(
                leftMakerAssetAmountRemaining,
                leftTakerAssetAmountRemaining,
                rightMakerAssetAmountRemaining,
                rightTakerAssetAmountRemaining
            );
        }

        // Calculate amount given to taker in the left order's maker asset if the left spread will be part of the profit.
        if (doesLeftMakerAssetProfitExist) {
            matchedFillResults.profitInLeftMakerAsset = matchedFillResults.left.makerAssetFilledAmount.safeSub(
                matchedFillResults.right.takerAssetFilledAmount
            );
        }

        // Calculate amount given to taker in the right order's maker asset if the right spread will be part of the profit.
        if (doesRightMakerAssetProfitExist) {
            matchedFillResults.profitInRightMakerAsset = matchedFillResults.right.makerAssetFilledAmount.safeSub(
                matchedFillResults.left.takerAssetFilledAmount
            );
        }

        return matchedFillResults;
    }

    
    ///      to the fillResults that are being collected on the order. Both orders will be fully filled in this
    ///      case.
    
    
    
    
    
    function _calculateCompleteFillBoth(
        uint256 leftMakerAssetAmountRemaining,
        uint256 leftTakerAssetAmountRemaining,
        uint256 rightMakerAssetAmountRemaining,
        uint256 rightTakerAssetAmountRemaining
    )
        private
        pure
        returns (MatchedFillResults memory matchedFillResults)
    {
        // Calculate the fully filled results for both orders.
        matchedFillResults.left.makerAssetFilledAmount = leftMakerAssetAmountRemaining;
        matchedFillResults.left.takerAssetFilledAmount = leftTakerAssetAmountRemaining;
        matchedFillResults.right.makerAssetFilledAmount = rightMakerAssetAmountRemaining;
        matchedFillResults.right.takerAssetFilledAmount = rightTakerAssetAmountRemaining;

        return matchedFillResults;
    }

    
    ///      to the fillResults that are being collected on the order.
    
    ///                  can be derived from this order and the right asset remaining fields.
    
    
    
    function _calculateCompleteRightFill(
        LibOrder.Order memory leftOrder,
        uint256 rightMakerAssetAmountRemaining,
        uint256 rightTakerAssetAmountRemaining
    )
        private
        pure
        returns (MatchedFillResults memory matchedFillResults)
    {
        matchedFillResults.right.makerAssetFilledAmount = rightMakerAssetAmountRemaining;
        matchedFillResults.right.takerAssetFilledAmount = rightTakerAssetAmountRemaining;
        matchedFillResults.left.takerAssetFilledAmount = rightMakerAssetAmountRemaining;
        // Round down to ensure the left maker's exchange rate does not exceed the price specified by the order.
        // We favor the left maker when the exchange rate must be rounded and the profit is being paid in the
        // left maker asset.
        matchedFillResults.left.makerAssetFilledAmount = LibMath.safeGetPartialAmountFloor(
            leftOrder.makerAssetAmount,
            leftOrder.takerAssetAmount,
            rightMakerAssetAmountRemaining
        );

        return matchedFillResults;
    }
}

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

pragma solidity ^0.5.9;





library LibExchangeRichErrors {

    enum AssetProxyDispatchErrorCodes {
        INVALID_ASSET_DATA_LENGTH,
        UNKNOWN_ASSET_PROXY
    }

    enum BatchMatchOrdersErrorCodes {
        ZERO_LEFT_ORDERS,
        ZERO_RIGHT_ORDERS,
        INVALID_LENGTH_LEFT_SIGNATURES,
        INVALID_LENGTH_RIGHT_SIGNATURES
    }

    enum ExchangeContextErrorCodes {
        INVALID_MAKER,
        INVALID_TAKER,
        INVALID_SENDER
    }

    enum FillErrorCodes {
        INVALID_TAKER_AMOUNT,
        TAKER_OVERPAY,
        OVERFILL,
        INVALID_FILL_PRICE
    }

    enum SignatureErrorCodes {
        BAD_ORDER_SIGNATURE,
        BAD_TRANSACTION_SIGNATURE,
        INVALID_LENGTH,
        UNSUPPORTED,
        ILLEGAL,
        INAPPROPRIATE_SIGNATURE_TYPE,
        INVALID_SIGNER
    }

    enum TransactionErrorCodes {
        ALREADY_EXECUTED,
        EXPIRED
    }

    enum IncompleteFillErrorCode {
        INCOMPLETE_MARKET_BUY_ORDERS,
        INCOMPLETE_MARKET_SELL_ORDERS,
        INCOMPLETE_FILL_ORDER
    }

    // bytes4(keccak256("SignatureError(uint8,bytes32,address,bytes)"))
    bytes4 internal constant SIGNATURE_ERROR_SELECTOR =
        0x7e5a2318;

    // bytes4(keccak256("SignatureValidatorNotApprovedError(address,address)"))
    bytes4 internal constant SIGNATURE_VALIDATOR_NOT_APPROVED_ERROR_SELECTOR =
        0xa15c0d06;

    // bytes4(keccak256("EIP1271SignatureError(address,bytes,bytes,bytes)"))
    bytes4 internal constant EIP1271_SIGNATURE_ERROR_SELECTOR =
        0x5bd0428d;

    // bytes4(keccak256("SignatureWalletError(bytes32,address,bytes,bytes)"))
    bytes4 internal constant SIGNATURE_WALLET_ERROR_SELECTOR =
        0x1b8388f7;

    // bytes4(keccak256("OrderStatusError(bytes32,uint8)"))
    bytes4 internal constant ORDER_STATUS_ERROR_SELECTOR =
        0xfdb6ca8d;

    // bytes4(keccak256("ExchangeInvalidContextError(uint8,bytes32,address)"))
    bytes4 internal constant EXCHANGE_INVALID_CONTEXT_ERROR_SELECTOR =
        0xe53c76c8;

    // bytes4(keccak256("FillError(uint8,bytes32)"))
    bytes4 internal constant FILL_ERROR_SELECTOR =
        0xe94a7ed0;

    // bytes4(keccak256("OrderEpochError(address,address,uint256)"))
    bytes4 internal constant ORDER_EPOCH_ERROR_SELECTOR =
        0x4ad31275;

    // bytes4(keccak256("AssetProxyExistsError(bytes4,address)"))
    bytes4 internal constant ASSET_PROXY_EXISTS_ERROR_SELECTOR =
        0x11c7b720;

    // bytes4(keccak256("AssetProxyDispatchError(uint8,bytes32,bytes)"))
    bytes4 internal constant ASSET_PROXY_DISPATCH_ERROR_SELECTOR =
        0x488219a6;

    // bytes4(keccak256("AssetProxyTransferError(bytes32,bytes,bytes)"))
    bytes4 internal constant ASSET_PROXY_TRANSFER_ERROR_SELECTOR =
        0x4678472b;

    // bytes4(keccak256("NegativeSpreadError(bytes32,bytes32)"))
    bytes4 internal constant NEGATIVE_SPREAD_ERROR_SELECTOR =
        0xb6555d6f;

    // bytes4(keccak256("TransactionError(uint8,bytes32)"))
    bytes4 internal constant TRANSACTION_ERROR_SELECTOR =
        0xf5985184;

    // bytes4(keccak256("TransactionExecutionError(bytes32,bytes)"))
    bytes4 internal constant TRANSACTION_EXECUTION_ERROR_SELECTOR =
        0x20d11f61;
    
    // bytes4(keccak256("TransactionGasPriceError(bytes32,uint256,uint256)"))
    bytes4 internal constant TRANSACTION_GAS_PRICE_ERROR_SELECTOR =
        0xa26dac09;

    // bytes4(keccak256("TransactionInvalidContextError(bytes32,address)"))
    bytes4 internal constant TRANSACTION_INVALID_CONTEXT_ERROR_SELECTOR =
        0xdec4aedf;

    // bytes4(keccak256("IncompleteFillError(uint8,uint256,uint256)"))
    bytes4 internal constant INCOMPLETE_FILL_ERROR_SELECTOR =
        0x18e4b141;

    // bytes4(keccak256("BatchMatchOrdersError(uint8)"))
    bytes4 internal constant BATCH_MATCH_ORDERS_ERROR_SELECTOR =
        0xd4092f4f;

    // bytes4(keccak256("PayProtocolFeeError(bytes32,uint256,address,address,bytes)"))
    bytes4 internal constant PAY_PROTOCOL_FEE_ERROR_SELECTOR =
        0x87cb1e75;

    // solhint-disable func-name-mixedcase
    function SignatureErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return SIGNATURE_ERROR_SELECTOR;
    }

    function SignatureValidatorNotApprovedErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return SIGNATURE_VALIDATOR_NOT_APPROVED_ERROR_SELECTOR;
    }

    function EIP1271SignatureErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return EIP1271_SIGNATURE_ERROR_SELECTOR;
    }

    function SignatureWalletErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return SIGNATURE_WALLET_ERROR_SELECTOR;
    }

    function OrderStatusErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return ORDER_STATUS_ERROR_SELECTOR;
    }

    function ExchangeInvalidContextErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return EXCHANGE_INVALID_CONTEXT_ERROR_SELECTOR;
    }

    function FillErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return FILL_ERROR_SELECTOR;
    }

    function OrderEpochErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return ORDER_EPOCH_ERROR_SELECTOR;
    }

    function AssetProxyExistsErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return ASSET_PROXY_EXISTS_ERROR_SELECTOR;
    }

    function AssetProxyDispatchErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return ASSET_PROXY_DISPATCH_ERROR_SELECTOR;
    }

    function AssetProxyTransferErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return ASSET_PROXY_TRANSFER_ERROR_SELECTOR;
    }

    function NegativeSpreadErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return NEGATIVE_SPREAD_ERROR_SELECTOR;
    }

    function TransactionErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return TRANSACTION_ERROR_SELECTOR;
    }

    function TransactionExecutionErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return TRANSACTION_EXECUTION_ERROR_SELECTOR;
    }

    function IncompleteFillErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return INCOMPLETE_FILL_ERROR_SELECTOR;
    }

    function BatchMatchOrdersErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return BATCH_MATCH_ORDERS_ERROR_SELECTOR;
    }

    function TransactionGasPriceErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return TRANSACTION_GAS_PRICE_ERROR_SELECTOR;
    }

    function TransactionInvalidContextErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return TRANSACTION_INVALID_CONTEXT_ERROR_SELECTOR;
    }

    function PayProtocolFeeErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return PAY_PROTOCOL_FEE_ERROR_SELECTOR;
    }
    
    function BatchMatchOrdersError(
        BatchMatchOrdersErrorCodes errorCode
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            BATCH_MATCH_ORDERS_ERROR_SELECTOR,
            errorCode
        );
    }

    function SignatureError(
        SignatureErrorCodes errorCode,
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            SIGNATURE_ERROR_SELECTOR,
            errorCode,
            hash,
            signerAddress,
            signature
        );
    }

    function SignatureValidatorNotApprovedError(
        address signerAddress,
        address validatorAddress
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            SIGNATURE_VALIDATOR_NOT_APPROVED_ERROR_SELECTOR,
            signerAddress,
            validatorAddress
        );
    }

    function EIP1271SignatureError(
        address verifyingContractAddress,
        bytes memory data,
        bytes memory signature,
        bytes memory errorData
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            EIP1271_SIGNATURE_ERROR_SELECTOR,
            verifyingContractAddress,
            data,
            signature,
            errorData
        );
    }

    function SignatureWalletError(
        bytes32 hash,
        address walletAddress,
        bytes memory signature,
        bytes memory errorData
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            SIGNATURE_WALLET_ERROR_SELECTOR,
            hash,
            walletAddress,
            signature,
            errorData
        );
    }

    function OrderStatusError(
        bytes32 orderHash,
        LibOrder.OrderStatus orderStatus
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            ORDER_STATUS_ERROR_SELECTOR,
            orderHash,
            orderStatus
        );
    }

    function ExchangeInvalidContextError(
        ExchangeContextErrorCodes errorCode,
        bytes32 orderHash,
        address contextAddress
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            EXCHANGE_INVALID_CONTEXT_ERROR_SELECTOR,
            errorCode,
            orderHash,
            contextAddress
        );
    }

    function FillError(
        FillErrorCodes errorCode,
        bytes32 orderHash
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            FILL_ERROR_SELECTOR,
            errorCode,
            orderHash
        );
    }

    function OrderEpochError(
        address makerAddress,
        address orderSenderAddress,
        uint256 currentEpoch
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            ORDER_EPOCH_ERROR_SELECTOR,
            makerAddress,
            orderSenderAddress,
            currentEpoch
        );
    }

    function AssetProxyExistsError(
        bytes4 assetProxyId,
        address assetProxyAddress
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            ASSET_PROXY_EXISTS_ERROR_SELECTOR,
            assetProxyId,
            assetProxyAddress
        );
    }

    function AssetProxyDispatchError(
        AssetProxyDispatchErrorCodes errorCode,
        bytes32 orderHash,
        bytes memory assetData
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            ASSET_PROXY_DISPATCH_ERROR_SELECTOR,
            errorCode,
            orderHash,
            assetData
        );
    }

    function AssetProxyTransferError(
        bytes32 orderHash,
        bytes memory assetData,
        bytes memory errorData
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            ASSET_PROXY_TRANSFER_ERROR_SELECTOR,
            orderHash,
            assetData,
            errorData
        );
    }

    function NegativeSpreadError(
        bytes32 leftOrderHash,
        bytes32 rightOrderHash
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            NEGATIVE_SPREAD_ERROR_SELECTOR,
            leftOrderHash,
            rightOrderHash
        );
    }

    function TransactionError(
        TransactionErrorCodes errorCode,
        bytes32 transactionHash
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            TRANSACTION_ERROR_SELECTOR,
            errorCode,
            transactionHash
        );
    }

    function TransactionExecutionError(
        bytes32 transactionHash,
        bytes memory errorData
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            TRANSACTION_EXECUTION_ERROR_SELECTOR,
            transactionHash,
            errorData
        );
    }

    function TransactionGasPriceError(
        bytes32 transactionHash,
        uint256 actualGasPrice,
        uint256 requiredGasPrice
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            TRANSACTION_GAS_PRICE_ERROR_SELECTOR,
            transactionHash,
            actualGasPrice,
            requiredGasPrice
        );
    }

    function TransactionInvalidContextError(
        bytes32 transactionHash,
        address currentContextAddress
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            TRANSACTION_INVALID_CONTEXT_ERROR_SELECTOR,
            transactionHash,
            currentContextAddress
        );
    }

    function IncompleteFillError(
        IncompleteFillErrorCode errorCode,
        uint256 expectedAssetFillAmount,
        uint256 actualAssetFillAmount
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            INCOMPLETE_FILL_ERROR_SELECTOR,
            errorCode,
            expectedAssetFillAmount,
            actualAssetFillAmount
        );
    }

    function PayProtocolFeeError(
        bytes32 orderHash,
        uint256 protocolFee,
        address makerAddress,
        address takerAddress,
        bytes memory errorData
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            PAY_PROTOCOL_FEE_ERROR_SELECTOR,
            orderHash,
            protocolFee,
            makerAddress,
            takerAddress,
            errorData
        );
    }
}

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
pragma solidity ^0.5.9;

















interface IFeesManager {
    function receiveFees(uint256 id, address owner, address asset, uint256 fee) external;
    function calculateFee(uint256 id, uint256 amount) external returns (uint256);
}

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

pragma solidity ^0.5.9;


library LibBytesRichErrors {

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
    bytes4 internal constant INVALID_BYTE_OPERATION_ERROR_SELECTOR =
        0x28006595;

    // solhint-disable func-name-mixedcase
    function InvalidByteOperationError(
        InvalidByteOperationErrorCodes errorCode,
        uint256 offset,
        uint256 required
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            INVALID_BYTE_OPERATION_ERROR_SELECTOR,
            errorCode,
            offset,
            required
        );
    }
}

pragma solidity ^0.5.9;





library LibSafeMath {

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
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.MULTIPLICATION_OVERFLOW,
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
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.DIVISION_BY_ZERO,
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
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.SUBTRACTION_UNDERFLOW,
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
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.ADDITION_OVERFLOW,
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
}

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

pragma solidity ^0.5.9;






library LibMath {

    using LibSafeMath for uint256;

    
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
            LibRichErrors.rrevert(LibMathRichErrors.RoundingError(
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
            LibRichErrors.rrevert(LibMathRichErrors.RoundingError(
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
            LibRichErrors.rrevert(LibMathRichErrors.DivisionByZeroError());
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
            LibRichErrors.rrevert(LibMathRichErrors.DivisionByZeroError());
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

pragma solidity ^0.5.9;


library LibSafeMathRichErrors {

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
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT96
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

pragma solidity ^0.5.9;


library LibMathRichErrors {

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

pragma solidity ^0.5.9;


library LibReentrancyGuardRichErrors {

    // bytes4(keccak256("IllegalReentrancyError()"))
    bytes internal constant ILLEGAL_REENTRANCY_ERROR_SELECTOR_BYTES =
        hex"0c3b823f";

    // solhint-disable func-name-mixedcase
    function IllegalReentrancyError()
        internal
        pure
        returns (bytes memory)
    {
        return ILLEGAL_REENTRANCY_ERROR_SELECTOR_BYTES;
    }
}

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

pragma solidity ^0.5.9;


contract IAssetProxy {

    
    
    
    
    
    function transferFrom(
        bytes calldata assetData,
        address from,
        address to,
        uint256 amount
    )
        external;

    
    
    function getProxyId()
        external
        pure
        returns (bytes4);
}

pragma solidity ^0.5.9;


library LibOwnableRichErrors {

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

pragma solidity ^0.5.9;







interface IStaking {

    
    
    function addExchangeAddress(address addr)
        external;

    
    /// Note that an operator must be payable.
    
    
    
    function createStakingPool(uint32 operatorShare, bool addOperatorAsMaker)
        external
        returns (bytes32 poolId);

    
    
    
    function decreaseStakingPoolOperatorShare(bytes32 poolId, uint32 newOperatorShare)
        external;

    
    ///      Throws if not enough time has passed between epochs or if the
    ///      previous epoch was not fully finalized.
    
    function endEpoch()
        external
        returns (uint256);

    
    ///      epoch, crediting it rewards for members and withdrawing operator's
    ///      rewards as WETH. This can be called by internal functions that need
    ///      to finalize a pool immediately. Does nothing if the pool is already
    ///      finalized or did not earn rewards in the previous epoch.
    
    function finalizePool(bytes32 poolId)
        external;

    
    ///      This function should not be called directly.
    ///      The StakingProxy contract will call it in `attachStakingContract()`.
    function init()
        external;

    
    
    function joinStakingPoolAsMaker(bytes32 poolId)
        external;

    
    ///      Delegated stake can also be moved between pools.
    ///      This change comes into effect next epoch.
    
    
    
    function moveStake(
        IStructs.StakeInfo calldata from,
        IStructs.StakeInfo calldata to,
        uint256 amount
    )
        external;

    
    
    
    
    function payProtocolFee(
        address makerAddress,
        address payerAddress,
        uint256 protocolFee
    )
        external
        payable;

    
    
    function removeExchangeAddress(address addr)
        external;

    
    
    
    
    
    
    function setParams(
        uint256 _epochDurationInSeconds,
        uint32 _rewardDelegatedStakeWeight,
        uint256 _minimumPoolStake,
        uint32 _cobbDouglasAlphaNumerator,
        uint32 _cobbDouglasAlphaDenominator
    )
        external;

    
    ///      Unstake to retrieve the ZRX. Stake is in the 'Active' status.
    
    function stake(uint256 amount)
        external;

    
    ///      the staker. Stake must be in the 'undelegated' status in both the
    ///      current and next epoch in order to be unstaked.
    
    function unstake(uint256 amount)
        external;

    
    ///      until the last epoch.
    
    function withdrawDelegatorRewards(bytes32 poolId)
        external;

    
    
    
    
    function computeRewardBalanceOfDelegator(bytes32 poolId, address member)
        external
        view
        returns (uint256 reward);

    
    
    
    function computeRewardBalanceOfOperator(bytes32 poolId)
        external
        view
        returns (uint256 reward);

    
    ///      The next epoch can begin once this time is reached.
    ///      Epoch period = [startTimeInSeconds..endTimeInSeconds)
    
    function getCurrentEpochEarliestEndTimeInSeconds()
        external
        view
        returns (uint256);

    
    
    
    function getGlobalStakeByStatus(IStructs.StakeStatus stakeStatus)
        external
        view
        returns (IStructs.StoredBalance memory balance);

    
    
    
    
    function getOwnerStakeByStatus(
        address staker,
        IStructs.StakeStatus stakeStatus
    )
        external
        view
        returns (IStructs.StoredBalance memory balance);

    
    
    
    
    
    
    function getParams()
        external
        view
        returns (
            uint256 _epochDurationInSeconds,
            uint32 _rewardDelegatedStakeWeight,
            uint256 _minimumPoolStake,
            uint32 _cobbDouglasAlphaNumerator,
            uint32 _cobbDouglasAlphaDenominator
        );

    
    
    
    function getStakeDelegatedToPoolByOwner(address staker, bytes32 poolId)
        external
        view
        returns (IStructs.StoredBalance memory balance);

    
    
    function getStakingPool(bytes32 poolId)
        external
        view
        returns (IStructs.Pool memory);

    
    
    
    function getStakingPoolStatsThisEpoch(bytes32 poolId)
        external
        view
        returns (IStructs.PoolStats memory);

    
    ///      across all members.
    
    
    function getTotalStakeDelegatedToPool(bytes32 poolId)
        external
        view
        returns (IStructs.StoredBalance memory balance);

    
    ///      Must be view to allow overrides to access state.
    
    function getWethContract()
        external
        view
        returns (IEtherToken wethContract);

    
    ///      Must be view to allow overrides to access state.
    
    function getZrxVault()
        external
        view
        returns (IZrxVault zrxVault);
}

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

pragma solidity ^0.5.9;




contract IEtherToken is
    IERC20Token
{
    function deposit()
        public
        payable;
    
    function withdraw(uint256 amount)
        public;
}

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

pragma solidity ^0.5.9;


interface IStructs {

    
    
    
    
    struct PoolStats {
        uint256 feesCollected;
        uint256 weightedStake;
        uint256 membersStake;
    }

    
    
    ///        being finalized (the previous epoch). This is simply the balance
    ///        of the contract at the end of the epoch.
    
    
    
    
    struct AggregatedStats {
        uint256 rewardsAvailable;
        uint256 numPoolsToFinalize;
        uint256 totalFeesCollected;
        uint256 totalWeightedStake;
        uint256 totalRewardsFinalized;
    }

    
    /// Note that these balances may be stale if the current epoch
    /// is greater than `currentEpoch`.
    
    
    
    struct StoredBalance {
        uint64 currentEpoch;
        uint96 currentEpochBalance;
        uint96 nextEpochBalance;
    }

    
    ///      Any stake can be (re)delegated effective at the next epoch
    ///      Undelegated stake can be withdrawn if it is available in both the current and next epoch
    enum StakeStatus {
        UNDELEGATED,
        DELEGATED
    }

    
    
    
    struct StakeInfo {
        StakeStatus status;
        bytes32 poolId;
    }

    
    
    
    struct Fraction {
        uint256 numerator;
        uint256 denominator;
    }

    
    
    
    struct Pool {
        address operator;
        uint32 operatorShare;
    }
}

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

pragma solidity ^0.5.9;


interface IZrxVault {

    
    event StakingProxySet(address stakingProxyAddress);

    
    
    event InCatastrophicFailureMode(address sender);

    
    
    
    event Deposit(
        address indexed staker,
        uint256 amount
    );

    
    
    
    event Withdraw(
        address indexed staker,
        uint256 amount
    );

    
    event ZrxProxySet(address zrxProxyAddress);

    
    /// Note that only the contract staker can call this function.
    
    function setStakingProxy(address _stakingProxyAddress)
        external;

    
    /// *** WARNING - ONCE IN CATOSTROPHIC FAILURE MODE, YOU CAN NEVER GO BACK! ***
    /// Note that only the contract staker can call this function.
    function enterCatastrophicFailure()
        external;

    
    /// Note that only the contract staker can call this.
    /// Note that this can only be called when *not* in Catastrophic Failure mode.
    
    function setZrxProxy(address zrxProxyAddress)
        external;

    
    /// Note that only the Staking contract can call this.
    /// Note that this can only be called when *not* in Catastrophic Failure mode.
    
    
    function depositFrom(address staker, uint256 amount)
        external;

    
    /// Note that only the Staking contract can call this.
    /// Note that this can only be called when *not* in Catastrophic Failure mode.
    
    
    function withdrawFrom(address staker, uint256 amount)
        external;

    
    /// Note that this can only be called when *in* Catastrophic Failure mode.
    
    function withdrawAllFrom(address staker)
        external
        returns (uint256);

    
    
    function balanceOf(address staker)
        external
        view
        returns (uint256);

    
    function balanceOfZrxVault()
        external
        view
        returns (uint256);
}

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

pragma solidity ^0.5.9;





library LibZeroExTransaction {

    using LibZeroExTransaction for ZeroExTransaction;

    // Hash for the EIP712 0x transaction schema
    // keccak256(abi.encodePacked(
    //    "ZeroExTransaction(",
    //    "uint256 salt,",
    //    "uint256 expirationTimeSeconds,",
    //    "uint256 gasPrice,",
    //    "address signerAddress,",
    //    "bytes data",
    //    ")"
    // ));
    bytes32 constant internal _EIP712_ZEROEX_TRANSACTION_SCHEMA_HASH = 0xec69816980a3a3ca4554410e60253953e9ff375ba4536a98adfa15cc71541508;

    struct ZeroExTransaction {
        uint256 salt;                   // Arbitrary number to ensure uniqueness of transaction hash.
        uint256 expirationTimeSeconds;  // Timestamp in seconds at which transaction expires.
        uint256 gasPrice;               // gasPrice that transaction is required to be executed with.
        address signerAddress;          // Address of transaction signer.
        bytes data;                     // AbiV2 encoded calldata.
    }

    
    
    
    function getTypedDataHash(ZeroExTransaction memory transaction, bytes32 eip712ExchangeDomainHash)
        internal
        pure
        returns (bytes32 transactionHash)
    {
        // Hash the transaction with the domain separator of the Exchange contract.
        transactionHash = LibEIP712.hashEIP712Message(
            eip712ExchangeDomainHash,
            transaction.getStructHash()
        );
        return transactionHash;
    }

    
    
    
    function getStructHash(ZeroExTransaction memory transaction)
        internal
        pure
        returns (bytes32 result)
    {
        bytes32 schemaHash = _EIP712_ZEROEX_TRANSACTION_SCHEMA_HASH;
        bytes memory data = transaction.data;
        uint256 salt = transaction.salt;
        uint256 expirationTimeSeconds = transaction.expirationTimeSeconds;
        uint256 gasPrice = transaction.gasPrice;
        address signerAddress = transaction.signerAddress;

        // Assembly for more efficiently computing:
        // result = keccak256(abi.encodePacked(
        //     schemaHash,
        //     salt,
        //     expirationTimeSeconds,
        //     gasPrice,
        //     uint256(signerAddress),
        //     keccak256(data)
        // ));

        assembly {
            // Compute hash of data
            let dataHash := keccak256(add(data, 32), mload(data))

            // Load free memory pointer
            let memPtr := mload(64)

            mstore(memPtr, schemaHash)                                                                // hash of schema
            mstore(add(memPtr, 32), salt)                                                             // salt
            mstore(add(memPtr, 64), expirationTimeSeconds)                                            // expirationTimeSeconds
            mstore(add(memPtr, 96), gasPrice)                                                         // gasPrice
            mstore(add(memPtr, 128), and(signerAddress, 0xffffffffffffffffffffffffffffffffffffffff))  // signerAddress
            mstore(add(memPtr, 160), dataHash)                                                        // hash of data

            // Compute hash
            result := keccak256(memPtr, 192)
        }
        return result;
    }
}

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

pragma solidity ^0.5.9;





contract IWallet {

    
    
    
    
    function isValidSignature(
        bytes32 hash,
        bytes calldata signature
    )
        external
        view
        returns (bytes4 magicValue);
}

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

pragma solidity ^0.5.9;




contract IEIP1271Wallet is
    LibEIP1271
{
    
    
    
    
    function isValidSignature(
        bytes calldata data,
        bytes calldata signature
    )
        external
        view
        returns (bytes4 magicValue);
}

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

pragma solidity ^0.5.9;






// solhint-disable
contract IEIP1271Data {

    
    ///      and hash into a byte array before calling `isValidSignature`.
    ///      This function serves no other purpose.
    function OrderWithHash(
        LibOrder.Order calldata order,
        bytes32 orderHash
    )
        external
        pure;
    
    
    ///      and hash into a byte array before calling `isValidSignature`.
    ///      This function serves no other purpose.
    function ZeroExTransactionWithHash(
        LibZeroExTransaction.ZeroExTransaction calldata transaction,
        bytes32 transactionHash
    )
        external
        pure;
}
