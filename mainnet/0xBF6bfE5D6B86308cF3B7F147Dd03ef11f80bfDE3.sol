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

pragma solidity ^0.8.4;




interface ISignatureValidator {

   // Allowed signature types.
    enum SignatureType {
        Illegal,                     // 0x00, default value
        Invalid,                     // 0x01
        EIP712,                      // 0x02
        EthSign,                     // 0x03
        NSignatureTypes              // 0x06, number of signature types. Always leave at end.
    }

    
    
    
    
    function isValidHashSignature(
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        external
        view
        returns (bool isValid);

    
    
    
    
    function isValidOrderSignature(
        LibOrder.Order memory order,
        bytes memory signature
    )
        external
        view
        returns (bool isValid);
}

pragma solidity ^0.8.4;


interface IProtocolFees {

    // Logs updates to the protocol fee multiplier.
    event ProtocolFeeMultiplier(uint256 oldProtocolFeeMultiplier, uint256 updatedProtocolFeeMultiplier);

    // Logs updates to the protocol fixed fee.
    event ProtocolFixedFee(uint256 oldProtocolFixedFee, uint256 updatedProtocolFixedFee);

    // Logs updates to the protocolFeeCollector address.
    event ProtocolFeeCollectorAddress(address oldProtocolFeeCollector, address updatedProtocolFeeCollector);

    
    
    function setProtocolFeeMultiplier(uint256 updatedProtocolFeeMultiplier) external;

    
    
    function setProtocolFixedFee(uint256 fixedProtocolFee) external;

    
    
    function setProtocolFeeCollectorAddress(address updatedProtocolFeeCollector) external;
}

pragma solidity ^0.8.4;




contract LibEIP712ExchangeDomain {

    // EIP712 Exchange Domain Name value
    string constant internal DOMAIN_NAME = "Nifty Exchange";

    // EIP712 Exchange Domain Version value
    string constant internal DOMAIN_VERSION = "2.0";

    // solhint-disable var-name-mixedcase
    
    
    bytes32 public DOMAIN_HASH;
    // solhint-enable var-name-mixedcase

    
    constructor (
        uint256 chainId
    )
    {
        DOMAIN_HASH = LibEIP712.hashDomain(
            DOMAIN_NAME,
            DOMAIN_VERSION,
            chainId,
            address(this)
        );
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
pragma solidity ^0.8.4;


abstract contract IAssetProxyRegistry {

    // Logs registration of new asset proxy
    event AssetProxyRegistered(
        bytes4 id,              // Id of new registered AssetProxy.
        address assetProxy      // Address of new registered AssetProxy.
    );

    
    ///      Once an asset proxy is registered, it cannot be unregistered.
    
    function registerAssetProxy(address assetProxy)
        virtual external;

    
    
    
    function getAssetProxy(bytes4 assetProxyId)
        virtual
        external
        view
        returns (address);
}

pragma solidity ^0.8.4;




abstract contract IExchangeCore {

    // Fill event is emitted whenever an order is filled.
    event Fill(
        address indexed makerAddress,         // Address that created the order.
        address indexed royaltiesAddress,     // Address that received fees.
        bytes makerAssetData,                 // Encoded data specific to makerAsset.
        bytes takerAssetData,                 // Encoded data specific to takerAsset.
        bytes32 indexed orderHash,            // EIP712 hash of order (see LibOrder.getTypedDataHash).
        address takerAddress,                 // Address that filled the order.
        address senderAddress,                // Address that called the Exchange contract (msg.sender).
        uint256 makerAssetAmount,             // Amount of makerAsset sold by maker and bought by taker.
        uint256 takerAssetAmount,             // Amount of takerAsset sold by taker and bought by maker.
        uint256 royaltiesAmount,              // Amount of royalties paid to royaltiesAddress.
        uint256 protocolFeePaid,              // Amount paid to the protocol.
        bytes32 marketplaceIdentifier,        // marketplace identifier.
        uint256 marketplaceFeePaid            // Amount paid to the marketplace brought the taker.
    );

    // Cancel event is emitted whenever an individual order is cancelled.
    event Cancel(
        address indexed makerAddress,         // Address that created the order.
        bytes makerAssetData,                 // Encoded data specific to makerAsset.
        bytes takerAssetData,                 // Encoded data specific to takerAsset.
        address senderAddress,                // Address that called the Exchange contract (msg.sender).
        bytes32 indexed orderHash             // EIP712 hash of order (see LibOrder.getTypedDataHash).
    );

    // CancelUpTo event is emitted whenever `cancelOrdersUpTo` is executed succesfully.
    event CancelUpTo(
        address indexed makerAddress,         // Orders cancelled must have been created by this address.
        uint256 orderEpoch                    // Orders with a salt less than this value are considered cancelled.
    );

    
    
    function cancelOrdersUpTo(uint256 targetOrderEpoch)
        virtual
        external;

    
    
    
    
    function fillOrder(
        LibOrder.Order memory order,
        bytes memory signature,
        bytes32 marketIdentifier
    )
        virtual
        external
        payable
        returns (bool fulfilled);

    
    
    
    
    
    function fillOrderFor(
        LibOrder.Order memory order,
        bytes memory signature,
        bytes32 marketIdentifier,
        address takerAddress
    )
        virtual
        external
        payable
        returns (bool fulfilled);

    
    
    function cancelOrder(LibOrder.Order memory order)
        virtual
        external;

    
    
    
    ///                   See LibOrder.OrderInfo for a complete description.
    function getOrderInfo(LibOrder.Order memory order)
        virtual
        external
        view
        returns (LibOrder.OrderInfo memory orderInfo);
}

pragma solidity ^0.8.4;







abstract contract SignatureValidator is
    LibEIP712ExchangeDomain,
    ISignatureValidator
{
    using LibBytes for bytes;
    using LibOrder for LibOrder.Order;

    
    
    
    
    
    function isValidHashSignature(
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        override
        public
        pure
        returns (bool isValid)
    {
        SignatureType signatureType = _readValidSignatureType(
            signerAddress,
            signature
        );

        return _validateHashSignatureTypes(
            signatureType,
            hash,
            signerAddress,
            signature
        );
    }

    
    
    
    
    function isValidOrderSignature(
        LibOrder.Order memory order,
        bytes memory signature
    )
        override
        public
        view
        returns (bool isValid)
    {
        bytes32 orderHash = order.getTypedDataHash(DOMAIN_HASH);
        isValid = _isValidOrderWithHashSignature(
            order,
            orderHash,
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
        pure
        returns (bool isValid)
    {
        address signerAddress = order.makerAddress;
        SignatureType signatureType = _readValidSignatureType(
            signerAddress,
            signature
        );
        
        return _validateHashSignatureTypes(
            signatureType,
            orderHash,
            signerAddress,
            signature
        );
    }

    /// Validates a hash-only signature type
    /// (anything but `EIP1271Wallet`).
    function _validateHashSignatureTypes(
        SignatureType signatureType,
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        private
        pure
        returns (bool isValid)
    {
        // invalid signature.
        if (signatureType == SignatureType.Invalid) {
            if (signature.length != 1) {
                revert('SIGNATURE: invalid length');
            }
            isValid = false;

        // Signature using EIP712
        } else if (signatureType == SignatureType.EIP712) {
            if (signature.length != 66) {
                revert('SIGNATURE: invalid length');
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
                revert('SIGNATURE: invalid length');
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
        }

        return isValid;
    }

    
    function _readValidSignatureType(
        address signerAddress,
        bytes memory signature
    )
        private
        pure
        returns (SignatureType signatureType)
    {
        if (signature.length == 0) {
            revert('SIGNATURE: invalid length');
        }
        signatureType = SignatureType(uint8(signature[signature.length - 1]));

        // Disallow address zero because ecrecover() returns zero on failure.
        if (signerAddress == address(0)) {
            revert('SIGNATURE: signerAddress cannot be null');
        }

        // Ensure signature is supported
        if (uint8(signatureType) >= uint8(SignatureType.NSignatureTypes)) {
            revert('SIGNATURE: signature not supported');
        }

        // illegal signature.
        if (signatureType == SignatureType.Illegal) {
            revert('SIGNATURE: illegal signature');
        }

        return signatureType;
    }
}

pragma solidity ^0.8.4;





contract ProtocolFees is
    IProtocolFees,
    Ownable
{
    
    
    uint256 public protocolFeeMultiplier;

    
    
    uint256 public protocolFixedFee;

    
    
    address public protocolFeeCollector;

    
    
    function setProtocolFeeMultiplier(uint256 updatedProtocolFeeMultiplier)
        override
        external
        onlyOwner
    {
        emit ProtocolFeeMultiplier(protocolFeeMultiplier, updatedProtocolFeeMultiplier);
        protocolFeeMultiplier = updatedProtocolFeeMultiplier;
    }

    
    
    function setProtocolFixedFee(uint256 updatedProtocolFixedFee)
        override
        external
        onlyOwner
    {
        emit ProtocolFixedFee(protocolFixedFee, updatedProtocolFixedFee);
        protocolFixedFee = updatedProtocolFixedFee;
    }

    
    
    function setProtocolFeeCollectorAddress(address updatedProtocolFeeCollector)
        override
        external
        onlyOwner
    {
        emit ProtocolFeeCollectorAddress(protocolFeeCollector, updatedProtocolFeeCollector);
        protocolFeeCollector = updatedProtocolFeeCollector;
    }
}

pragma solidity ^0.8.4;



contract MarketplaceRegistry is Ownable {
    struct Marketplace {
        uint256 feeMultiplier;
        address feeCollector;
        bool isActive;
    }

    event MarketplaceRegister(bytes32 identifier, uint256 feeMultiplier, address feeCollector);
    event MarketplaceUpdateStatus(bytes32 identifier, bool status);
    event MarketplaceSetFees(bytes32 identifier, uint256 feeMultiplier, address feeCollector);

    bool public distributeMarketplaceFees = true;

    mapping(bytes32 => Marketplace) marketplaces;

    function marketplaceDistribution(bool _distributeMarketplaceFees)
        external
        onlyOwner
    {
        distributeMarketplaceFees = _distributeMarketplaceFees;
    }

    function registerMarketplace(bytes32 identifier, uint256 feeMultiplier, address feeCollector) external onlyOwner {
        require(feeMultiplier <= 100, "fee multiplier must be betwen 0 to 100");
        marketplaces[identifier] = Marketplace(feeMultiplier, feeCollector, true);
        emit MarketplaceRegister(identifier, feeMultiplier, feeCollector);
    }

    function setMarketplaceStatus(bytes32 identifier, bool isActive)
        external
        onlyOwner
    {
        marketplaces[identifier].isActive = isActive;
        emit MarketplaceUpdateStatus(identifier, isActive);
    }

    function setMarketplaceFees(
        bytes32 identifier,
        uint256 feeMultiplier,
        address feeCollector
    ) external onlyOwner {
        require(feeMultiplier <= 100, "fee multiplier must be betwen 0 to 100");
        marketplaces[identifier].feeMultiplier = feeMultiplier;
        marketplaces[identifier].feeCollector = feeCollector;
        emit MarketplaceSetFees(identifier, feeMultiplier, feeCollector);
    }
}

pragma solidity ^0.8.4;








contract AssetProxyRegistry is
    Ownable,
    IAssetProxyRegistry
{
    using LibBytes for bytes;

    // Mapping from Asset Proxy Id's to their respective Asset Proxy
    mapping (bytes4 => address) internal _assetProxies;

    
    
    function registerAssetProxy(address assetProxy)
        override
        external
        onlyOwner
    {
        // Ensure that no asset proxy exists with current id.
        bytes4 assetProxyId = IAssetProxy(assetProxy).getProxyId();
        // Add asset proxy and log registration.
        _assetProxies[assetProxyId] = assetProxy;
        emit AssetProxyRegistered(
            assetProxyId,
            assetProxy
        );
    }

    
    
    
    function getAssetProxy(bytes4 assetProxyId)
        override
        external
        view
        returns (address assetProxy)
    {
        return _assetProxies[assetProxyId];
    }

    function _isERC20Proxy(bytes memory assetData)
        internal
        pure
        returns (bool)
    {
        bytes4 assetProxyId = assetData.readBytes4(0);
        bytes4 erc20ProxyId = IAssetData(address(0)).ERC20Token.selector;

        return assetProxyId == erc20ProxyId;
    }

    
    
    
    
    
    function _dispatchTransfer(
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
                revert('ASSET PROXY: invalid length');
            }

            // Lookup assetProxy.
            bytes4 assetProxyId = assetData.readBytes4(0);
            address assetProxy = _assetProxies[assetProxyId];

            // Ensure that assetProxy exists
            if (assetProxy == address(0)) {
                revert('ASSET PROXY: unknown');
            }

            bool ethPayment = false;

            if (assetProxyId == IAssetData(address(0)).ERC20Token.selector) {
                address erc20TokenAddress = assetData.readAddress(4);
                ethPayment = erc20TokenAddress == address(0);
            }

            if (ethPayment) {
                if (address(this).balance < amount) {
                    revert("ASSET PROXY: insufficient balance");
                }
                (bool success, ) = to.call{value: amount}("");
                require(success, "ASSET PROXY: eth transfer failed");
            } else {
                // Construct the calldata for the transferFrom call.
                bytes memory proxyCalldata = abi.encodeWithSelector(
                    IAssetProxy(address(0)).transferFrom.selector,
                    assetData,
                    from,
                    to,
                    amount
                );

                // Call the asset proxy's transferFrom function with the constructed calldata.
                (bool didSucceed, ) = assetProxy.call(proxyCalldata);

                // If the transaction did not succeed, revert with the returned data.
                if (!didSucceed) {
                    revert("ASSET PROXY: transfer failed");
                }
            }
        }
    }
}

pragma solidity ^0.8.4;

contract Refundable
{

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier refundFinalBalanceNoReentry {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        _refundNonZeroBalance();

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    function _refundNonZeroBalance()
        internal
    {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            payable(msg.sender).transfer(balance);
        }
    }
}

pragma solidity ^0.8.4;












abstract contract ExchangeCore is
    IExchangeCore,
    AssetProxyRegistry,
    ProtocolFees,
    SignatureValidator,
    MarketplaceRegistry
{
    using LibOrder for LibOrder.Order;
    using SafeMath for uint256;
    using LibBytes for bytes;

    
    
    mapping (bytes32 => bool) public filled;

    
    
    mapping (bytes32 => bool) public cancelled;

    
    
    mapping (address => uint256) public orderEpoch;

    
    
    
    
    
    function _fillOrder(
        LibOrder.Order memory order,
        bytes memory signature,
        address takerAddress,
        bytes32 marketplaceIdentifier
    )
        internal
        returns (bool fulfilled)
    {
        // Fetch order info
        LibOrder.OrderInfo memory orderInfo = _getOrderInfo(order);

        // Assert that the order is fillable by taker
        _assertFillable(
            order,
            orderInfo,
            takerAddress,
            signature
        );

        bytes32 orderHash = orderInfo.orderHash;

        // Update state
        filled[orderHash] = true;

        Marketplace memory marketplace = marketplaces[marketplaceIdentifier];

        // Settle order
        (uint256 protocolFee, uint256 marketplaceFee) = _settle(
            orderInfo,
            order,
            takerAddress,
            marketplace
        );

        _notifyFill(order, orderHash, takerAddress, protocolFee, marketplaceIdentifier, marketplaceFee);

        return filled[orderHash];
    }

    function _notifyFill(
        LibOrder.Order memory order,
        bytes32 orderHash,
        address takerAddress,
        uint256 protocolFee,
        bytes32 marketplaceIdentifier,
        uint256 marketplaceFee
    ) internal {
        emit Fill(
            order.makerAddress,
            order.royaltiesAddress,
            order.makerAssetData,
            order.takerAssetData,
            orderHash,
            takerAddress,
            msg.sender,
            order.makerAssetAmount,
            order.takerAssetAmount,
            order.royaltiesAmount,
            protocolFee,
            marketplaceIdentifier,
            marketplaceFee
        );
    }

    
    ///      Throws if order is invalid or sender does not have permission to cancel.
    
    function _cancelOrder(LibOrder.Order memory order)
        internal
    {
        // Fetch current order status
        LibOrder.OrderInfo memory orderInfo = _getOrderInfo(order);

        // Validate context
        _assertValidCancel(order);

        // Noop if order is already unfillable
        if (orderInfo.orderStatus != LibOrder.OrderStatus.FILLABLE) {
            return;
        }

        // Perform cancel
        _updateCancelledState(order, orderInfo.orderHash);
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
            order.makerAssetData,
            order.takerAssetData,
            msg.sender,
            orderHash
        );
    }

    
    
    
    
    
    function _assertFillable(
        LibOrder.Order memory order,
        LibOrder.OrderInfo memory orderInfo,
        address takerAddress,
        bytes memory signature
    )
        internal
    {
        if (orderInfo.orderType == LibOrder.OrderType.INVALID) {
            revert('EXCHANGE: type illegal');
        }

        if (orderInfo.orderType == LibOrder.OrderType.LIST) {
            address erc20TokenAddress = order.takerAssetData.readAddress(4);
            if (erc20TokenAddress == address(0) && msg.value < order.takerAssetAmount) {
                revert('EXCHANGE: wrong value sent');
            }
        }

        if (orderInfo.orderType != LibOrder.OrderType.LIST && takerAddress != msg.sender) {
            revert('EXCHANGE: fill order for is only valid for buy now');
        }

        if (orderInfo.orderType == LibOrder.OrderType.SWAP) {
            if (msg.value < protocolFixedFee) {
                revert('EXCHANGE: wrong value sent');
            }
        }

        // An order can only be filled if its status is FILLABLE.
        if (orderInfo.orderStatus != LibOrder.OrderStatus.FILLABLE) {
            revert('EXCHANGE: status not fillable');
        }

        // Validate sender is allowed to fill this order
        if (order.senderAddress != address(0)) {
            if (order.senderAddress != msg.sender) {
                revert('EXCHANGE: invalid sender');
            }
        }

        // Validate taker is allowed to fill this order
        if (order.takerAddress != address(0)) {
            if (order.takerAddress != takerAddress) {
                revert('EXCHANGE: invalid taker');
            }
        }

        // Validate signature
        if (!_isValidOrderWithHashSignature(
                order,
                orderInfo.orderHash,
                signature
            )
        ) {
            revert('EXCHANGE: invalid signature');
        }
    }

    
    
    function _assertValidCancel(
        LibOrder.Order memory order
    )
        internal
        view
    {
        // Validate sender is allowed to cancel this order
        if (order.senderAddress != address(0)) {
            if (order.senderAddress != msg.sender) {
                revert('EXCHANGE: invalid sender');
            }
        }

        // Validate transaction signed by maker
        address makerAddress = msg.sender;
        if (order.makerAddress != makerAddress) {
            revert('EXCHANGE: invalid maker');
        }
    }

    
    
    
    ///         See LibOrder.OrderInfo for a complete description.
    function _getOrderInfo(LibOrder.Order memory order)
        internal
        view
        returns (LibOrder.OrderInfo memory orderInfo)
    {
        // Compute the order hash
        orderInfo.orderHash = order.getTypedDataHash(DOMAIN_HASH);

        bool isTakerAssetDataERC20 = _isERC20Proxy(order.takerAssetData);
        bool isMakerAssetDataERC20 = _isERC20Proxy(order.makerAssetData);

        if (isTakerAssetDataERC20 && !isMakerAssetDataERC20) {
            orderInfo.orderType = LibOrder.OrderType.LIST;
        } else if (!isTakerAssetDataERC20 && isMakerAssetDataERC20) {
            orderInfo.orderType = LibOrder.OrderType.OFFER;
        } else if (!isTakerAssetDataERC20 && !isMakerAssetDataERC20) {
            orderInfo.orderType = LibOrder.OrderType.SWAP;
        } else {
            orderInfo.orderType = LibOrder.OrderType.INVALID;
        }

        // If order.makerAssetAmount is zero the order is invalid
        if (order.makerAssetAmount == 0) {
            orderInfo.orderStatus = LibOrder.OrderStatus.INVALID_MAKER_ASSET_AMOUNT;
            return orderInfo;
        }

        // If order.takerAssetAmount is zero the order is invalid
        if (order.takerAssetAmount == 0) {
            orderInfo.orderStatus = LibOrder.OrderStatus.INVALID_TAKER_ASSET_AMOUNT;
            return orderInfo;
        }

        if (orderInfo.orderType == LibOrder.OrderType.LIST && order.royaltiesAmount > order.takerAssetAmount) {
            orderInfo.orderStatus = LibOrder.OrderStatus.INVALID_ROYALTIES;
            return orderInfo;
        }

        if (orderInfo.orderType == LibOrder.OrderType.OFFER && order.royaltiesAmount > order.makerAssetAmount) {
            orderInfo.orderStatus = LibOrder.OrderStatus.INVALID_ROYALTIES;
            return orderInfo;
        }

        // Check if order has been filled
        if (filled[orderInfo.orderHash]) {
            orderInfo.orderStatus = LibOrder.OrderStatus.FILLED;
            return orderInfo;
        }

        // Check if order has been cancelled
        if (cancelled[orderInfo.orderHash]) {
            orderInfo.orderStatus = LibOrder.OrderStatus.CANCELLED;
            return orderInfo;
        }

        if (orderEpoch[order.makerAddress] > order.salt) {
            orderInfo.orderStatus = LibOrder.OrderStatus.CANCELLED;
            return orderInfo;
        }

        // Validate order expiration
        if (block.timestamp >= order.expirationTimeSeconds) {
            orderInfo.orderStatus = LibOrder.OrderStatus.EXPIRED;
            return orderInfo;
        }

        // All other statuses are ruled out: order is Fillable
        orderInfo.orderStatus = LibOrder.OrderStatus.FILLABLE;
        return orderInfo;
    }


    
    
    
    
    function _settle(
        LibOrder.OrderInfo memory orderInfo,
        LibOrder.Order memory order,
        address takerAddress,
        Marketplace memory marketplace
    )
        internal
        returns (uint256 protocolFee, uint256 marketplaceFee)
    {
        bytes memory payerAssetData;
        bytes memory sellerAssetData;
        address payerAddress;
        address sellerAddress;
        uint256 buyerPayment;
        uint256 sellerAmount;

        if (orderInfo.orderType == LibOrder.OrderType.LIST) {
            payerAssetData = order.takerAssetData;
            sellerAssetData = order.makerAssetData;
            payerAddress = msg.sender;
            sellerAddress = order.makerAddress;
            buyerPayment = order.takerAssetAmount;
            sellerAmount = order.makerAssetAmount;
        }

        if (orderInfo.orderType == LibOrder.OrderType.OFFER || orderInfo.orderType == LibOrder.OrderType.SWAP) {
            payerAssetData = order.makerAssetData;
            sellerAssetData = order.takerAssetData;
            payerAddress = order.makerAddress;
            sellerAddress = msg.sender;
            takerAddress = payerAddress;
            buyerPayment = order.makerAssetAmount;
            sellerAmount = order.takerAssetAmount;
        }


        // pay protocol fees
        if (protocolFeeCollector != address(0)) {
            bytes memory protocolAssetData = payerAssetData;
            if (orderInfo.orderType == LibOrder.OrderType.SWAP && protocolFixedFee > 0) {
                protocolFee = protocolFixedFee;
                protocolAssetData = abi.encodeWithSelector(IAssetData(address(0)).ERC20Token.selector, address(0));
            } else if (protocolFeeMultiplier > 0) {
                protocolFee = buyerPayment.mul(protocolFeeMultiplier).div(1000); // 10 times the fee to support decimals - 20 -> 2%
                buyerPayment = buyerPayment.sub(protocolFee);
            }

            if (marketplace.isActive && marketplace.feeCollector != address(0) && marketplace.feeMultiplier > 0 && distributeMarketplaceFees) {
                marketplaceFee = protocolFee.mul(marketplace.feeMultiplier).div(100);
                protocolFee = protocolFee.sub(marketplaceFee);
                _dispatchTransfer(
                    protocolAssetData,
                    payerAddress,
                    marketplace.feeCollector,
                    marketplaceFee
                );
            }

            _dispatchTransfer(
                protocolAssetData,
                payerAddress,
                protocolFeeCollector,
                protocolFee
            );
        }

        // pay royalties
        if (order.royaltiesAddress != address(0) && order.royaltiesAmount > 0 ) {
            buyerPayment = buyerPayment.sub(order.royaltiesAmount);
            _dispatchTransfer(
                payerAssetData,
                payerAddress,
                order.royaltiesAddress,
                order.royaltiesAmount
            );
        }

        // pay seller // erc20
        _dispatchTransfer(
            payerAssetData,
            payerAddress,
            sellerAddress,
            buyerPayment
        );

        // Transfer seller -> buyer (nft / bundle)
        _dispatchTransfer(
            sellerAssetData,
            sellerAddress,
            takerAddress,
            sellerAmount
        );

        return (protocolFee, marketplaceFee);
      
    }
}
pragma solidity ^0.8.4;






contract NiftyProtocol is
    Ownable,
    Refundable,
    ExchangeCore
{
    string public name = "Nifty Protocol";

    constructor (uint256 chainId) LibEIP712ExchangeDomain(chainId) {}
    
    
    
    
    
    function fillOrder(
        LibOrder.Order memory order,
        bytes memory signature,
        bytes32 marketplaceIdentifier
    )
        override
        external
        payable
        refundFinalBalanceNoReentry
        returns (bool fulfilled)
    {
        return _fillOrder(
            order,
            signature,
            msg.sender,
            marketplaceIdentifier
        );
    }

    
    
    
    
    
    function fillOrderFor(
        LibOrder.Order memory order,
        bytes memory signature,
        bytes32 marketplaceIdentifier,
        address takerAddress
    )
        override
        external
        payable
        refundFinalBalanceNoReentry
        returns (bool fulfilled)
    {
        return _fillOrder(
            order,
            signature,
            takerAddress,
            marketplaceIdentifier
        );
    }

    
    
    function cancelOrder(LibOrder.Order memory order)
        override
        external
    {
        _cancelOrder(order);
    }

    
    ///      and senderAddress equal to msg.sender (or null address if msg.sender == makerAddress).
    
    function cancelOrdersUpTo(uint256 targetOrderEpoch)
        override
        external
    {
        address makerAddress = msg.sender;
        // orderEpoch is initialized to 0, so to cancelUpTo we need salt + 1
        uint256 newOrderEpoch = targetOrderEpoch + 1;
        uint256 oldOrderEpoch = orderEpoch[makerAddress];

        // Ensure orderEpoch is monotonically increasing
        if (newOrderEpoch <= oldOrderEpoch) {
            revert('EXCHANGE: order epoch error');
        }

        // Update orderEpoch
        orderEpoch[makerAddress] = newOrderEpoch;
        emit CancelUpTo(
            makerAddress,
            newOrderEpoch
        );
    }

    
    
    
    ///         See LibOrder.OrderInfo for a complete description.
    function getOrderInfo(LibOrder.Order memory order)
        override
        public
        view
        returns (LibOrder.OrderInfo memory orderInfo)
    {
        return _getOrderInfo(order);
    }

    function returnAllETHToOwner() external payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function returnERC20ToOwner(address ERC20Token) external payable onlyOwner {
        IERC20 CustomToken = IERC20(ERC20Token);
        CustomToken.transferFrom(address(this), msg.sender, CustomToken.balanceOf(address(this)));
    }

    receive() external payable {}
}

pragma solidity ^0.8.4;




library LibOrder {

    using LibOrder for Order;

    // Hash for the EIP712 Order Schema:
    // keccak256(abi.encodePacked(
    //     "Order(",
    //     "address makerAddress,",
    //     "address takerAddress,",
    //     "address royaltiesAddress,",
    //     "address senderAddress,",
    //     "uint256 makerAssetAmount,",
    //     "uint256 takerAssetAmount,",
    //     "uint256 royaltiesAmount,",
    //     "uint256 expirationTimeSeconds,",
    //     "uint256 salt,",
    //     "bytes makerAssetData,",
    //     "bytes takerAssetData",
    //     ")"
    // ))
    bytes32 constant internal _EIP712_ORDER_SCHEMA_HASH =
        0x85eeee70c9e228559a0ea5492e9915b70dab1efedd40807802f996020d88dc2e;

    // A valid order remains fillable until it is expired, fully filled, or cancelled.
    // An order's status is unaffected by external factors, like account balances.
    enum OrderStatus {
        INVALID,                     // Default value
        INVALID_MAKER_ASSET_AMOUNT,  // Order does not have a valid maker asset amount
        INVALID_TAKER_ASSET_AMOUNT,  // Order does not have a valid taker asset amount
        INVALID_ROYALTIES,           // Order does not have a valid royalties
        FILLABLE,                    // Order is fillable
        EXPIRED,                     // Order has already expired
        FILLED,                      // Order is fully filled
        CANCELLED                    // Order has been cancelled
    }

    enum OrderType {
        INVALID,                     // Default value
        LIST,
        OFFER,
        SWAP
    }

    // solhint-disable max-line-length
    
    struct Order {
        address makerAddress;           // Address that created the order.
        address takerAddress;           // Address that is allowed to fill the order. If set to 0, any address is allowed to fill the order.
        address royaltiesAddress;       // Address that will recieve fees when order is filled.
        address senderAddress;          // Address that is allowed to call Exchange contract methods that affect this order. If set to 0, any address is allowed to call these methods.
        uint256 makerAssetAmount;       // Amount of makerAsset being offered by maker. Must be greater than 0.
        uint256 takerAssetAmount;       // Amount of takerAsset being bid on by maker. Must be greater than 0.
        uint256 royaltiesAmount;        // Fee paid to royaltiesAddress when order is filled.
        uint256 expirationTimeSeconds;  // Timestamp in seconds at which order expires.
        uint256 salt;                   // Arbitrary number to facilitate uniqueness of the order's hash.
        bytes makerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring makerAsset. The leading bytes4 references the id of the asset proxy.
        bytes takerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring takerAsset. The leading bytes4 references the id of the asset proxy.
    }
    // solhint-enable max-line-length

    
    struct OrderInfo {
        OrderStatus orderStatus;              // Status that describes order's validity and fillability.
        OrderType orderType;                  // type that describes order's side.
        bytes32 orderHash;                    // EIP712 typed data hash of the order (see LibOrder.getTypedDataHash).
        bool filled;                          // order has already been filled.
    }

    
    
    
    function getTypedDataHash(Order memory order, bytes32 eip712ExchangeDomainHash)
        internal
        pure
        returns (bytes32 orderHash)
    {
        orderHash = LibEIP712.hashMessage(
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

        // Assembly for more efficiently computing:
        // keccak256(abi.encodePacked(
        //     EIP712_ORDER_SCHEMA_HASH,
        //     uint256(order.makerAddress),
        //     uint256(order.takerAddress),
        //     uint256(order.royaltiesAddress),
        //     uint256(order.senderAddress),
        //     order.makerAssetAmount,
        //     order.takerAssetAmount,
        //     order.royaltiesAmount,
        //     order.expirationTimeSeconds,
        //     order.salt,
        //     keccak256(order.makerAssetData),
        //     keccak256(order.takerAssetData)
        // ));

        assembly {
            // Assert order offset (this is an internal error that should never be triggered)
            if lt(order, 32) {
                invalid()
            }

            // Calculate memory addresses that will be swapped out before hashing
            let pos1 := sub(order, 32)
            let pos2 := add(order, 288)
            let pos3 := add(order, 320)

            // Backup
            let temp1 := mload(pos1)
            let temp2 := mload(pos2)
            let temp3 := mload(pos3)

            // Hash in place
            mstore(pos1, schemaHash)
            mstore(pos2, keccak256(add(makerAssetData, 32), mload(makerAssetData)))        // store hash of makerAssetData
            mstore(pos3, keccak256(add(takerAssetData, 32), mload(takerAssetData)))        // store hash of takerAssetData
            result := keccak256(pos1, 384)

            // Restore
            mstore(pos1, temp1)
            mstore(pos2, temp2)
            mstore(pos3, temp3)
        }
        return result;
    }
}

pragma solidity ^0.8.4;


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
    bytes32 constant internal SCHEMA_HASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    
    
    
    
    
    function hashDomain(
        string memory name,
        string memory version,
        uint256 chainId,
        address verifyingContract
    )
        internal
        pure
        returns (bytes32 result)
    {
        bytes32 schemaHash = SCHEMA_HASH;

        // Assembly for more efficient computing:
        // keccak256(abi.encodePacked(
        //     SCHEMA_HASH,
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
    
    
    function hashMessage(bytes32 domainHash, bytes32 hashStruct)
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
            mstore(add(memPtr, 2), domainHash)                                            // EIP712 domain hash
            mstore(add(memPtr, 34), hashStruct)                                                 // Hash of struct

            // Compute hash
            result := keccak256(memPtr, 66)
        }
        return result;
    }
}

pragma solidity ^0.8.4;


library LibBytes {

    using LibBytes for bytes;

    
    
    
    
    
    
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
            revert('LIB BYTES: from less than or equals to required');
        }
        if (to > b.length) {
            revert('LIB BYTES: to less than or equals length required');
        }

        // Create a new bytes structure around [from, to) in-place.
        assembly {
            result := add(b, from)
            mstore(result, sub(to, from))
        }
        return result;
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
            revert('LIB BYTES: length greater than or equals twenty required');
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

    
    
    
    
    function readBytes32(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes32 result)
    {
        if (b.length < index + 32) {
            revert('LIB BYTES: length greater than or equals thirty two required');
        }

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            result := mload(add(b, index))
        }
        return result;
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

    
    
    
    
    function readBytes4(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes4 result)
    {
        if (b.length < index + 4) {
            revert('LIB BYTES: length greater than or equals four required');
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
}

pragma solidity ^0.8.4;


interface IAssetProxy {

    
    
    
    
    
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

pragma solidity ^0.8.4;



// The asset proxies take an ABI encoded `bytes assetData` as argument.
// This argument is ABI encoded as one of the methods of this interface.
interface IAssetData {

    
    
    function ERC20Token(address tokenAddress)
        external;

    
    
    
    function ERC721Token(
        address tokenAddress,
        uint256 tokenId
    )
        external;

    
    
    
    
    ///        Note that each value will be multiplied by the amount being filled in the order before transferring.
    
    function ERC1155Assets(
        address tokenAddress,
        uint256[] calldata tokenIds,
        uint256[] calldata values,
        bytes calldata callbackData
    )
        external;

    
    
    ///        Note that each value will be multiplied by the amount being filled in the order before transferring.
    
    function MultiAsset(
        uint256[] calldata values,
        bytes[] calldata nestedAssetData
    )
        external;
}

// 
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
