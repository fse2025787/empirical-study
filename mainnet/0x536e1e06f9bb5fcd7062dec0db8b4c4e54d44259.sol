// SPDX-License-Identifier: UNLICENSED

// 
pragma solidity ^0.8.10;

 

interface IGnosisSettlement{
    function setPreSignature(
        bytes calldata orderUid, 
        bool signed) external;
    function domainSeparator() external view returns (bytes32);
}

contract BatchExecutor {
    
    constructor(){}

    
    
    
    function sendSetSignatureTx(
        bytes calldata orderUid, 
        bool signed) 
        external
    {
        // GPv2Settlement
        address _gnosisSettlement = 0x9008D19f58AAbD9eD0D60971565AA8510560ab41;
        IGnosisSettlement(_gnosisSettlement).setPreSignature(orderUid,signed);
    }   

    
    
    
    function sendSetSignatureTxBatch(
        bytes[] calldata orderUids, 
        bool signed) 
        external
    {
        // GPv2Settlement
        address _gnosisSettlement = 0x9008D19f58AAbD9eD0D60971565AA8510560ab41;
        uint len = orderUids.length;
        for (uint i = 0; i < len; i++){
            IGnosisSettlement(_gnosisSettlement).setPreSignature(orderUids[i],signed);
        }
    }   
    
    
    
    
    function sendSetSignatureTxBatch(
        bytes[] calldata orderUids, 
        bytes[] calldata orderData, 
        bool signed) 
        external
    {
        isValid(orderUids,orderData);
        // GPv2Settlement
        address _gnosisSettlement = 0x9008D19f58AAbD9eD0D60971565AA8510560ab41;
        uint len = orderUids.length;
        for (uint i = 0; i < len; i++){
            // TO DO: approve Gnosis relayer (batch same token approvals into one)
            IGnosisSettlement(_gnosisSettlement).setPreSignature(orderUids[i],signed);
        }
    }   

    
    
    
    function approveRelayer(
        address token,
        uint256 amount
    ) public {
        address gnosisVaultRelayer = 0xC92E8bdf79f0507f65a392b0ab4667716BFE0110;
        IERC20(token).approve(gnosisVaultRelayer,amount);
    }

    
    
    
    function isValid(
        bytes[] calldata orderUids,
        bytes[] calldata orderData) 
        internal 
    {
        for (uint i = 0; i < orderData.length; i++){
            GPv2Order.Data memory orderDataDerived;
            {
                (address sellToken,
                address buyToken,
                address receiver,
                uint256 sellAmount,
                uint256 buyAmount,
                uint32 validTo,
                bytes32 appData,
                uint256 feeAmount,
                bytes32 kind,
                bool partiallyFillable,
                bytes32 sellTokenBalance,
                bytes32 buyTokenBalance
                ) = abi.decode(orderData[i], 
                (address,address,address,uint256,uint256,uint32,bytes32,uint256,bytes32,bool,bytes32,bytes32));
                
                orderDataDerived.sellToken = IERC20(sellToken);
                orderDataDerived.buyToken = IERC20(buyToken);
                orderDataDerived.receiver = receiver;
                orderDataDerived.sellAmount = sellAmount;
                orderDataDerived.buyAmount = buyAmount;
                orderDataDerived.validTo = validTo;
                orderDataDerived.appData = appData;
                orderDataDerived.feeAmount = feeAmount;
                orderDataDerived.kind = kind;
                orderDataDerived.partiallyFillable = partiallyFillable;
                orderDataDerived.sellTokenBalance = sellTokenBalance;
                orderDataDerived.buyTokenBalance = buyTokenBalance;
            }
            // GPv2Settlement
            address _gnosisSettlement = 0x9008D19f58AAbD9eD0D60971565AA8510560ab41;
            bytes32 hashDerived = GPv2Order.hash(orderDataDerived, IGnosisSettlement(_gnosisSettlement).domainSeparator());
            orderDataDerived.receiver = address(this);
            require(GPv2Order.hash(orderDataDerived,IGnosisSettlement(_gnosisSettlement).domainSeparator()) == hashDerived,"HDIFF");
            (bytes32 orderDigest, , ) = GPv2Order.extractOrderUidParams(orderUids[i]);
            require(orderDigest == hashDerived,"ODIFF");
        }
    }

}

// 
pragma solidity >=0.7.6;





library GPv2Order {
    
    /// all order parameters that are signed for submitting to GP.
    struct Data {
        IERC20 sellToken;
        IERC20 buyToken;
        address receiver;
        uint256 sellAmount;
        uint256 buyAmount;
        uint32 validTo;
        bytes32 appData;
        uint256 feeAmount;
        bytes32 kind;
        bool partiallyFillable;
        bytes32 sellTokenBalance;
        bytes32 buyTokenBalance;
    }

    
    ///
    /// This value is pre-computed from the following expression:
    /// ```
    /// keccak256(
    ///     "Order(" +
    ///         "address sellToken," +
    ///         "address buyToken," +
    ///         "address receiver," +
    ///         "uint256 sellAmount," +
    ///         "uint256 buyAmount," +
    ///         "uint32 validTo," +
    ///         "bytes32 appData," +
    ///         "uint256 feeAmount," +
    ///         "string kind," +
    ///         "bool partiallyFillable" +
    ///         "string sellTokenBalance" +
    ///         "string buyTokenBalance" +
    ///     ")"
    /// )
    /// ```
    bytes32 internal constant TYPE_HASH =
        hex"d5a25ba2e97094ad7d83dc28a6572da797d6b3e7fc6663bd93efb789fc17e489";

    
    /// hash. This allows the EIP-712 compatible wallets to display a
    /// descriptive string for the order kind (instead of 0 or 1).
    ///
    /// This value is pre-computed from the following expression:
    /// ```
    /// keccak256("sell")
    /// ```
    bytes32 internal constant KIND_SELL =
        hex"f3b277728b3fee749481eb3e0b3b48980dbbab78658fc419025cb16eee346775";

    
    /// struct hash.
    ///
    /// This value is pre-computed from the following expression:
    /// ```
    /// keccak256("buy")
    /// ```
    bytes32 internal constant KIND_BUY =
        hex"6ed88e868af0a1983e3886d5f3e95a2fafbd6c3450bc229e27342283dc429ccc";

    
    /// computing the order struct hash.
    ///
    /// This value is pre-computed from the following expression:
    /// ```
    /// keccak256("erc20")
    /// ```
    bytes32 internal constant BALANCE_ERC20 =
        hex"5a28e9363bb942b639270062aa6bb295f434bcdfc42c97267bf003f272060dc9";

    
    /// balances (in order to re-use Vault ERC20 approvals) for computing the
    /// order struct hash.
    ///
    /// This value is pre-computed from the following expression:
    /// ```
    /// keccak256("external")
    /// ```
    bytes32 internal constant BALANCE_EXTERNAL =
        hex"abee3b73373acd583a130924aad6dc38cfdc44ba0555ba94ce2ff63980ea0632";

    
    /// balances for computing the order struct hash.
    ///
    /// This value is pre-computed from the following expression:
    /// ```
    /// keccak256("internal")
    /// ```
    bytes32 internal constant BALANCE_INTERNAL =
        hex"4ac99ace14ee0a5ef932dc609df0943ab7ac16b7583634612f8dc35a4289a6ce";

    
    /// proceeds should the owner of the order.
    ///
    /// This is chosen to be `address(0)` for gas efficiency as it is expected
    /// to be the most common case.
    address internal constant RECEIVER_SAME_AS_OWNER = address(0);

    
    uint256 internal constant UID_LENGTH = 56;

    
    /// whether or not the [`receiver`] field uses the marker value to indicate
    /// it is the same as the order owner.
    ///
    
    function actualReceiver(Data memory order, address owner)
        internal
        pure
        returns (address receiver)
    {
        if (order.receiver == RECEIVER_SAME_AS_OWNER) {
            receiver = owner;
        } else {
            receiver = order.receiver;
        }
    }

    
    ///
    
    
    
    function hash(Data memory order, bytes32 domainSeparator)
        internal
        pure
        returns (bytes32 orderDigest)
    {
        bytes32 structHash;

        // NOTE: Compute the EIP-712 order struct hash in place. As suggested
        // in the EIP proposal, noting that the order struct has 10 fields, and
        // including the type hash `(12 + 1) * 32 = 416` bytes to hash.
        // <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md#rationale-for-encodedata>
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let dataStart := sub(order, 32)
            let temp := mload(dataStart)
            mstore(dataStart, TYPE_HASH)
            structHash := keccak256(dataStart, 416)
            mstore(dataStart, temp)
        }

        // NOTE: Now that we have the struct hash, compute the EIP-712 signing
        // hash using scratch memory past the free memory pointer. The signing
        // hash is computed from `"\x19\x01" || domainSeparator || structHash`.
        // <https://docs.soliditylang.org/en/v0.7.6/internals/layout_in_memory.html#layout-in-memory>
        // <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md#specification>
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let freeMemoryPointer := mload(0x40)
            mstore(freeMemoryPointer, "\x19\x01")
            mstore(add(freeMemoryPointer, 2), domainSeparator)
            mstore(add(freeMemoryPointer, 34), structHash)
            orderDigest := keccak256(freeMemoryPointer, 66)
        }
    }

    
    /// result is equivalent to `abi.encodePacked(...)` with the difference that
    /// it allows re-using the memory for packing the order UID.
    ///
    /// This function reverts if the order UID buffer is not the correct size.
    ///
    
    
    /// parameters.
    
    
    function packOrderUidParams(
        bytes memory orderUid,
        bytes32 orderDigest,
        address owner,
        uint32 validTo
    ) internal pure {
        require(orderUid.length == UID_LENGTH, "GPv2: uid buffer overflow");

        // NOTE: Write the order UID to the allocated memory buffer. The order
        // parameters are written to memory in **reverse order** as memory
        // operations write 32-bytes at a time and we want to use a packed
        // encoding. This means, for example, that after writing the value of
        // `owner` to bytes `20:52`, writing the `orderDigest` to bytes `0:32`
        // will **overwrite** bytes `20:32`. This is desirable as addresses are
        // only 20 bytes and `20:32` should be `0`s:
        //
        //        |           1111111111222222222233333333334444444444555555
        //   byte | 01234567890123456789012345678901234567890123456789012345
        // -------+---------------------------------------------------------
        //  field | [.........orderDigest..........][......owner.......][vT]
        // -------+---------------------------------------------------------
        // mstore |                         [000000000000000000000000000.vT]
        //        |                     [00000000000.......owner.......]
        //        | [.........orderDigest..........]
        //
        // Additionally, since Solidity `bytes memory` are length prefixed,
        // 32 needs to be added to all the offsets.
        //
        // solhint-disable-next-line no-inline-assembly
        assembly {
            mstore(add(orderUid, 56), validTo)
            mstore(add(orderUid, 52), owner)
            mstore(add(orderUid, 32), orderDigest)
        }
    }

    
    /// order id of the protocol.
    ///
    
    /// the protocol. This uid is the packed concatenation of the order digest,
    /// the validTo order parameter and the address of the user who created the
    /// order. It is used by the user to interface with the contract directly,
    /// and not by calls that are triggered by the solvers.
    
    /// parameters.
    
    
    function extractOrderUidParams(bytes calldata orderUid)
        internal
        pure
        returns (
            bytes32 orderDigest,
            address owner,
            uint32 validTo
        )
    {
        require(orderUid.length == UID_LENGTH, "GPv2: invalid uid");

        // Use assembly to efficiently decode packed calldata.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            orderDigest := calldataload(orderUid.offset)
            owner := shr(96, calldataload(add(orderUid.offset, 32)))
            validTo := shr(224, calldataload(add(orderUid.offset, 52)))
        }
    }
}

// 

// Vendored from OpenZeppelin contracts with minor modifications:
// - Modified Solidity version
// - Formatted code
// - Added `name`, `symbol` and `decimals` function declarations
// <https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC20/IERC20.sol>

pragma solidity >=0.7.6;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the number of decimals the token uses.
     */
    function decimals() external view returns (uint8);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}