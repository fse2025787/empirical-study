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

pragma solidity ^0.6;







abstract contract FixinERC721Spender {

    // Mask of the lower 20 bytes of a bytes32.
    uint256 constant private ADDRESS_MASK = 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;

    
    
    
    
    
    function _transferERC721AssetFrom(
        IERC721Token token,
        address owner,
        address to,
        uint256 tokenId
    )
        internal
    {
        require(address(token) != address(this), "FixinERC721Spender/CANNOT_INVOKE_SELF");

        assembly {
            let ptr := mload(0x40) // free memory pointer

            // selector for transferFrom(address,address,uint256)
            mstore(ptr, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr, 0x04), and(owner, ADDRESS_MASK))
            mstore(add(ptr, 0x24), and(to, ADDRESS_MASK))
            mstore(add(ptr, 0x44), tokenId)

            let success := call(
                gas(),
                and(token, ADDRESS_MASK),
                0,
                ptr,
                0x64,
                0,
                0
            )

            if iszero(success) {
                let rdsize := returndatasize()
                returndatacopy(ptr, 0, rdsize)
                revert(ptr, rdsize)
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

pragma solidity ^0.6;







abstract contract FixinERC1155Spender {

    // Mask of the lower 20 bytes of a bytes32.
    uint256 constant private ADDRESS_MASK = 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;

    
    
    
    
    
    
    function _transferERC1155AssetFrom(
        IERC1155Token token,
        address owner,
        address to,
        uint256 tokenId,
        uint256 amount
    )
        internal
    {
        require(address(token) != address(this), "FixinERC1155Spender/CANNOT_INVOKE_SELF");

        assembly {
            let ptr := mload(0x40) // free memory pointer

            // selector for safeTransferFrom(address,address,uint256,uint256,bytes)
            mstore(ptr, 0xf242432a00000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr, 0x04), and(owner, ADDRESS_MASK))
            mstore(add(ptr, 0x24), and(to, ADDRESS_MASK))
            mstore(add(ptr, 0x44), tokenId)
            mstore(add(ptr, 0x64), amount)
            mstore(add(ptr, 0x84), 0xa0)
            mstore(add(ptr, 0xa4), 0)

            let success := call(
                gas(),
                and(token, ADDRESS_MASK),
                0,
                ptr,
                0xc4,
                0,
                0
            )

            if iszero(success) {
                let rdsize := returndatasize()
                returndatacopy(ptr, 0, rdsize)
                revert(ptr, rdsize)
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


    
    ///      reverts if the transfer fails.
    
    
    function _transferEth(address payable recipient, uint256 amount)
        internal
    {
        if (amount > 0) {
            (bool success,) = recipient.call{value: amount}("");
            require(success, "FixinTokenSpender::_transferEth/TRANSFER_FAILED");
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


interface INFTAuctionsFeature {

    
    ///      `isMatcher` is only valid for English auctions.
    ///      For Dutch auctions, `amountOrRate` should be treated as `amount`.
    ///      For English auctions, `amountOrRate` should be treated as `rate` with precision `1 ether`.
    struct AuctionFee {
        bool isMatcher;
        address recipient;
        uint256 amountOrRate;
        bytes feeData;
    }

    
    ///      Contains all the fields of the auction.
    event ERC721DutchAuctionPreSigned(
        address maker,
        uint128 startTime,
        uint128 endTime,
        uint256 nonce,
        IERC20TokenV06 erc20Token,
        uint256 startErc20TokenAmount,
        uint256 endErc20TokenAmount,
        AuctionFee[] fees,
        address nftToken,
        uint256 nftTokenId
    );

    
    ///      Contains all the fields of the auction.
    event ERC1155DutchAuctionPreSigned(
        address maker,
        uint128 startTime,
        uint128 endTime,
        uint256 nonce,
        IERC20TokenV06 erc20Token,
        uint256 startErc20TokenAmount,
        uint256 endErc20TokenAmount,
        AuctionFee[] fees,
        address nftToken,
        uint256 nftTokenId,
        uint128 nftTokenAmount
    );

    
    ///      Contains all the fields of the auction.
    event ERC721EnglishAuctionPreSigned(
        bool earlyMatch,
        address maker,
        uint128 startTime,
        uint128 endTime,
        uint256 nonce,
        IERC20TokenV06 erc20Token,
        uint256 startErc20TokenAmount,
        uint256 ReservedErc20TokenAmount,
        AuctionFee[] fees,
        address nftToken,
        uint256 nftTokenId
    );

    
    ///      Contains all the fields of the auction.
    event ERC1155EnglishAuctionPreSigned(
        bool earlyMatch,
        address maker,
        uint128 startTime,
        uint128 endTime,
        uint256 nonce,
        IERC20TokenV06 erc20Token,
        uint256 startErc20TokenAmount,
        uint256 ReservedErc20TokenAmount,
        AuctionFee[] fees,
        address nftToken,
        uint256 nftTokenId,
        uint128 nftTokenAmount
    );

    
    
    
    event NFTAuctionCancelled(
        address maker,
        uint256 nonce
    );

    
    enum AuctionStatus {
        INVALID_AMOUNT_SETTINGS,
        FILLABLE,
        UNFILLABLE,
        NOT_START,
        EXPIRED,
        INVALID_TIME_SETTINGS,
        INVALID_ERC1155_TOKEN_AMOUNT,
        INVALID_ERC721_TOKEN_AMOUNT,
        NATIVE_TOKEN_NOT_ALLOWED,
        TAKE_TOO_EARLY
    }

    
    enum NFTAuctionKind {
        ENGLISH,
        DUTCH
    }

    
    enum NFTKind {
        ERC721,
        ERC1155
    }

    
    struct NFTAuctionInfo {
        bytes32 auctionStructHash;
        bytes32 auctionHash;
        AuctionStatus status;
        uint128 remainingAmount;
    }

    
    
    
    
    
    
    
    
    
    
    event DutchAuctionFilled(
        NFTKind nftKind,
        address maker,
        address taker,
        uint256 nonce,
        IERC20TokenV06 erc20Token,
        uint256 erc20FillAmount,
        address nftToken,
        uint256 nftTokenId,
        uint128 nftTokenAmount
    );

    
    event EnglishAuctionFilled(
        NFTKind nftKind,
        bool earlyMatch,
        address auctionMaker,
        address bidMaker,
        address taker,
        uint256 nonce,
        IERC20TokenV06 erc20Token,
        uint256 erc20FillAmount,
        address nftToken,
        uint256 nftTokenId,
        uint128 nftTokenAmount
    );

    
    ///      `earlyMatch` is only valid for English auctions.
    ///      For Dutch auctions, `endOrReservedErc20TokenAmount` should be treated as `endErc20TokenAmount`.
    ///      For English auctions, `endOrReservedErc20TokenAmount` should be treated as `reservedErc20TokenAmount`.
    struct NFTAuction {
        NFTAuctionKind auctionKind;
        NFTKind nftKind;
        bool earlyMatch;
        address maker;
        uint128 startTime;
        uint128 endTime;
        uint256 nonce;
        IERC20TokenV06 erc20Token;
        uint256 startErc20TokenAmount;
        uint256 endOrReservedErc20TokenAmount;
        AuctionFee[] fees;
        address nftToken;
        uint256 nftTokenId;
        uint128 nftTokenAmount;
    }

    
    struct EnglishAuctionBid {
        NFTAuction auction;
        address bidMaker;
        uint256 erc20TokenAmount;
    }

    
    
    
    function getEnAuctionBidHash(EnglishAuctionBid calldata enBid) external view returns (bytes32 bidHash);

    
    function bidNFTDutchAuction(
        NFTAuction calldata dutchAuction,
        LibSignature.Signature calldata signature,
        uint128 bidAmount,
        bytes calldata callbackData
    ) external payable;

    
    
    
    function getNFTAuctionHash(NFTAuction calldata auction) external view returns (bytes32 auctionHash);

    
    ///      the auction, the `PRESIGNED` signature type will become
    ///      valid for that auction and signer.
    
    function preSignNFTAuction(NFTAuction calldata auction) external;
    
    
    
    
    function getNFTAuctionInfo(NFTAuction calldata auction) 
      external view returns (NFTAuctionInfo memory auctionInfo);

    
    ///      maker address and nonce range.
    
    
    ///        by maker address and the upper 248 bits of the
    ///        auction nonce. We define `nonceRange` to be these
    ///        248 bits.
    
    ///         given maker and nonce range.
    function getAuctionStatusBitVector(address maker, uint248 nonceRange) 
      external view returns (uint256 bitVector);

    
    ///      the given auction. Reverts if not.
    
    
    function validateAuctionSignature(
        NFTAuction calldata auction,
        LibSignature.Signature calldata signature
    ) external view;

    
    ///      the given English auction bid. Reverts if not.
    
    
    function validateEnAuctionBidSignature(
        EnglishAuctionBid calldata enBid,
        LibSignature.Signature calldata bidSig
    ) external view;

    
    ///      should be the maker of the auction. Silently succeeds if
    ///      an auction with the same nonce has already been filled or
    ///      cancelled.
    
    function cancelAuction(uint256 auctionNonce) external;

    
    ///      should be the maker of the auctions. Silently succeeds if
    ///      an auction with the same nonce has already been filled or
    ///      cancelled.
    
    function batchCancelAuctions(uint256[] calldata auctionNonces) external;

    
    function getNFTAuctionFilledAmount(bytes32 _hash) external view returns(uint128 filledAmount);

    
    function isNFTAuctionFillable(address maker, uint256 nonce) external view returns(bool);

    
    
    
    
    
    ///        ERC20 token of the auction is e.g. WETH, unwraps the
    ///        token before transferring it to the taker.
    
    ///        `zeroExTakerCallback` on `msg.sender` after
    ///        the ERC20 tokens have been transferred to `msg.sender`
    ///        but before transferring the NFT asset to the buyer.
    function acceptBid(
        EnglishAuctionBid calldata enBid,
        LibSignature.Signature calldata auctionSig,
        LibSignature.Signature calldata bidSig,
        bool unwrapNativeToken,
        bytes calldata takerCallbackData
    ) external;
}

// 
/*

  Copyright 2020 ZeroEx Intl.
  Modifications copyright (C) 2022 TheOpenDAO

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
                    keccak256("721FM"),
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

  Copyright 2021 TheOpenDAO

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




















contract NFTAuctionsFeature is
    IFeature,
    FixinERC721Spender,
    FixinERC1155Spender,
    FixinTokenSpender,
    FixinEIP712,
    FixinCommon,
    INFTAuctionsFeature
{
    using LibSafeMathV06 for uint256;
    using LibSafeMathV06 for uint128;

    
    string public constant override FEATURE_NAME = "Auctions";

    
    uint256 public immutable override FEATURE_VERSION = _encodeVersion(1, 0, 0);

    
    address constant private NATIVE_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    
    uint256 private constant CODE_ERC721  = 10000;

    
    uint256 private constant CODE_ERC1155 = 20000;
    
    
    uint256 private constant CODE_AUCTION = 30000;

    
    IEtherTokenV06 private immutable WETH;

    // keccak256(abi.encodePacked(
    //     "NFTAuction(",
    //         "uint8 auctionKind,",
    //         "uint8 nftKind,",
    //         "bool earlyMatch,",
    //         "address maker,",
    //         "uint128 startTime,",
    //         "uint128 endTime,",
    //         "uint256 nonce,",
    //         "address erc20Token,",
    //         "uint256 startErc20TokenAmount,",
    //         "uint256 endOrReservedErc20TokenAmount,",
    //         "AuctionFee[] fees,",
    //         "address nftToken,",
    //         "uint256 nftTokenId,",
    //         "uint128 nftTokenAmount",
    //     ")",
    //     "AuctionFee(bool isMatcher,address recipient,uint256 amountOrRate,bytes feeData)"
    // ));
    uint256 constant internal _AUCTION_TYPEHASH = 0x34d7d43b53221ee6752fa32d5ded36b33e740caf3f63cebc727ecf4cdf3e33b2;

    // keccak256(abi.encodePacked(
    //     "AuctionFee(",
    //         "bool isMatcher,",
    //         "address recipient,",
    //         "uint256 amountOrRate,",
    //         "bytes feeData",
    //     ")"
    // ));
    uint256 constant internal _FEE_TYPEHASH = 0x2b140d7226cf6abe7e4444eda0a7193418f3834740d024075cc30e873e6e970e;

    // keccak256(abi.encodePacked(
    //     "EnglishAuctionBid(",
    //         "NFTAuction auction,",
    //         "address bidMaker,",
    //         "uint256 erc20TokenAmount",
    //     ")",
    //     "AuctionFee(bool isMatcher,address recipient,uint256 amountOrRate,bytes feeData)",
    //     "NFTAuction(uint8 auctionKind,uint8 nftKind,bool earlyMatch,address maker,uint128 startTime,uint128 endTime,uint256 nonce,address erc20Token,uint256 startErc20TokenAmount,uint256 endOrReservedErc20TokenAmount,AuctionFee[] fees,address nftToken,uint256 nftTokenId,uint128 nftTokenAmount)"
    // ));
    uint256 constant internal _EN_AUCTION_BID_TYPEHASH = 0x0e81d1fc9d2f6b4a2129ba40325ec3a851f3a0c7dd470bcccbd624c4defee146;

    // Mask of the lower 20 bytes of a bytes32.
    uint256 private constant ADDRESS_MASK = (1 << 160) - 1;

    // keccak256("");
    bytes32 private constant _EMPTY_ARRAY_KECCAK256 = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

    
    bytes4 private constant FEE_CALLBACK_MAGIC_BYTES = IFeeRecipient.receiveZeroExFeeCallback.selector;

    
    bytes4 private constant TAKER_CALLBACK_MAGIC_BYTES = ITakerCallback.zeroExTakerCallback.selector;

    constructor(address zeroExAddress, IEtherTokenV06 weth) public FixinEIP712(zeroExAddress) {
        WETH = weth;
    }

    
    ///      Should be delegatecalled by `Migrate.migrate()`.
    
    function migrate() external virtual returns (bytes4 success) {
        _registerFeatureFunction(this.bidNFTDutchAuction.selector);
        _registerFeatureFunction(this.getNFTAuctionHash.selector);
        _registerFeatureFunction(this.preSignNFTAuction.selector);
        _registerFeatureFunction(this.getNFTAuctionInfo.selector);
        _registerFeatureFunction(this.getAuctionStatusBitVector.selector);
        _registerFeatureFunction(this.validateAuctionSignature.selector);
        _registerFeatureFunction(this.validateEnAuctionBidSignature.selector);
        _registerFeatureFunction(this.cancelAuction.selector);
        _registerFeatureFunction(this.batchCancelAuctions.selector);
        _registerFeatureFunction(this.getEnAuctionBidHash.selector);
        _registerFeatureFunction(this.acceptBid.selector);
        _registerFeatureFunction(this.onERC721Received.selector);
        _registerFeatureFunction(this.onERC1155Received.selector);
        _registerFeatureFunction(this.getNFTAuctionFilledAmount.selector);
        _registerFeatureFunction(this.isNFTAuctionFillable.selector);
        return LibMigrate.MIGRATE_SUCCESS;
    }

    
    function bidNFTDutchAuction(
        NFTAuction memory auction,
        LibSignature.Signature memory signature,
        uint128 bidAmount,
        bytes memory callbackData
    ) external override payable {
        uint256 ethBalanceBefore = address(this).balance.safeSub(msg.value);
        uint256 erc20FillAmount = _bidDutchAuction(
            msg.sender, // taker
            auction,
            signature,
            bidAmount,
            msg.value,
            callbackData
        );
        
        {
            uint256 ethBalanceAfter = address(this).balance;
            // Cannot use pre-existing ETH balance
            if (ethBalanceAfter < ethBalanceBefore) {
                // Unreachable code
                LibNFTOrdersRichErrors.OverspentEthError(
                    msg.value + (ethBalanceBefore - ethBalanceAfter),
                    msg.value
                ).rrevert();
            }
            // Refund
            _transferEth(msg.sender, ethBalanceAfter - ethBalanceBefore);
        }

        emit DutchAuctionFilled(
            auction.nftKind,
            auction.maker,
            msg.sender, // taker
            auction.nonce,
            auction.erc20Token,
            erc20FillAmount,
            auction.nftToken,
            auction.nftTokenId,
            auction.nftTokenAmount
        );
    }

    function _bidDutchAuction(
        address taker,
        NFTAuction memory auction,
        LibSignature.Signature memory signature,
        uint128 bidAmount,
        uint256 ethAvailable,
        bytes memory takerCallbackData
    ) private returns (uint256 erc20FillAmount) {
        require(auction.auctionKind == NFTAuctionKind.DUTCH, "NFTAuctionsFeature::bidNFTDutchAuction/AUCTION_KIND_NOT_DUTCH");

        NFTAuctionInfo memory auctionInfo = getNFTAuctionInfo(auction);

        // Check that the auction can be filled.
        _validateNFTAuction(auction, signature, auctionInfo, bidAmount);
       
        _updateAuctionState(auction.maker, auction.nonce, auctionInfo.auctionHash, auctionInfo.remainingAmount, bidAmount);

        // Rounding favors the auction maker.
        erc20FillAmount = LibMathV06.getPartialAmountCeil(
            auction.endTime.safeSub(block.timestamp),
            auction.endTime.safeSub(auction.startTime),
            auction.startErc20TokenAmount.safeSub(auction.endOrReservedErc20TokenAmount) // as endErc20TokenAmount
        ).safeAdd(auction.endOrReservedErc20TokenAmount); // as endErc20TokenAmount

        if (bidAmount != auction.nftTokenAmount) {
            // Rounding favors the auction maker.
            erc20FillAmount = LibMathV06.getPartialAmountCeil(
                bidAmount,
                auction.nftTokenAmount,
                erc20FillAmount
            );
        }

        if (auction.nftKind == NFTKind.ERC721) {
            _transferERC721AssetFrom(IERC721Token(auction.nftToken), auction.maker, taker, auction.nftTokenId);
        } else {
            _transferERC1155AssetFrom(IERC1155Token(auction.nftToken), auction.maker, taker, auction.nftTokenId, bidAmount);
        }
        
        if (takerCallbackData.length > 0) {
            require(
                taker != address(this),
                "NFTAuctionsFeature::_bidDutchAuction/CANNOT_CALLBACK_SELF"
            );
            uint256 ethBalanceBeforeCallback = address(this).balance;
            // Invoke the callback
            bytes4 callbackResult = ITakerCallback(taker)
                .zeroExTakerCallback(auctionInfo.auctionHash, takerCallbackData);
            // Update `ethAvailable` with amount acquired during the callback
            ethAvailable = ethAvailable.safeAdd(
                address(this).balance.safeSub(ethBalanceBeforeCallback)
            );
            // Check for the magic success bytes
            require(
                callbackResult == TAKER_CALLBACK_MAGIC_BYTES,
                "NFTAuctionsFeature::_bidDutchAuction/CALLBACK_FAILED"
            );
        }

        if (address(auction.erc20Token) == NATIVE_TOKEN_ADDRESS) {
            // Transfer ETH to the seller.
            _transferEth(payable(auction.maker), erc20FillAmount);

            // Fees are paid from the EP's current balance of ETH.
            _payEthFees(
                auction,
                erc20FillAmount,
                ethAvailable
            );
        } else if (auction.erc20Token == WETH) {
            // If there is enough ETH available, fill the WETH auction
            // (including fees) using that ETH.
            // Otherwise, transfer WETH from the taker.
            if (ethAvailable >= erc20FillAmount) {
                // Wrap ETH.
                WETH.deposit{value: erc20FillAmount}();
                // TODO: Probably safe to just use WETH.transfer for some
                //       small gas savings
                // Transfer WETH to the seller.
                _transferERC20Tokens(
                    WETH,
                    auction.maker,
                    erc20FillAmount
                );
                // Fees are paid from the EP's current balance of ETH.
                _payEthFees(
                    auction,
                    erc20FillAmount,
                    ethAvailable
                );
            } else {
                // Transfer WETH from the buyer to the seller.
                _transferERC20TokensFrom(
                    auction.erc20Token,
                    taker,
                    auction.maker,
                    erc20FillAmount
                );
                // The buyer pays fees using WETH.
                _payFees(
                    auction,
                    taker,
                    erc20FillAmount,
                    false
                );
            }
        } else {
            // Transfer ERC20 token from the buyer to the seller.
            _transferERC20TokensFrom(
                auction.erc20Token,
                taker,
                auction.maker,
                erc20FillAmount
            );
            // The buyer pays fees.
            _payFees(
                auction,
                taker,
                erc20FillAmount,
                false
            );
        }
    }

    function _payEthFees(
        NFTAuction memory auction,
        uint256 erc20FillAmount,
        uint256 ethAvailable
    ) private {
        // Pay fees using ETH.
        uint256 ethFees = _payFees(
            auction,
            address(this),
            erc20FillAmount,
            true
        );
        // Calc amount of ETH spent.
        uint256 ethSpent = erc20FillAmount.safeAdd(ethFees);
        if (ethSpent > ethAvailable) {
            LibNFTOrdersRichErrors.OverspentEthError(
                ethSpent,
                ethAvailable
            ).rrevert();
        }
    }

    function _payFees(
        NFTAuction memory auction,
        address payer,
        uint256 erc20FillAmount,
        bool useNativeToken
    ) private returns (uint256 totalFeesPaid) {
        // Make assertions about ETH case
        if (useNativeToken) {
            assert(payer == address(this));
            assert(
                auction.erc20Token == WETH ||
                address(auction.erc20Token) == NATIVE_TOKEN_ADDRESS
            );
        }

        for (uint256 i = 0; i < auction.fees.length; ++i) {
            AuctionFee memory fee = auction.fees[i];

            require(
                fee.recipient != address(this),
                "NFTAuctionsFeature::_payFees/RECIPIENT_CANNOT_BE_EXCHANGE_PROXY"
            );

            if (fee.amountOrRate == 0 || erc20FillAmount == 0) {
                continue;
            }
            uint256 feeFillAmount;
            if (auction.auctionKind == NFTAuctionKind.DUTCH) {
                // Round against the fee recipient
                feeFillAmount = LibMathV06.getPartialAmountFloor(
                    erc20FillAmount,
                    auction.startErc20TokenAmount,
                    fee.amountOrRate // as amount
                );
            } else {
                // Round against the fee recipient
                feeFillAmount = LibMathV06.getPartialAmountFloor(
                    fee.amountOrRate, // as rate with precision `1 ether`
                    1 ether,
                    erc20FillAmount
                );
            }
            if (feeFillAmount == 0) {
                continue;
            }

            if (useNativeToken) {
                // Transfer ETH to the fee recipient.
                _transferEth(payable(fee.recipient), feeFillAmount);
            } else {
                // Transfer ERC20 token from payer to recipient.
                _transferERC20TokensFrom(
                    auction.erc20Token,
                    payer,
                    fee.recipient,
                    feeFillAmount
                );
            }
            // Note that the fee callback is _not_ called if zero
            // `feeData` is provided. If `feeData` is provided, we assume
            // the fee recipient is a contract that implements the
            // `IFeeRecipient` interface.
            if (fee.feeData.length > 0) {
                // Invoke the callback
                bytes4 callbackResult = IFeeRecipient(fee.recipient).receiveZeroExFeeCallback(
                    useNativeToken ? NATIVE_TOKEN_ADDRESS : address(auction.erc20Token),
                    feeFillAmount,
                    fee.feeData
                );
                // Check for the magic success bytes
                require(
                    callbackResult == FEE_CALLBACK_MAGIC_BYTES,
                    "NFTAuctionsFeature::_payFees/CALLBACK_FAILED"
                );
            }
            // Sum the fees paid
            totalFeesPaid = totalFeesPaid.safeAdd(feeFillAmount);
        }
    }

    
    ///      should be the maker of the auction. Silently succeeds if
    ///      an auction with the same nonce has already been filled or
    ///      cancelled.
    
    function cancelAuction(uint256 auctionNonce) public override {
        // get the low 8 bits as a flag.
        uint256 flag = 1 << (auctionNonce & 255);
        LibNFTAuctionsStorage.Storage storage stor = LibNFTAuctionsStorage.getStorage();
        // get the high 248 bits as an index.
        // set the flag corresponding to the index.
        stor.auctionCancellationByMaker[msg.sender][uint248(auctionNonce >> 8)] |= flag;
        emit NFTAuctionCancelled(msg.sender, auctionNonce);
    }

    
    ///      should be the maker of the auctions. Silently succeeds if
    ///      an auction with the same nonce has already been filled or
    ///      cancelled.
    
    function batchCancelAuctions(uint256[] calldata auctionNonces) external override {
        uint256 len = auctionNonces.length;
        for (uint256 i = 0; i < len; ++i) {
            cancelAuction(auctionNonces[i]);
        }
    }

    function _updateAuctionState(address maker, uint256 nonce, bytes32 _hash, uint128 remaining, uint128 amount) internal {
        LibNFTAuctionsStorage.Storage storage stor = LibNFTAuctionsStorage.getStorage();
        if (remaining == amount) {
            uint256 flag = 1 << (nonce & 255);
            stor.auctionCancellationByMaker[maker][uint248(nonce >> 8)] |= flag;
        } else {
            uint128 filledAmount = stor.auctionState[_hash].filledAmount;
            stor.auctionState[_hash].filledAmount = filledAmount.safeAdd128(amount);
        }
    }

    
    function getNFTAuctionFilledAmount(bytes32 _hash) external override view virtual returns(uint128 filledAmount) {
        LibNFTAuctionsStorage.Storage storage stor = LibNFTAuctionsStorage.getStorage();
        filledAmount = stor.auctionState[_hash].filledAmount;
    }

    
    function isNFTAuctionFillable(address maker, uint256 nonce) external override virtual view returns(bool) {
        LibNFTAuctionsStorage.Storage storage stor = LibNFTAuctionsStorage.getStorage();
        uint256 auctionCancellationBitVector = stor.auctionCancellationByMaker[maker][uint248(nonce >> 8)];
        uint256 flag = 1 << (nonce & 255);
        return auctionCancellationBitVector & flag == 0;
    }

    
    
    
    function getNFTAuctionInfo(NFTAuction memory auction) public override view returns (NFTAuctionInfo memory auctionInfo) {
        auctionInfo.auctionStructHash = _getNFTAuctionStructHash(auction);
        auctionInfo.auctionHash = _getEIP712Hash(auctionInfo.auctionStructHash);

        if (auction.nftKind == NFTKind.ERC721) {
            if (auction.nftTokenAmount != 1) {
                auctionInfo.status = AuctionStatus.INVALID_ERC721_TOKEN_AMOUNT;
                return auctionInfo;
            }
        } else {
            if (auction.nftTokenAmount == 0) {
                auctionInfo.status = AuctionStatus.INVALID_ERC1155_TOKEN_AMOUNT;
                return auctionInfo;
            }
        }

        if (auction.endTime <= auction.startTime) {
            auctionInfo.status = AuctionStatus.INVALID_TIME_SETTINGS;
            return auctionInfo;
        } else if (block.timestamp < auction.startTime) {
            auctionInfo.status = AuctionStatus.NOT_START;
            return auctionInfo;
        }

        if (auction.auctionKind == NFTAuctionKind.DUTCH) {
            if (auction.endTime < block.timestamp) {
                auctionInfo.status = AuctionStatus.EXPIRED;
                return auctionInfo;
            } else if (auction.endOrReservedErc20TokenAmount >= auction.startErc20TokenAmount) { // as endErc20TokenAmount
                auctionInfo.status = AuctionStatus.INVALID_AMOUNT_SETTINGS;
                return auctionInfo;
            }
        } else {
            if (address(auction.erc20Token) == NATIVE_TOKEN_ADDRESS) {
                auctionInfo.status = AuctionStatus.NATIVE_TOKEN_NOT_ALLOWED;
                return auctionInfo;
            } else if (!auction.earlyMatch && block.timestamp <= auction.endTime) {
                auctionInfo.status = AuctionStatus.TAKE_TOO_EARLY;
                return auctionInfo;
            }
        }

        LibNFTAuctionsStorage.Storage storage stor = LibNFTAuctionsStorage.getStorage();

        // drop the low 8 bits to get the auctionStatusBitVector index.
        uint256 auctionCancellationBitVector = stor.auctionCancellationByMaker[auction.maker][uint248(auction.nonce >> 8)];
        // use the low 8 bits to index auctionCancellationBitVector.
        uint256 flag = 1 << (auction.nonce & 255);
        if (auctionCancellationBitVector & flag != 0) {
            auctionInfo.status = AuctionStatus.UNFILLABLE;
            return auctionInfo;
        }

        if (auction.nftKind == NFTKind.ERC1155) {
            LibNFTAuctionsStorage.AuctionState storage auctionState = stor.auctionState[auctionInfo.auctionHash];
            auctionInfo.remainingAmount = auction.nftTokenAmount.safeSub128(auctionState.filledAmount);
        } else {
            auctionInfo.remainingAmount = 1;
        }

        // Otherwise, the auction is fillable.
        auctionInfo.status = AuctionStatus.FILLABLE;
    }

    
    ///      maker address and nonce range.
    
    
    ///        by maker address and the upper 248 bits of the
    ///        auction nonce. We define `nonceRange` to be these
    ///        248 bits.
    
    ///         given maker and nonce range.
    function getAuctionStatusBitVector(address maker, uint248 nonceRange) external override view returns (uint256 bitVector) {
        LibNFTAuctionsStorage.Storage storage stor = LibNFTAuctionsStorage.getStorage();
        return stor.auctionCancellationByMaker[maker][nonceRange];
    }

    function _validateNFTAuction(
        NFTAuction memory auction,
        LibSignature.Signature memory signature,
        NFTAuctionInfo memory auctionInfo,
        uint128 bidAmount
    ) private view {
        if(auction.nftKind == NFTKind.ERC721) {
            require(bidAmount == 1, "NFTAuctionsFeature::_validateNFTAuction/INVALID_ERC721_BID_AMOUNT");
        } else {
            require(bidAmount >= 1, "NFTAuctionsFeature::_validateNFTAuction/INVALID_ERC1155_BID_AMOUNT");
        }

        // Check that the auction is valid and has not expired, been cancelled, or been filled.
        if (auctionInfo.status != AuctionStatus.FILLABLE) {
            LibNFTOrdersRichErrors.OrderNotFillableError(
                auction.maker,
                auction.nonce,
                uint8(auctionInfo.status)
            ).rrevert();
        }

        if (bidAmount > auctionInfo.remainingAmount) {
            LibNFTOrdersRichErrors.ExceedsRemainingOrderAmount(
                auctionInfo.remainingAmount,
                bidAmount
            ).rrevert();
        }

        // Check the signature.
        _validateAuctionSignature(auctionInfo.auctionHash, signature, auction.maker);
    }

    
    ///      the given auction. Reverts if not.
    
    
    function validateAuctionSignature(
        NFTAuction memory auction,
        LibSignature.Signature memory signature
    ) external override view {
        bytes32 _hash = getNFTAuctionHash(auction);
        _validateAuctionSignature(_hash, signature, auction.maker);
    }

    
    ///      the given English auction bid. Reverts if not.
    
    
    function validateEnAuctionBidSignature(
        EnglishAuctionBid memory enBid,
        LibSignature.Signature memory bidSig
    ) external override view {
        bytes32 auctionStructHash = _getNFTAuctionStructHash(enBid.auction);
        _validateEnAuctionBidSignature(auctionStructHash, enBid, bidSig);
    }

    function _validateEnAuctionBidSignature(
        bytes32 auctionStructHash,
        EnglishAuctionBid memory enBid,
        LibSignature.Signature memory bidSig
    ) private view {
        require(
            bidSig.signatureType != LibSignature.SignatureType.PRESIGNED, 
            "NFTAuctionsFeature::_validateEnAuctionBidSignature/SIGNATURE_TYPE_CANNOT_BE_PRESIGNED"
        );
        bytes32 _hash = _getEIP712Hash(_getEnAuctionBidStructHash(enBid, auctionStructHash));
        _validateAuctionSignature(_hash, bidSig, enBid.bidMaker);
    }
    
    function _validateAuctionSignature(
        bytes32 auctionHash,
        LibSignature.Signature memory signature,
        address maker
    ) private view {
        if (signature.signatureType == LibSignature.SignatureType.PRESIGNED) {
            // Check if auction hash has been pre-signed by the maker.
            bool isPreSigned = LibNFTAuctionsStorage.getStorage().auctionState[auctionHash].preSigned;
            if (!isPreSigned) {
                LibNFTOrdersRichErrors.InvalidSignerError(maker, address(0)).rrevert();
            }
        } else {
            address signer = LibSignature.getSignerOfHash(auctionHash, signature);
            if (signer != maker) {
                LibNFTOrdersRichErrors.InvalidSignerError(maker, signer).rrevert();
            }
        }
    }

    
    
    
    function getNFTAuctionHash(NFTAuction memory auction) public override view returns (bytes32 auctionHash) {
        return _getEIP712Hash(_getNFTAuctionStructHash(auction));
    }

    
    
    
    function getEnAuctionBidHash(EnglishAuctionBid memory enBid) external override view returns (bytes32 bidHash) {
        bytes32 auctionHash = _getNFTAuctionStructHash(enBid.auction);
        return _getEIP712Hash(_getEnAuctionBidStructHash(enBid, auctionHash));
    }

    function _getNFTAuctionStructHash(NFTAuction memory auction) private pure returns (bytes32 structHash) {
        bytes32 feesHash = _feesHash(auction.fees);
        // Hash in place, equivalent to:
        // return keccak256(abi.encode(
        //     _AUCTION_TYPEHASH,-1
        //     uint8 auctionKind;0
        //     uint8 nftKind;1
        //     bool earlyMatch;2
        //     address maker;3
        //     uint128 startTime;4
        //     uint128 endTime;
        //     uint256 nonce;
        //     address erc20Token;
        //     uint256 startErc20TokenAmount;
        //     uint256 endOrReservedErc20TokenAmount;
        //     AuctionFee[] fees;10
        //     address nftToken;
        //     uint256 nftTokenId;
        //     uint128 nftTokenAmount;13
        // ));
        assembly {
            if lt(auction, 32) { invalid() } // Don't underflow memory.

            let typeHashPos := sub(auction, 32) // auction - 32
            let feesHashPos := add(auction, 320) // auction + (32 * 10)

            let typeHashMemBefore := mload(typeHashPos)
            let feeHashMemBefore := mload(feesHashPos)

            mstore(typeHashPos, _AUCTION_TYPEHASH)
            mstore(feesHashPos, feesHash)
            structHash := keccak256(typeHashPos, 480 /* 32 * 15 */ )

            mstore(typeHashPos, typeHashMemBefore)
            mstore(feesHashPos, feeHashMemBefore)
        }
        return structHash;
    }

    function _getEnAuctionBidStructHash(EnglishAuctionBid memory enBid, bytes32 auctionHash) private pure returns (bytes32 structHash) {
        // Hash in place, equivalent to:
        // return keccak256(abi.encode(
        //     _EN_AUCTION_BID_TYPEHASH,-1
        //     NFTAuction auction;0
        //     address bidMaker;1
        //     uint256 erc20TokenAmount;2
        // ));
        assembly {
            if lt(enBid, 32) { invalid() } // Don't underflow memory.

            let typeHashPos := sub(enBid, 32) // auction - 32
            let auctionHashPos := enBid // auction

            let typeHashMemBefore := mload(typeHashPos)
            let auctionHashMemBefore := mload(auctionHashPos)

            mstore(typeHashPos, _EN_AUCTION_BID_TYPEHASH)
            mstore(auctionHashPos, auctionHash)
            structHash := keccak256(typeHashPos, 128 /* 32 * 4 */ )

            mstore(typeHashPos, typeHashMemBefore)
            mstore(auctionHashPos, auctionHashMemBefore)
        }
        return structHash;
    }

    // Hashes the `fees` array as part of computing the EIP-712 hash of an auction.
    function _feesHash(AuctionFee[] memory fees) private pure returns (bytes32 feesHash) {
        uint256 numFees = fees.length;
        // We give `fees.length == 0` and `fees.length == 1`
        // special treatment because we expect these to be the most common.
        if (numFees == 0) {
            feesHash = _EMPTY_ARRAY_KECCAK256;
        } else if (numFees == 1) {
            // feesHash = keccak256(abi.encodePacked(keccak256(abi.encode(
            //     _FEE_TYPEHASH,0,0
            //     fees[0].isMatcher,1,32
            //     fees[0].recipient,2,64
            //     fees[0].amountOrRate,3,96
            //     keccak256(fees[0].feeData)4,128
            // ))));
            AuctionFee memory fee = fees[0];
            bytes32 dataHash = keccak256(fee.feeData);
            assembly {
                // Load free memory pointer
                let mem := mload(64)
                mstore(mem, _FEE_TYPEHASH)
                // fee.isMatcher
                mstore(add(mem, 32), mload(fee))
                // fee.recipient
                mstore(add(mem, 64), and(ADDRESS_MASK, mload(add(fee, 32))))
                // fee.amountOrRate
                mstore(add(mem, 96), mload(add(fee, 64)))
                // keccak256(fee.feeData)
                mstore(add(mem, 128), dataHash)
                mstore(mem, keccak256(mem, 160))
                feesHash := keccak256(mem, 32)
            }
        } else {
            bytes32[] memory feeStructHashArray = new bytes32[](numFees);
            for (uint256 i = 0; i < numFees; i++) {
                feeStructHashArray[i] = keccak256(abi.encode(
                    _FEE_TYPEHASH,
                    fees[i].isMatcher,
                    fees[i].recipient,
                    fees[i].amountOrRate,
                    keccak256(fees[i].feeData)
                ));
            }
            assembly {
                feesHash := keccak256(add(feeStructHashArray, 32), mul(numFees, 32))
            }
        }
    }

    
    ///      the auction, the `PRESIGNED` signature type will become
    ///      valid for that auction and signer.
    
    function preSignNFTAuction(NFTAuction memory auction) external override {
        require(auction.maker == msg.sender, "NFTAuctionsFeature::preSignNFTAuction/ONLY_MAKER");
        if (auction.nftKind == NFTKind.ERC721) {
            require(auction.nftTokenAmount == 1, "NFTAuctionsFeature::preSignNFTAuction/INVALID_ERC721_TOKEN_AMOUNT");
        }
        LibNFTAuctionsStorage.getStorage().auctionState[getNFTAuctionHash(auction)].preSigned = true;
        if (auction.auctionKind == NFTAuctionKind.DUTCH) {
            if (auction.nftKind == NFTKind.ERC721) {
                emit ERC721DutchAuctionPreSigned(
                    auction.maker,
                    auction.startTime,
                    auction.endTime,
                    auction.nonce,
                    auction.erc20Token,
                    auction.startErc20TokenAmount,
                    auction.endOrReservedErc20TokenAmount, // as endErc20TokenAmount
                    auction.fees,
                    auction.nftToken,
                    auction.nftTokenId
                );
            } else {
                emit ERC1155DutchAuctionPreSigned(
                    auction.maker,
                    auction.startTime,
                    auction.endTime,
                    auction.nonce,
                    auction.erc20Token,
                    auction.startErc20TokenAmount,
                    auction.endOrReservedErc20TokenAmount, // as endErc20TokenAmount
                    auction.fees,
                    auction.nftToken,
                    auction.nftTokenId,
                    auction.nftTokenAmount
                );
            }
        } else {
            if (auction.nftKind == NFTKind.ERC721) {
                emit ERC721EnglishAuctionPreSigned(
                    auction.earlyMatch,
                    auction.maker,
                    auction.startTime,
                    auction.endTime,
                    auction.nonce,
                    auction.erc20Token,
                    auction.startErc20TokenAmount,
                    auction.endOrReservedErc20TokenAmount, // as reservedErc20TokenAmount
                    auction.fees,
                    auction.nftToken,
                    auction.nftTokenId
                );
            } else {
                emit ERC1155EnglishAuctionPreSigned(
                    auction.earlyMatch,
                    auction.maker,
                    auction.startTime,
                    auction.endTime,
                    auction.nonce,
                    auction.erc20Token,
                    auction.startErc20TokenAmount,
                    auction.endOrReservedErc20TokenAmount, // as reservedErc20TokenAmount
                    auction.fees,
                    auction.nftToken,
                    auction.nftTokenId,
                    auction.nftTokenAmount
                );
            }
        }
    }

    function _validateSender(address taker, EnglishAuctionBid memory enBid) internal pure returns(bool) {
        if (taker == enBid.auction.maker) {
            return true;
        } else if (enBid.erc20TokenAmount >= enBid.auction.endOrReservedErc20TokenAmount) { // as reservedErc20TokenAmount
            for (uint256 i = 0; i < enBid.auction.fees.length; ++i) {
                if (enBid.auction.fees[i].recipient == taker && enBid.auction.fees[i].isMatcher) {
                    return true;
                }
            }
        }
        return false;
    }

    
    
    
    
    
    ///        ERC20 token of the auction is e.g. WETH, unwraps the
    ///        token before transferring it to the taker.
    
    ///        `zeroExTakerCallback` on `msg.sender` after
    ///        the ERC20 tokens have been transferred to `msg.sender`
    ///        but before transferring the NFT asset to the buyer.
    function acceptBid(
        EnglishAuctionBid memory enBid,
        LibSignature.Signature memory auctionSig,
        LibSignature.Signature memory bidSig,
        bool unwrapNativeToken,
        bytes memory takerCallbackData
    ) external override {
        _acceptBid(enBid.auction.maker, msg.sender, enBid, auctionSig, bidSig, unwrapNativeToken, takerCallbackData);
    }

    function _acceptBid(
        address nftOwner,
        address taker,
        EnglishAuctionBid memory enBid,
        LibSignature.Signature memory auctionSig,
        LibSignature.Signature memory bidSig,
        bool unwrapNativeToken,
        bytes memory takerCallbackData
    ) private {
        require(enBid.auction.auctionKind == NFTAuctionKind.ENGLISH, "NFTAuctionsFeature::acceptBid/AUCTION_KIND_NOT_ENGLISH");
        require(enBid.erc20TokenAmount >= enBid.auction.startErc20TokenAmount, "NFTAuctionsFeature::acceptBid/PRICE_TOO_LOW");
        require(_validateSender(taker, enBid), "NFTAuctionsFeature::acceptBid/NO_PERMISSION_TO_TAKE");

        NFTAuctionInfo memory auctionInfo = getNFTAuctionInfo(enBid.auction);

        // check the signature for the English bid.
        _validateEnAuctionBidSignature(auctionInfo.auctionStructHash, enBid, bidSig);

        // Check that the auction can be filled.
        _validateNFTAuction(enBid.auction, auctionSig, auctionInfo, enBid.auction.nftTokenAmount);

        _updateAuctionState(enBid.auction.maker, enBid.auction.nonce, auctionInfo.auctionHash, auctionInfo.remainingAmount, enBid.auction.nftTokenAmount);

        if (unwrapNativeToken) {
            // The ERC20 token must be WETH for it to be unwrapped.
            if (enBid.auction.erc20Token != WETH) {
                LibNFTOrdersRichErrors.ERC20TokenMismatchError(
                    address(enBid.auction.erc20Token),
                    address(WETH)
                ).rrevert();
            }
            // Transfer the WETH from the maker to the Exchange Proxy
            // so we can unwrap it before sending it to the seller.
            // TODO: Probably safe to just use WETH.transferFrom for some
            //       small gas savings
            _transferERC20TokensFrom(
                WETH,
                enBid.bidMaker,
                address(this),
                enBid.erc20TokenAmount
            );
            // Unwrap WETH into ETH.
            WETH.withdraw(enBid.erc20TokenAmount);
            // Send ETH to the seller.
            _transferEth(payable(enBid.auction.maker), enBid.erc20TokenAmount);
        } else {
            // Transfer the ERC20 token from the buyer to the seller.
            _transferERC20TokensFrom(
                enBid.auction.erc20Token,
                enBid.bidMaker,
                enBid.auction.maker,
                enBid.erc20TokenAmount
            );
        }

        if (takerCallbackData.length > 0) {
            require(taker != address(this), "NFTAuctionsFeature::_acceptBid/CANNOT_CALLBACK_SELF");
            // Invoke the callback
            bytes4 callbackResult = ITakerCallback(taker).zeroExTakerCallback(auctionInfo.auctionHash, takerCallbackData);
            // Check for the magic success bytes
            require(callbackResult == TAKER_CALLBACK_MAGIC_BYTES, "NFTAuctionsFeature::_acceptBid/CALLBACK_FAILED");
        }

        if (enBid.auction.nftKind == NFTKind.ERC721) {
            _transferERC721AssetFrom(IERC721Token(enBid.auction.nftToken), nftOwner, enBid.bidMaker, enBid.auction.nftTokenId);
        } else {
            _transferERC1155AssetFrom(IERC1155Token(enBid.auction.nftToken), nftOwner, enBid.bidMaker, enBid.auction.nftTokenId, enBid.auction.nftTokenAmount);
        }

        {
            uint256 len = enBid.auction.fees.length;
            for (uint256 i = 0; i < len; ++i) {
                if (enBid.auction.fees[i].isMatcher && enBid.auction.fees[i].recipient != taker) {
                    enBid.auction.fees[i].amountOrRate = 0; // as rate with precision `1 ether`
                }
            }
        }

        _payFees(
            enBid.auction,
            enBid.bidMaker,
            enBid.erc20TokenAmount,
            false
        );

        _emitEnglishAuctionFilled(enBid, taker);
    }

    function _emitEnglishAuctionFilled(EnglishAuctionBid memory enBid, address taker) private {
        emit EnglishAuctionFilled(
            enBid.auction.nftKind,
            enBid.auction.earlyMatch,
            enBid.auction.maker,
            enBid.bidMaker,
            taker,
            enBid.auction.nonce,
            enBid.auction.erc20Token,
            enBid.erc20TokenAmount,
            enBid.auction.nftToken,
            enBid.auction.nftTokenId,
            enBid.auction.nftTokenAmount
        );
    }

    function _onNFTReceived(        
        address operator,
        address /*from*/,
        uint256 tokenId,
        uint256 value,
        bytes calldata data
    ) private {
        (
            uint256 c,
            EnglishAuctionBid memory enBid,
            LibSignature.Signature memory auctionSig,
            LibSignature.Signature memory bidSig,
            bool unwrapNativeToken
        ) = abi.decode(
            data,
            (uint256, EnglishAuctionBid, LibSignature.Signature, LibSignature.Signature, bool)
        );c;
        require(enBid.auction.nftTokenId == tokenId, "NFTAuctionsFeature::_onNFTReceived/TOKEN_ID_MISMATCH");
        require(enBid.auction.nftTokenAmount == value, "NFTAuctionsFeature::_onNFTReceived/TOKEN_AMOUNT_MISMATCH");
        if (msg.sender != enBid.auction.nftToken) {
            if (enBid.auction.nftKind == NFTKind.ERC721) {
                LibNFTOrdersRichErrors.ERC721TokenMismatchError(msg.sender, address(enBid.auction.nftToken)).rrevert();
            } else {
                LibNFTOrdersRichErrors.ERC1155TokenMismatchError(msg.sender, address(enBid.auction.nftToken)).rrevert();
            }
        }
        _acceptBid(address(this), operator, enBid, auctionSig, bidSig, unwrapNativeToken, new bytes(0));
    }

    function onERC721Received(address operator, address from, uint256 tokenId,
        bytes calldata data) external returns (bytes4) 
    {
        (uint256 code) = abi.decode(data[:32], (uint256));
        if (code == CODE_ERC721) {
             (bool success, bytes memory resultData) = address(this).delegatecall(
                abi.encodeWithSelector(
                    IOnNFTReceived.onERC721Received2.selector,
                    operator, from, tokenId, data
                )
            );
            if (!success) {
                _revertWithData(resultData);
            }
            _returnWithData(resultData);
        } else if (code == CODE_AUCTION) {
            _onNFTReceived(operator,from,tokenId,1,data);
            return this.onERC721Received.selector;
        }
        revert("NFTAuctionsFeature::onERC721Received/UNKNOWN_CODE");
    }

    function onERC1155Received(address operator, address from, uint256 tokenId, 
        uint256 value, bytes calldata data) external returns (bytes4)
    {
        (uint256 code) = abi.decode(data[:32], (uint256));
        if (code == CODE_ERC1155) {
            (bool success, bytes memory resultData) = address(this).delegatecall(
                abi.encodeWithSelector(
                    IOnNFTReceived.onERC1155Received2.selector,
                    operator, from, tokenId, value, data
                )
            );
            if (!success) {
                _revertWithData(resultData);
            }
            _returnWithData(resultData);
        } else if (code == CODE_AUCTION) {
            _onNFTReceived(operator,from,tokenId,value,data);
            return this.onERC1155Received.selector;
        }
        revert("NFTAuctionsFeature::onERC1155Received/UNKNOWN_CODE");
    }

    
    
    function _revertWithData(bytes memory data) private pure {
        assembly { revert(add(data, 32), mload(data)) }
    }

    
    
    function _returnWithData(bytes memory data) private pure {
        assembly { return(add(data, 32), mload(data)) }
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

  Copyright 2021 ZeroEx Intl.
  Modifications copyright (C) 2022 TheOpenDAO

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

    
    
    
    event ERC721OrderCancelled(
        address maker,
        uint256 nonce
    );

    
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
    )
        external;

    
    
    
    
    ///        `zeroExERC721OrderCallback` on `msg.sender` after
    ///        the ERC721 asset has been transferred to `msg.sender`
    ///        but before transferring the ERC20 tokens to the seller.
    ///        Native tokens acquired during the callback can be used
    ///        to fill the order.
    function buyERC721(
        LibNFTOrder.ERC721Order calldata sellOrder,
        LibSignature.Signature calldata signature,
        bytes calldata callbackData
    )
        external
        payable;

    
    ///      should be the maker of the order. Silently succeeds if
    ///      an order with the same nonce has already been filled or
    ///      cancelled.
    
    function cancelERC721Order(uint256 orderNonce)
        external;

    
    ///      should be the maker of the orders. Silently succeeds if
    ///      an order with the same nonce has already been filled or
    ///      cancelled.
    
    function batchCancelERC721Orders(uint256[] calldata orderNonces)
        external;

    
    ///      given orders.
    
    
    
    ///        function fails to fill any individual order.
    
    ///        callback for each order. Refer to the `callbackData`
    ///        parameter to for `buyERC721`.
    
    
    ///         each order in `orders` was successfully filled.
    function batchBuyERC721sWithMaxNumber(
        LibNFTOrder.ERC721Order[] calldata sellOrders,
        LibSignature.Signature[] calldata signatures,
        bytes[] calldata callbackData,
        bool revertIfIncomplete,
        uint256 maxNFTs
    )
    external
    payable
    returns (bool[] memory successes);

    
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
    )
        external
        payable
        returns (bool[] memory successes);

    
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
    )
        external
        returns (uint256 profit);

    
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
    )
        external
        returns (uint256[] memory profits, bool[] memory successes);

    
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
    )
        external
        returns (bytes4 success);

    
    ///      the order, the `PRESIGNED` signature type will become
    ///      valid for that order and signer.
    
    function preSignERC721Order(LibNFTOrder.ERC721Order calldata order)
        external;

    
    ///      the given ERC721 order. Reverts if not.
    
    
    function validateERC721OrderSignature(
        LibNFTOrder.ERC721Order calldata order,
        LibSignature.Signature calldata signature
    )
        external
        view;

    
    ///      whether or not the given token ID satisfies the required
    ///      properties specified in the order. If the order does not
    ///      specify any properties, this function instead checks
    ///      whether the given token ID matches the ID in the order.
    ///      Reverts if any checks fail, or if the order is selling
    ///      an ERC721 asset.
    
    
    function validateERC721OrderProperties(
        LibNFTOrder.ERC721Order calldata order,
        uint256 erc721TokenId
    )
        external
        view;

    
    
    
    function getERC721OrderStatus(LibNFTOrder.ERC721Order calldata order)
        external
        view
        returns (LibNFTOrder.OrderStatus status);

    
    
    
    function getERC721OrderHash(LibNFTOrder.ERC721Order calldata order)
        external
        view
        returns (bytes32 orderHash);

    
    ///      maker address and nonce range.
    
    
    ///        by maker address and the upper 248 bits of the
    ///        order nonce. We define `nonceRange` to be these
    ///        248 bits.
    
    ///         given maker and nonce range.
    function getERC721OrderStatusBitVector(address maker, uint248 nonceRange)
        external
        view
        returns (uint256 bitVector);
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


















abstract contract NFTOrders is
    FixinCommon,
    FixinEIP712,
    FixinTokenSpender
{
    using LibSafeMathV06 for uint256;

    
    address constant internal NATIVE_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    
    IEtherTokenV06 internal immutable WETH;

    
    bytes4 private constant FEE_CALLBACK_MAGIC_BYTES = IFeeRecipient.receiveZeroExFeeCallback.selector;
    
    bytes4 private constant TAKER_CALLBACK_MAGIC_BYTES = ITakerCallback.zeroExTakerCallback.selector;

    constructor(address zeroExAddress, IEtherTokenV06 weth)
        public
        FixinEIP712(zeroExAddress)
    {
        WETH = weth;
    }

    struct SellParams {
        uint128 sellAmount;
        uint256 tokenId;
        bool unwrapNativeToken;
        address taker;
        address currentNftOwner;
        bytes takerCallbackData;
    }

    struct BuyParams {
        uint128 buyAmount;
        uint256 ethAvailable;
        bytes takerCallbackData;
    }

    // Core settlement logic for selling an NFT asset.
    function _sellNFT(
        LibNFTOrder.NFTOrder memory buyOrder,
        LibSignature.Signature memory signature,
        SellParams memory params
    )
        internal
        returns (uint256 erc20FillAmount)
    {
        LibNFTOrder.OrderInfo memory orderInfo = _getOrderInfo(buyOrder);
        // Check that the order can be filled.
        _validateBuyOrder(
            buyOrder,
            signature,
            orderInfo,
            params.taker,
            params.tokenId
        );

        if (params.sellAmount > orderInfo.remainingAmount) {
            LibNFTOrdersRichErrors.ExceedsRemainingOrderAmount(
                orderInfo.remainingAmount,
                params.sellAmount
            ).rrevert();
        }

        _updateOrderState(buyOrder, orderInfo.orderHash, params.sellAmount);

        if (params.sellAmount == orderInfo.orderAmount) {
            erc20FillAmount = buyOrder.erc20TokenAmount;
        } else {
            // Rounding favors the order maker.
            erc20FillAmount = LibMathV06.getPartialAmountFloor(
                params.sellAmount,
                orderInfo.orderAmount,
                buyOrder.erc20TokenAmount
            );
        }

        if (params.unwrapNativeToken) {
            // The ERC20 token must be WETH for it to be unwrapped.
            if (buyOrder.erc20Token != WETH) {
                LibNFTOrdersRichErrors.ERC20TokenMismatchError(
                    address(buyOrder.erc20Token),
                    address(WETH)
                ).rrevert();
            }
            // Transfer the WETH from the maker to the Exchange Proxy
            // so we can unwrap it before sending it to the seller.
            // TODO: Probably safe to just use WETH.transferFrom for some
            //       small gas savings
            _transferERC20TokensFrom(
                WETH,
                buyOrder.maker,
                address(this),
                erc20FillAmount
            );
            // Unwrap WETH into ETH.
            WETH.withdraw(erc20FillAmount);
            // Send ETH to the seller.
            _transferEth(payable(params.taker), erc20FillAmount);
        } else {
            // Transfer the ERC20 token from the buyer to the seller.
            _transferERC20TokensFrom(
                buyOrder.erc20Token,
                buyOrder.maker,
                params.taker,
                erc20FillAmount
            );
        }

        if (params.takerCallbackData.length > 0) {
            require(
                params.taker != address(this),
                "NFTOrders::_sellNFT/CANNOT_CALLBACK_SELF"
            );
            // Invoke the callback
            bytes4 callbackResult = ITakerCallback(params.taker)
                .zeroExTakerCallback(orderInfo.orderHash, params.takerCallbackData);
            // Check for the magic success bytes
            require(
                callbackResult == TAKER_CALLBACK_MAGIC_BYTES,
                "NFTOrders::_sellNFT/CALLBACK_FAILED"
            );
        }

        // Transfer the NFT asset to the buyer.
        // If this function is called from the
        // `onNFTReceived` callback the Exchange Proxy
        // holds the asset. Otherwise, transfer it from
        // the seller.
        _transferNFTAssetFrom(
            buyOrder.nft,
            params.currentNftOwner,
            buyOrder.maker,
            params.tokenId,
            params.sellAmount
        );

        // The buyer pays the order fees.
        _payFees(
            buyOrder,
            buyOrder.maker,
            params.sellAmount,
            orderInfo.orderAmount,
            false
        );
    }

    // Core settlement logic for buying an NFT asset.
    function _buyNFT(
        LibNFTOrder.NFTOrder memory sellOrder,
        LibSignature.Signature memory signature,
        BuyParams memory params
    )
        internal
        returns (uint256 erc20FillAmount)
    {
        LibNFTOrder.OrderInfo memory orderInfo = _getOrderInfo(sellOrder);
        // Check that the order can be filled.
        _validateSellOrder(
            sellOrder,
            signature,
            orderInfo,
            msg.sender
        );

        if (params.buyAmount > orderInfo.remainingAmount) {
            LibNFTOrdersRichErrors.ExceedsRemainingOrderAmount(
                orderInfo.remainingAmount,
                params.buyAmount
            ).rrevert();
        }

        _updateOrderState(sellOrder, orderInfo.orderHash, params.buyAmount);

        if (params.buyAmount == orderInfo.orderAmount) {
            erc20FillAmount = sellOrder.erc20TokenAmount;
        } else {
            // Rounding favors the order maker.
            erc20FillAmount = LibMathV06.getPartialAmountCeil(
                params.buyAmount,
                orderInfo.orderAmount,
                sellOrder.erc20TokenAmount
            );
        }

        // Transfer the NFT asset to the buyer (`msg.sender`).
        _transferNFTAssetFrom(
            sellOrder.nft,
            sellOrder.maker,
            msg.sender,
            sellOrder.nftId,
            params.buyAmount
        );

        uint256 ethAvailable = params.ethAvailable;
        if (params.takerCallbackData.length > 0) {
            require(
                msg.sender != address(this),
                "NFTOrders::_buyNFT/CANNOT_CALLBACK_SELF"
            );
            uint256 ethBalanceBeforeCallback = address(this).balance;
            // Invoke the callback
            bytes4 callbackResult = ITakerCallback(msg.sender)
                .zeroExTakerCallback(orderInfo.orderHash, params.takerCallbackData);
            // Update `ethAvailable` with amount acquired during
            // the callback
            ethAvailable = ethAvailable.safeAdd(
                address(this).balance.safeSub(ethBalanceBeforeCallback)
            );
            // Check for the magic success bytes
            require(
                callbackResult == TAKER_CALLBACK_MAGIC_BYTES,
                "NFTOrders::_buyNFT/CALLBACK_FAILED"
            );
        }

        if (address(sellOrder.erc20Token) == NATIVE_TOKEN_ADDRESS) {
            // Transfer ETH to the seller.
            _transferEth(payable(sellOrder.maker), erc20FillAmount);
            // Fees are paid from the EP's current balance of ETH.
            _payEthFees(
                sellOrder,
                params.buyAmount,
                orderInfo.orderAmount,
                erc20FillAmount,
                ethAvailable
            );
        } else if (sellOrder.erc20Token == WETH) {
            // If there is enough ETH available, fill the WETH order
            // (including fees) using that ETH.
            // Otherwise, transfer WETH from the taker.
            if (ethAvailable >= erc20FillAmount) {
                // Wrap ETH.
                WETH.deposit{value: erc20FillAmount}();
                // TODO: Probably safe to just use WETH.transfer for some
                //       small gas savings
                // Transfer WETH to the seller.
                _transferERC20Tokens(
                    WETH,
                    sellOrder.maker,
                    erc20FillAmount
                );
                // Fees are paid from the EP's current balance of ETH.
                _payEthFees(
                    sellOrder,
                    params.buyAmount,
                    orderInfo.orderAmount,
                    erc20FillAmount,
                    ethAvailable
                );
            } else {
                // Transfer WETH from the buyer to the seller.
                _transferERC20TokensFrom(
                    sellOrder.erc20Token,
                    msg.sender,
                    sellOrder.maker,
                    erc20FillAmount
                );
                // The buyer pays fees using WETH.
                _payFees(
                    sellOrder,
                    msg.sender,
                    params.buyAmount,
                    orderInfo.orderAmount,
                    false
                );
            }
        } else {
            // Transfer ERC20 token from the buyer to the seller.
            _transferERC20TokensFrom(
                sellOrder.erc20Token,
                msg.sender,
                sellOrder.maker,
                erc20FillAmount
            );
            // The buyer pays fees.
            _payFees(
                sellOrder,
                msg.sender,
                params.buyAmount,
                orderInfo.orderAmount,
                false
            );
        }
    }

    function _validateSellOrder(
        LibNFTOrder.NFTOrder memory sellOrder,
        LibSignature.Signature memory signature,
        LibNFTOrder.OrderInfo memory orderInfo,
        address taker
    )
        internal
        view
    {
        // Order must be selling the NFT asset.
        require(
            sellOrder.direction == LibNFTOrder.TradeDirection.SELL_NFT,
            "NFTOrders::_validateSellOrder/WRONG_TRADE_DIRECTION"
        );
        // Taker must match the order taker, if one is specified.
        if (sellOrder.taker != address(0) && sellOrder.taker != taker) {
            LibNFTOrdersRichErrors.OnlyTakerError(taker, sellOrder.taker).rrevert();
        }
        // Check that the order is valid and has not expired, been cancelled,
        // or been filled.
        if (orderInfo.status != LibNFTOrder.OrderStatus.FILLABLE) {
            LibNFTOrdersRichErrors.OrderNotFillableError(
                sellOrder.maker,
                sellOrder.nonce,
                uint8(orderInfo.status)
            ).rrevert();
        }

        // Check the signature.
        _validateOrderSignature(orderInfo.orderHash, signature, sellOrder.maker);
    }

    function _validateBuyOrder(
        LibNFTOrder.NFTOrder memory buyOrder,
        LibSignature.Signature memory signature,
        LibNFTOrder.OrderInfo memory orderInfo,
        address taker,
        uint256 tokenId
    )
        internal
        view
    {
        // Order must be buying the NFT asset.
        require(
            buyOrder.direction == LibNFTOrder.TradeDirection.BUY_NFT,
            "NFTOrders::_validateBuyOrder/WRONG_TRADE_DIRECTION"
        );
        // The ERC20 token cannot be ETH.
        require(
            address(buyOrder.erc20Token) != NATIVE_TOKEN_ADDRESS,
            "NFTOrders::_validateBuyOrder/NATIVE_TOKEN_NOT_ALLOWED"
        );
        // Taker must match the order taker, if one is specified.
        if (buyOrder.taker != address(0) && buyOrder.taker != taker) {
            LibNFTOrdersRichErrors.OnlyTakerError(taker, buyOrder.taker).rrevert();
        }
        // Check that the order is valid and has not expired, been cancelled,
        // or been filled.
        if (orderInfo.status != LibNFTOrder.OrderStatus.FILLABLE) {
            LibNFTOrdersRichErrors.OrderNotFillableError(
                buyOrder.maker,
                buyOrder.nonce,
                uint8(orderInfo.status)
            ).rrevert();
        }
        // Check that the asset with the given token ID satisfies the properties
        // specified by the order.
        _validateOrderProperties(buyOrder, tokenId);
        // Check the signature.
        _validateOrderSignature(orderInfo.orderHash, signature, buyOrder.maker);
    }

    function _payEthFees(
        LibNFTOrder.NFTOrder memory order,
        uint128 fillAmount,
        uint128 orderAmount,
        uint256 ethSpent,
        uint256 ethAvailable
    )
        private
    {
        // Pay fees using ETH.
        uint256 ethFees = _payFees(
            order,
            address(this),
            fillAmount,
            orderAmount,
            true
        );
        // Update amount of ETH spent.
        ethSpent = ethSpent.safeAdd(ethFees);
        if (ethSpent > ethAvailable) {
            LibNFTOrdersRichErrors.OverspentEthError(
                ethSpent,
                ethAvailable
            ).rrevert();
        }
    }

    function _payFees(
        LibNFTOrder.NFTOrder memory order,
        address payer,
        uint128 fillAmount,
        uint128 orderAmount,
        bool useNativeToken
    )
        internal
        returns (uint256 totalFeesPaid)
    {
        // Make assertions about ETH case
        if (useNativeToken) {
            assert(payer == address(this));
            assert(
                order.erc20Token == WETH ||
                address(order.erc20Token) == NATIVE_TOKEN_ADDRESS
            );
        }

        for (uint256 i = 0; i < order.fees.length; i++) {
            LibNFTOrder.Fee memory fee = order.fees[i];

            require(
                fee.recipient != address(this),
                "NFTOrders::_payFees/RECIPIENT_CANNOT_BE_EXCHANGE_PROXY"
            );

            uint256 feeFillAmount;
            if (fillAmount == orderAmount) {
                feeFillAmount = fee.amount;
            } else {
                // Round against the fee recipient
                feeFillAmount = LibMathV06.getPartialAmountFloor(
                    fillAmount,
                    orderAmount,
                    fee.amount
                );
            }
            if (feeFillAmount == 0) {
                continue;
            }

            if (useNativeToken) {
                // Transfer ETH to the fee recipient.
                _transferEth(payable(fee.recipient), feeFillAmount);
            } else {
                // Transfer ERC20 token from payer to recipient.
                _transferERC20TokensFrom(
                    order.erc20Token,
                    payer,
                    fee.recipient,
                    feeFillAmount
                );
            }
            // Note that the fee callback is _not_ called if zero
            // `feeData` is provided. If `feeData` is provided, we assume
            // the fee recipient is a contract that implements the
            // `IFeeRecipient` interface.
            if (fee.feeData.length > 0) {
                // Invoke the callback
                bytes4 callbackResult = IFeeRecipient(fee.recipient).receiveZeroExFeeCallback(
                    useNativeToken ? NATIVE_TOKEN_ADDRESS : address(order.erc20Token),
                    feeFillAmount,
                    fee.feeData
                );
                // Check for the magic success bytes
                require(
                    callbackResult == FEE_CALLBACK_MAGIC_BYTES,
                    "NFTOrders::_payFees/CALLBACK_FAILED"
                );
            }
            // Sum the fees paid
            totalFeesPaid = totalFeesPaid.safeAdd(feeFillAmount);
        }
    }

    
    ///      whether or not the given token ID satisfies the required
    ///      properties specified in the order. If the order does not
    ///      specify any properties, this function instead checks
    ///      whether the given token ID matches the ID in the order.
    ///      Reverts if any checks fail, or if the order is selling
    ///      an NFT asset.
    
    
    function _validateOrderProperties(
        LibNFTOrder.NFTOrder memory order,
        uint256 tokenId
    )
        internal
        view
    {
        // Order must be buying an NFT asset to have properties.
        require(
            order.direction == LibNFTOrder.TradeDirection.BUY_NFT,
            "NFTOrders::_validateOrderProperties/WRONG_TRADE_DIRECTION"
        );

        // If no properties are specified, check that the given
        // `tokenId` matches the one specified in the order.
        if (order.nftProperties.length == 0) {
            if (tokenId != order.nftId) {
                LibNFTOrdersRichErrors.TokenIdMismatchError(
                    tokenId,
                    order.nftId
                ).rrevert();
            }
        } else {
            // Validate each property
            for (uint256 i = 0; i < order.nftProperties.length; i++) {
                LibNFTOrder.Property memory property = order.nftProperties[i];
                // `address(0)` is interpreted as a no-op. Any token ID
                // will satisfy a property with `propertyValidator == address(0)`.
                if (address(property.propertyValidator) == address(0)) {
                    continue;
                }

                // Call the property validator and throw a descriptive error
                // if the call reverts.
                try property.propertyValidator.validateProperty(
                    order.nft,
                    tokenId,
                    property.propertyData
                ) {} catch (bytes memory errorData) {
                    LibNFTOrdersRichErrors.PropertyValidationFailedError(
                        address(property.propertyValidator),
                        order.nft,
                        tokenId,
                        property.propertyData,
                        errorData
                    ).rrevert();
                }
            }
        }
    }

    
    ///      given maker and order hash. Reverts if the signature
    ///      is not valid.
    
    
    
    function _validateOrderSignature(
        bytes32 orderHash,
        LibSignature.Signature memory signature,
        address maker
    )
        internal
        virtual
        view;

    
    
    
    
    
    
    ///        1 for ERC721 assets.
    function _transferNFTAssetFrom(
        address token,
        address from,
        address to,
        uint256 tokenId,
        uint256 amount
    )
        internal
        virtual;

    
    ///      has been filled by the given amount.
    
    
    
    ///        that the order has been filled by.
    function _updateOrderState(
        LibNFTOrder.NFTOrder memory order,
        bytes32 orderHash,
        uint128 fillAmount
    )
        internal
        virtual;

    
    
    
    function _getOrderInfo(LibNFTOrder.NFTOrder memory order)
        internal
        virtual
        view
        returns (LibNFTOrder.OrderInfo memory orderInfo);
}

// 
/*

  Copyright 2021 ZeroEx Intl.
  Modifications copyright (C) 2022 TheOpenDAO

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

    
    
    
    event ERC1155OrderCancelled(
        address maker,
        uint256 nonce
    );

    
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
    )
        external;

    
    
    
    
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
    )
        external
        payable;

    
    ///      should be the maker of the order. Silently succeeds if
    ///      an order with the same nonce has already been filled or
    ///      cancelled.
    
    function cancelERC1155Order(uint256 orderNonce)
        external;

    
    ///      should be the maker of the orders. Silently succeeds if
    ///      an order with the same nonce has already been filled or
    ///      cancelled.
    
    function batchCancelERC1155Orders(uint256[] calldata orderNonces)
        external;

    
    ///      given orders.
    
    
    
    ///        to buy for each order.
    
    ///        callback for each order. Refer to the `callbackData`
    ///        parameter to for `buyERC1155`.
    
    ///        function fails to fill any individual order.
    
    
    ///         each order in `orders` was successfully filled.
    function batchBuyERC1155sWithMaxNumber(
        LibNFTOrder.ERC1155Order[] calldata sellOrders,
        LibSignature.Signature[] calldata signatures,
        uint128[] calldata erc1155FillAmounts,
        bytes[] calldata callbackData,
        bool revertIfIncomplete,
        uint256 maxNFTs
    )
        external
        payable
        returns (bool[] memory successes);

    
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
    )
        external
        payable
        returns (bool[] memory successes);

    
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
    )
        external
        returns (bytes4 success);

    
    ///      the order, the `PRESIGNED` signature type will become
    ///      valid for that order and signer.
    
    function preSignERC1155Order(LibNFTOrder.ERC1155Order calldata order)
        external;

    
    ///      the given ERC1155 order. Reverts if not.
    
    
    function validateERC1155OrderSignature(
        LibNFTOrder.ERC1155Order calldata order,
        LibSignature.Signature calldata signature
    )
        external
        view;

    
    ///      whether or not the given token ID satisfies the required
    ///      properties specified in the order. If the order does not
    ///      specify any properties, this function instead checks
    ///      whether the given token ID matches the ID in the order.
    ///      Reverts if any checks fail, or if the order is selling
    ///      an ERC1155 asset.
    
    
    function validateERC1155OrderProperties(
        LibNFTOrder.ERC1155Order calldata order,
        uint256 erc1155TokenId
    )
        external
        view;

    
    
    
    function getERC1155OrderInfo(LibNFTOrder.ERC1155Order calldata order)
        external
        view
        returns (LibNFTOrder.OrderInfo memory orderInfo);

    
    
    
    function getERC1155OrderHash(LibNFTOrder.ERC1155Order calldata order)
        external
        view
        returns (bytes32 orderHash);
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
    function supportInterface(bytes4 interfaceId)
        external
        pure
        returns (bool isSupported);
}

// 
/*

  Copyright 2021 TheOpenDAO

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






interface INFTToolsFeature {
    
    struct TransferERC721AsseetsParam {
        IERC721Token token;
        address to;
        uint256 tokenId;
    }

    
    struct TransferERC1155AsseetsParam {
        IERC1155Token token;
        address to;
        uint256 tokenId;
        uint256 amount;
    }

    
    
    
    function batchTransferNFTAssetsFrom(TransferERC721AsseetsParam[] calldata erc721s, TransferERC1155AsseetsParam[] calldata erc1155s) external;
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




interface IBootstrapFeature {

    
    ///      into `target`. Before exiting the `bootstrap()` function will
    ///      deregister itself from the proxy to prevent being called again.
    
    
    function bootstrap(address target, bytes calldata callData) external;
}
// 
pragma solidity ^0.6;





contract NFTAuctionsFeatureHelper is NFTAuctionsFeature {

    function migrate() external override returns (bytes4 success) {
        _registerFeatureFunction(this.validateSender.selector);
        _registerFeatureFunction(this.updateAuctionState.selector);
        return LibMigrate.MIGRATE_SUCCESS;
    }

    constructor(address zeroExAddress, IEtherTokenV06 weth) public NFTAuctionsFeature(zeroExAddress, weth) { }

    function getAuctionTypeHash2() external pure returns (bytes32) {
        return bytes32(_AUCTION_TYPEHASH);
    }

    function getFeeTypeHash2() external pure returns (bytes32) {
        return bytes32(_FEE_TYPEHASH);
    }

    function getEnAuctionBidTypeHash2() external pure returns (bytes32) {
        return bytes32(_EN_AUCTION_BID_TYPEHASH);
    }

    function validateSender(address taker, EnglishAuctionBid memory enBid) external pure returns(bool) {
        return _validateSender(taker, enBid);
    }

    function updateAuctionState(address maker, uint256 nonce, bytes32 _hash, uint128 remaining, uint128 amount) external {
        return _updateAuctionState(maker, nonce, _hash, remaining, amount);
    }

    function getFeeTypeHash() external pure returns(bytes32) {
        return keccak256(abi.encodePacked(
            "AuctionFee(",
                "bool isMatcher,",
                "address recipient,",
                "uint256 amountOrRate,",
                "bytes feeData",
            ")"
        ));
    }

    function getAuctionTypeHash() external pure returns(bytes32) {
        return keccak256(abi.encodePacked(
            "NFTAuction(",
                "uint8 auctionKind,",
                "uint8 nftKind,",
                "bool earlyMatch,",
                "address maker,",
                "uint128 startTime,",
                "uint128 endTime,",
                "uint256 nonce,",
                "address erc20Token,",
                "uint256 startErc20TokenAmount,",
                "uint256 endOrReservedErc20TokenAmount,",
                "AuctionFee[] fees,",
                "address nftToken,",
                "uint256 nftTokenId,",
                "uint128 nftTokenAmount",
            ")",
            "AuctionFee(bool isMatcher,address recipient,uint256 amountOrRate,bytes feeData)"
        ));
    }

    // https://eips.ethereum.org/EIPS/eip-712#definition-of-encodetype
    function getEnAuctionBidTypeHash() external pure returns(bytes32) {
        return keccak256(abi.encodePacked(
            "EnglishAuctionBid(",
                "NFTAuction auction,",
                "address bidMaker,",
                "uint256 erc20TokenAmount",
            ")",
            "AuctionFee(bool isMatcher,address recipient,uint256 amountOrRate,bytes feeData)",
            "NFTAuction(uint8 auctionKind,uint8 nftKind,bool earlyMatch,address maker,uint128 startTime,uint128 endTime,uint256 nonce,address erc20Token,uint256 startErc20TokenAmount,uint256 endOrReservedErc20TokenAmount,AuctionFee[] fees,address nftToken,uint256 nftTokenId,uint128 nftTokenAmount)"
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




interface IEtherTokenV06 is
    IERC20TokenV06
{
    
    function deposit() external payable;

    
    function withdraw(uint256 amount) external;
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

  Copyright 2021 TheOpenDAO

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






interface IOnNFTReceived {
    
    function onERC721Received2(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4 success);
    
    function onERC1155Received2(address operator, address from, uint256 tokenId, uint256 value, bytes calldata data) external returns (bytes4 success);
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


library LibNFTOrdersRichErrors {

    // solhint-disable func-name-mixedcase

    function OverspentEthError(
        uint256 ethSpent,
        uint256 ethAvailable
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("OverspentEthError(uint256,uint256)")),
            ethSpent,
            ethAvailable
        );
    }

    function InsufficientEthError(
        uint256 ethAvailable,
        uint256 orderAmount
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("InsufficientEthError(uint256,uint256)")),
            ethAvailable,
            orderAmount
        );
    }

    function ERC721TokenMismatchError(
        address token1,
        address token2
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("ERC721TokenMismatchError(address,address)")),
            token1,
            token2
        );
    }

    function ERC1155TokenMismatchError(
        address token1,
        address token2
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("ERC1155TokenMismatchError(address,address)")),
            token1,
            token2
        );
    }

    function ERC20TokenMismatchError(
        address token1,
        address token2
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("ERC20TokenMismatchError(address,address)")),
            token1,
            token2
        );
    }

    function NegativeSpreadError(
        uint256 sellOrderAmount,
        uint256 buyOrderAmount
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("NegativeSpreadError(uint256,uint256)")),
            sellOrderAmount,
            buyOrderAmount
        );
    }

    function SellOrderFeesExceedSpreadError(
        uint256 sellOrderFees,
        uint256 spread
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("SellOrderFeesExceedSpreadError(uint256,uint256)")),
            sellOrderFees,
            spread
        );
    }

    function OnlyTakerError(
        address sender,
        address taker
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("OnlyTakerError(address,address)")),
            sender,
            taker
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

    function OrderNotFillableError(
        address maker,
        uint256 nonce,
        uint8 orderStatus
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("OrderNotFillableError(address,uint256,uint8)")),
            maker,
            nonce,
            orderStatus
        );
    }

    function TokenIdMismatchError(
        uint256 tokenId,
        uint256 orderTokenId
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("TokenIdMismatchError(uint256,uint256)")),
            tokenId,
            orderTokenId
        );
    }

    function PropertyValidationFailedError(
        address propertyValidator,
        address token,
        uint256 tokenId,
        bytes memory propertyData,
        bytes memory errorData
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("PropertyValidationFailedError(address,address,uint256,bytes,bytes)")),
            propertyValidator,
            token,
            tokenId,
            propertyData,
            errorData
        );
    }

    function ExceedsRemainingOrderAmount(
        uint128 remainingOrderAmount,
        uint128 fillAmount
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("ExceedsRemainingOrderAmount(uint128,uint128)")),
            remainingOrderAmount,
            fillAmount
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

        // If a feature supports pre-signing, it wouldn't use 
        // `getSignerOfHash` on a pre-signed order.
        if (signature.signatureType == SignatureType.PRESIGNED) {
            LibSignatureRichErrors.SignatureValidationError(
                LibSignatureRichErrors.SignatureValidationErrorCodes.UNSUPPORTED,
                hash
            ).rrevert();
        }

        // Solidity should check that the signature type is within enum range for us
        // when abi-decoding.
    }
}

// 
/*

  Copyright 2022 TheOpenDAO

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






library LibNFTAuctionsStorage {

    struct AuctionState {
        // The amount (denominated in the ERC1155 asset)
        // that the order has been filled by.
        uint128 filledAmount;
        // Whether the order has been pre-signed.
        bool preSigned;
    }

    
    struct Storage {
        //  auction hash => auction state
        mapping(bytes32 => AuctionState) auctionState;
        // maker => nonce range =>  auction cancellation bit vector
        mapping(address => mapping(uint248 => uint256)) auctionCancellationByMaker;
    }

    
    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.NFTAuctions
        );
        // Dip into assembly to change the slot pointed to by the local
        // variable `stor`.
        // See https://solidity.readthedocs.io/en/v0.6.8/assembly.html?highlight=slot#access-to-external-variables-functions-and-libraries
        assembly { stor_slot := storageSlot }
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

pragma solidity ^0.6;



interface ITakerCallback {

    
    ///      ERC1155OrdersFeature between the maker -> taker transfer and
    ///      the taker -> maker transfer.
    
    ///        callback is invoked.
    
    
    ///         indicating that the callback succeeded.
    function zeroExTakerCallback(
        bytes32 orderHash,
        bytes calldata callbackData
    )
        external
        returns (bytes4 success);
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



interface IFeeRecipient {

    
    ///      order fee that get paid. Integrators can make use of this callback
    ///      to implement arbitrary fee-handling logic, e.g. splitting the fee
    ///      between multiple parties.
    
    ///        denominated. `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE` indicates
    ///        that the fee was paid in the native token (e.g. ETH).
    
    
    
    ///         indicating that the callback succeeded.
    function receiveZeroExFeeCallback(
        address tokenAddress,
        uint256 amount,
        bytes calldata feeData
    )
        external
        returns (bytes4 success);
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
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    
    ///      reaffirmed. The zero address indicates there is no approved address.
    ///      When a Transfer event emits, this also indicates that the approved
    ///      address for that NFT (if any) is reset to none.
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );

    
    ///      The operator can manage all NFTs of the owner.
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    
    
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
    )
        external;

    
    
    ///      except this function just sets data to "".
    
    
    
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        external;

    
    
    ///      Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///      operator of the current owner.
    
    
    function approve(address _approved, uint256 _tokenId)
        external;

    
    ///         all of `msg.sender`'s assets
    
    ///      multiple operators per owner.
    
    
    function setApprovalForAll(address _operator, bool _approved)
        external;

    
    
    ///      function throws for queries about the zero address.
    
    
    function balanceOf(address _owner)
        external
        view
        returns (uint256);

    
    ///         TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///         THEY MAY BE PERMANENTLY LOST
    
    ///      operator, or the approved address for this NFT. Throws if `_from` is
    ///      not the current owner. Throws if `_to` is the zero address. Throws if
    ///      `_tokenId` is not a valid NFT.
    
    
    
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        external;

    
    
    ///      about them do throw.
    
    
    function ownerOf(uint256 _tokenId)
        external
        view
        returns (address);

    
    
    
    
    function getApproved(uint256 _tokenId)
        external
        view
        returns (address);

    
    
    
    
    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool);
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
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    
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

    
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    
    /// URIs are defined in RFC 3986.
    /// The URI MUST point a JSON file that conforms to the "ERC-1155 Metadata JSON Schema".
    event URI(
        string value,
        uint256 indexed id
    );

    
    
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
    )
        external;

    
    
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
    )
        external;

    
    
    
    
    function setApprovalForAll(address operator, bool approved) external;

    
    
    
    
    function isApprovedForAll(address owner, address operator) external view returns (bool isApproved);

    
    
    
    
    function balanceOf(address owner, uint256 id) external view returns (uint256 balance);

    
    
    
    
    function balanceOfBatch(
        address[] calldata owners,
        uint256[] calldata ids
    )
        external
        view
        returns (uint256[] memory balances_);
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
  Modifications copyright (C) 2022 TheOpenDAO

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
        OtcOrders,
        ERC721Orders,
        ERC1155Orders,
        NFTAuctions
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

  Copyright 2021 ZeroEx Intl.
  Modifications copyright (C) 2022 TheOpenDAO

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















contract ERC721OrdersFeature is
    IFeature,
    IERC721OrdersFeature,
    FixinERC721Spender,
    NFTOrders
{
    using LibSafeMathV06 for uint256;
    using LibNFTOrder for LibNFTOrder.ERC721Order;
    using LibNFTOrder for LibNFTOrder.NFTOrder;

    
    string public constant override FEATURE_NAME = "ERC721Orders";
    
    uint256 public immutable override FEATURE_VERSION = _encodeVersion(1, 0, 0);

    
    bytes4 private constant ERC721_RECEIVED_MAGIC_BYTES = this.onERC721Received.selector;


    constructor(address zeroExAddress, IEtherTokenV06 weth)
        public
        NFTOrders(zeroExAddress, weth)
    {}

    
    ///      Should be delegatecalled by `Migrate.migrate()`.
    
    function migrate()
        external
        returns (bytes4 success)
    {
        _registerFeatureFunction(this.sellERC721.selector);
        _registerFeatureFunction(this.buyERC721.selector);
        _registerFeatureFunction(this.cancelERC721Order.selector);
        _registerFeatureFunction(this.batchCancelERC721Orders.selector);
        _registerFeatureFunction(this.batchBuyERC721s.selector);
        _registerFeatureFunction(this.matchERC721Orders.selector);
        _registerFeatureFunction(this.batchBuyERC721sWithMaxNumber.selector);
        _registerFeatureFunction(this.batchMatchERC721Orders.selector);
        _registerFeatureFunction(this.onERC721Received.selector);
        _registerFeatureFunction(this.onERC721Received2.selector);
        _registerFeatureFunction(this.preSignERC721Order.selector);
        _registerFeatureFunction(this.validateERC721OrderSignature.selector);
        _registerFeatureFunction(this.validateERC721OrderProperties.selector);
        _registerFeatureFunction(this.getERC721OrderStatus.selector);
        _registerFeatureFunction(this.getERC721OrderHash.selector);
        _registerFeatureFunction(this.getERC721OrderStatusBitVector.selector);
        return LibMigrate.MIGRATE_SUCCESS;
    }

    
    
    
    
    ///        sold. If the given order specifies properties,
    ///        the asset must satisfy those properties. Otherwise,
    ///        it must equal the tokenId in the order.
    
    ///        ERC20 token of the order is e.g. WETH, unwraps the
    ///        token before transferring it to the taker.
    
    ///        `zeroExERC721OrderCallback` on `msg.sender` after
    ///        the ERC20 tokens have been transferred to `msg.sender`
    ///        but before transferring the ERC721 asset to the buyer.
    function sellERC721(
        LibNFTOrder.ERC721Order memory buyOrder,
        LibSignature.Signature memory signature,
        uint256 erc721TokenId,
        bool unwrapNativeToken,
        bytes memory callbackData
    )
        public
        override
    {
        _sellERC721(
            buyOrder,
            signature,
            erc721TokenId,
            unwrapNativeToken,
            msg.sender, // taker
            msg.sender, // owner
            callbackData
        );
    }

    
    
    
    
    ///        `zeroExERC721OrderCallback` on `msg.sender` after
    ///        the ERC721 asset has been transferred to `msg.sender`
    ///        but before transferring the ERC20 tokens to the seller.
    ///        Native tokens acquired during the callback can be used
    ///        to fill the order.
    function buyERC721(
        LibNFTOrder.ERC721Order memory sellOrder,
        LibSignature.Signature memory signature,
        bytes memory callbackData
    )
        public
        override
        payable
    {
        uint256 ethBalanceBefore = address(this).balance
            .safeSub(msg.value);
        _buyERC721(
            sellOrder,
            signature,
            msg.value,
            callbackData
        );
        uint256 ethBalanceAfter = address(this).balance;
        // Cannot use pre-existing ETH balance
        if (ethBalanceAfter < ethBalanceBefore) {
            LibNFTOrdersRichErrors.OverspentEthError(
                msg.value + (ethBalanceBefore - ethBalanceAfter),
                msg.value
            ).rrevert();
        }
        // Refund
        _transferEth(msg.sender, ethBalanceAfter - ethBalanceBefore);
    }

    
    ///      should be the maker of the order. Silently succeeds if
    ///      an order with the same nonce has already been filled or
    ///      cancelled.
    
    function cancelERC721Order(uint256 orderNonce)
        public
        override
    {
        // Mark order as cancelled
        _setOrderStatusBit(msg.sender, orderNonce);
        emit ERC721OrderCancelled(msg.sender, orderNonce);
    }

    
    ///      should be the maker of the orders. Silently succeeds if
    ///      an order with the same nonce has already been filled or
    ///      cancelled.
    
    function batchCancelERC721Orders(uint256[] calldata orderNonces)
        external
        override
    {
        for (uint256 i = 0; i < orderNonces.length; i++) {
            cancelERC721Order(orderNonces[i]);
        }
    }

    
    ///      given orders.
    
    
    
    ///        function fails to fill any individual order.
    
    ///        callback for each order. Refer to the `callbackData`
    ///        parameter to for `buyERC721`.
    
    
    ///         each order in `orders` was successfully filled.
    function batchBuyERC721sWithMaxNumber(
        LibNFTOrder.ERC721Order[] memory sellOrders,
        LibSignature.Signature[] memory signatures,
        bytes[] memory callbackData,
        bool revertIfIncomplete,
        uint256 maxNFTs
    )
        public
        override
        payable
        returns (bool[] memory successes)
    {
        require(
            sellOrders.length == signatures.length &&
            sellOrders.length == callbackData.length,
            "ERC721OrdersFeature::batchBuyERC721s/ARRAY_LENGTH_MISMATCH"
        );
        successes = new bool[](sellOrders.length);

        uint256 ethBalanceBefore = address(this).balance
            .safeSub(msg.value);
        if (revertIfIncomplete) {
            for (uint256 i = 0; i < sellOrders.length; i++) {
                // Will revert if _buyERC721 reverts.
                _buyERC721(
                    sellOrders[i],
                    signatures[i],
                    address(this).balance.safeSub(ethBalanceBefore),
                    callbackData[i]
                );
                successes[i] = true;
            }
        } else {
            require(maxNFTs > 0, "ERC721OrdersFeature::batchBuyERC721s/maxNFTs_CANNOT_BE_ZERO");
            for (uint256 i = 0; i < sellOrders.length; i++) {
                // Delegatecall `_buyERC721` to swallow reverts while
                // preserving execution context.
                // Note that `_buyERC721` is a public function but should _not_
                // be registered in the Exchange Proxy.
                (successes[i], ) = _implementation.delegatecall(
                    abi.encodeWithSelector(
                        this._buyERC721.selector,
                        sellOrders[i],
                        signatures[i],
                        address(this).balance.safeSub(ethBalanceBefore), // Remaining ETH available
                        callbackData[i]
                    )
                );
                if (successes[i]) {
                    if (--maxNFTs == 0) {
                        break;
                    }
                }
            }
        }

        // Cannot use pre-existing ETH balance
        uint256 ethBalanceAfter = address(this).balance;
        if (ethBalanceAfter < ethBalanceBefore) {
            LibNFTOrdersRichErrors.OverspentEthError(
                msg.value + (ethBalanceBefore - ethBalanceAfter),
                msg.value
            ).rrevert();
        }

        // Refund
        _transferEth(msg.sender, ethBalanceAfter - ethBalanceBefore);
    }

    
    ///      given orders.
    
    
    
    ///        function fails to fill any individual order.
    
    ///        callback for each order. Refer to the `callbackData`
    ///        parameter to for `buyERC721`.
    
    ///         each order in `orders` was successfully filled.
    function batchBuyERC721s(
        LibNFTOrder.ERC721Order[] memory sellOrders,
        LibSignature.Signature[] memory signatures,
        bytes[] memory callbackData,
        bool revertIfIncomplete
    )
        public
        override
        payable
        returns (bool[] memory successes)
    {
        return batchBuyERC721sWithMaxNumber(sellOrders, signatures, callbackData, revertIfIncomplete, uint256(-1));
    }

    
    ///      a non-negative spread. Each order is filled at
    ///      their respective price, and the matcher receives
    ///      a profit denominated in the ERC20 token.
    
    
    
    
    
    ///         of this function (denominated in the ERC20 token
    ///         of the matched orders).
    function matchERC721Orders(
        LibNFTOrder.ERC721Order memory sellOrder,
        LibNFTOrder.ERC721Order memory buyOrder,
        LibSignature.Signature memory sellOrderSignature,
        LibSignature.Signature memory buyOrderSignature
    )
        public
        override
        returns (uint256 profit)
    {
        // The ERC721 tokens must match
        if (sellOrder.erc721Token != buyOrder.erc721Token) {
            LibNFTOrdersRichErrors.ERC721TokenMismatchError(
                address(sellOrder.erc721Token),
                address(buyOrder.erc721Token)
            ).rrevert();
        }

        LibNFTOrder.NFTOrder memory sellNFTOrder = sellOrder.asNFTOrder();
        LibNFTOrder.NFTOrder memory buyNFTOrder = buyOrder.asNFTOrder();

        {
            LibNFTOrder.OrderInfo memory sellOrderInfo = _getOrderInfo(sellNFTOrder);
            LibNFTOrder.OrderInfo memory buyOrderInfo = _getOrderInfo(buyNFTOrder);

            _validateSellOrder(
                sellNFTOrder,
                sellOrderSignature,
                sellOrderInfo,
                buyOrder.maker
            );
            _validateBuyOrder(
                buyNFTOrder,
                buyOrderSignature,
                buyOrderInfo,
                sellOrder.maker,
                sellOrder.erc721TokenId
            );

            // Mark both orders as filled.
            _updateOrderState(sellNFTOrder, sellOrderInfo.orderHash, 1);
            _updateOrderState(buyNFTOrder, buyOrderInfo.orderHash, 1);
        }

        // The buyer must be willing to pay at least the amount that the
        // seller is asking.
        if (buyOrder.erc20TokenAmount < sellOrder.erc20TokenAmount) {
            LibNFTOrdersRichErrors.NegativeSpreadError(
                sellOrder.erc20TokenAmount,
                buyOrder.erc20TokenAmount
            ).rrevert();
        }

        // The difference in ERC20 token amounts is the spread.
        uint256 spread = buyOrder.erc20TokenAmount - sellOrder.erc20TokenAmount;

        // Transfer the ERC721 asset from seller to buyer.
        _transferERC721AssetFrom(
            sellOrder.erc721Token,
            sellOrder.maker,
            buyOrder.maker,
            sellOrder.erc721TokenId
        );

        // Handle the ERC20 side of the order:
        if (
            address(sellOrder.erc20Token) == NATIVE_TOKEN_ADDRESS &&
            buyOrder.erc20Token == WETH
        ) {
            // The sell order specifies ETH, while the buy order specifies WETH.
            // The orders are still compatible with one another, but we'll have
            // to unwrap the WETH on behalf of the buyer.

            // Step 1: Transfer WETH from the buyer to the EP.
            //         Note that we transfer `buyOrder.erc20TokenAmount`, which
            //         is the amount the buyer signaled they are willing to pay
            //         for the ERC721 asset, which may be more than the seller's
            //         ask.
            _transferERC20TokensFrom(
                WETH,
                buyOrder.maker,
                address(this),
                buyOrder.erc20TokenAmount
            );
            // Step 2: Unwrap the WETH into ETH. We unwrap the entire
            //         `buyOrder.erc20TokenAmount`.
            //         The ETH will be used for three purposes:
            //         - To pay the seller
            //         - To pay fees for the sell order
            //         - Any remaining ETH will be sent to
            //           `msg.sender` as profit.
            WETH.withdraw(buyOrder.erc20TokenAmount);

            // Step 3: Pay the seller (in ETH).
            _transferEth(payable(sellOrder.maker), sellOrder.erc20TokenAmount);

            // Step 4: Pay fees for the buy order. Note that these are paid
            //         in _WETH_ by the _buyer_. By signing the buy order, the
            //         buyer signals that they are willing to spend a total
            //         of `erc20TokenAmount` _plus_ fees, all denominated in
            //         the `erc20Token`, which in this case is WETH.
            _payFees(
                buyNFTOrder,
                buyOrder.maker, // payer
                1,              // fillAmount
                1,              // orderAmount
                false           // useNativeToken
            );

            // Step 5: Pay fees for the sell order. The `erc20Token` of the
            //         sell order is ETH, so the fees are paid out in ETH.
            //         There should be `spread` wei of ETH remaining in the
            //         EP at this point, which we will use ETH to pay the
            //         sell order fees.
            uint256 sellOrderFees = _payFees(
                sellNFTOrder,
                address(this), // payer
                1,             // fillAmount
                1,             // orderAmount
                true           // useNativeToken
            );

            // Step 6: The spread must be enough to cover the sell order fees.
            //         If not, either `_payFees` will have reverted, or we
            //         have spent ETH that was in the EP before this
            //         `matchERC721Orders` call, which we disallow.
            if (spread < sellOrderFees) {
                LibNFTOrdersRichErrors.SellOrderFeesExceedSpreadError(
                    sellOrderFees,
                    spread
                ).rrevert();
            }
            // Step 7: The spread less the sell order fees is the amount of ETH
            //         remaining in the EP that can be sent to `msg.sender` as
            //         the profit from matching these two orders.
            profit = spread - sellOrderFees;
            if (profit > 0) {
                _transferEth(msg.sender, profit);
            }
        } else {
            // ERC20 tokens must match
            if (sellOrder.erc20Token != buyOrder.erc20Token) {
                LibNFTOrdersRichErrors.ERC20TokenMismatchError(
                    address(sellOrder.erc20Token),
                    address(buyOrder.erc20Token)
                ).rrevert();
            }

            // Step 1: Transfer the ERC20 token from the buyer to the seller.
            //         Note that we transfer `sellOrder.erc20TokenAmount`, which
            //         is at most `buyOrder.erc20TokenAmount`.
            _transferERC20TokensFrom(
                buyOrder.erc20Token,
                buyOrder.maker,
                sellOrder.maker,
                sellOrder.erc20TokenAmount
            );

            // Step 2: Pay fees for the buy order. Note that these are paid
            //         by the buyer. By signing the buy order, the buyer signals
            //         that they are willing to spend a total of
            //         `buyOrder.erc20TokenAmount` _plus_ `buyOrder.fees`.
            _payFees(
                buyNFTOrder,
                buyOrder.maker, // payer
                1,              // fillAmount
                1,              // orderAmount
                false           // useNativeToken
            );

            // Step 3: Pay fees for the sell order. These are paid by the buyer
            //         as well. After paying these fees, we may have taken more
            //         from the buyer than they agreed to in the buy order. If
            //         so, we revert in the following step.
            uint256 sellOrderFees = _payFees(
                sellNFTOrder,
                buyOrder.maker, // payer
                1,              // fillAmount
                1,              // orderAmount
                false           // useNativeToken
            );

            // Step 4: The spread must be enough to cover the sell order fees.
            //         If not, `_payFees` will have taken more tokens from the
            //         buyer than they had agreed to in the buy order, in which
            //         case we revert here.
            if (spread < sellOrderFees) {
                LibNFTOrdersRichErrors.SellOrderFeesExceedSpreadError(
                    sellOrderFees,
                    spread
                ).rrevert();
            }

            // Step 5: We calculate the profit as:
            //         profit = buyOrder.erc20TokenAmount - sellOrder.erc20TokenAmount - sellOrderFees
            //                = spread - sellOrderFees
            //         I.e. the buyer would've been willing to pay up to `profit`
            //         more to buy the asset, so instead that amount is sent to
            //         `msg.sender` as the profit from matching these two orders.
            profit = spread - sellOrderFees;
            if (profit > 0) {
                _transferERC20TokensFrom(
                    buyOrder.erc20Token,
                    buyOrder.maker,
                    msg.sender,
                    profit
                );
            }
        }

        emit ERC721OrderFilled(
            sellOrder.direction,
            sellOrder.maker,
            buyOrder.maker, // taker
            sellOrder.nonce,
            sellOrder.erc20Token,
            sellOrder.erc20TokenAmount,
            sellOrder.erc721Token,
            sellOrder.erc721TokenId,
            msg.sender
        );

        emit ERC721OrderFilled(
            buyOrder.direction,
            buyOrder.maker,
            sellOrder.maker, // taker
            buyOrder.nonce,
            buyOrder.erc20Token,
            buyOrder.erc20TokenAmount,
            buyOrder.erc721Token,
            sellOrder.erc721TokenId,
            msg.sender
        );
    }

    
    ///      non-negative spreads. Each order is filled at
    ///      their respective price, and the matcher receives
    ///      a profit denominated in the ERC20 token.
    
    
    
    
    
    ///         of this function for each pair of matched orders
    ///         (denominated in the ERC20 token of the order pair).
    
    ///         whether each pair of orders was successfully matched.
    function batchMatchERC721Orders(
        LibNFTOrder.ERC721Order[] memory sellOrders,
        LibNFTOrder.ERC721Order[] memory buyOrders,
        LibSignature.Signature[] memory sellOrderSignatures,
        LibSignature.Signature[] memory buyOrderSignatures
    )
        public
        override
        returns (uint256[] memory profits, bool[] memory successes)
    {
        require(
            sellOrders.length == buyOrders.length &&
            sellOrderSignatures.length == buyOrderSignatures.length &&
            sellOrders.length == sellOrderSignatures.length,
            "ERC721OrdersFeature::batchMatchERC721Orders/ARRAY_LENGTH_MISMATCH"
        );
        profits = new uint256[](sellOrders.length);
        successes = new bool[](sellOrders.length);

        for (uint256 i = 0; i < sellOrders.length; i++) {
            bytes memory returnData;
            // Delegatecall `matchERC721Orders` to catch reverts while
            // preserving execution context.
            (successes[i], returnData) = _implementation.delegatecall(
                abi.encodeWithSelector(
                    this.matchERC721Orders.selector,
                    sellOrders[i],
                    buyOrders[i],
                    sellOrderSignatures[i],
                    buyOrderSignatures[i]
                )
            );
            if (successes[i]) {
                // If the matching succeeded, record the profit.
                (uint256 profit) = abi.decode(returnData, (uint256));
                profits[i] = profit;
            }
        }
    }

    
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
    ) external override returns (bytes4 success) {
        return onERC721Received2(operator,from,tokenId,data);
    }

    function onERC721Received2(
        address operator,
        address /* from */,
        uint256 tokenId,
        bytes calldata data
    )
        public
        returns (bytes4 success)
    {
        // Decode the order, signature, and `unwrapNativeToken` from
        // `data`. If `data` does not encode such parameters, this
        // will throw.
        (
            uint256 code,
            LibNFTOrder.ERC721Order memory buyOrder,
            LibSignature.Signature memory signature,
            bool unwrapNativeToken
        ) = abi.decode(
            data,
            (uint256, LibNFTOrder.ERC721Order, LibSignature.Signature, bool)
        );code;

        // `onERC721Received` is called by the ERC721 token contract.
        // Check that it matches the ERC721 token in the order.
        if (msg.sender != address(buyOrder.erc721Token)) {
            LibNFTOrdersRichErrors.ERC721TokenMismatchError(
                msg.sender,
                address(buyOrder.erc721Token)
            ).rrevert();
        }

        _sellERC721(
            buyOrder,
            signature,
            tokenId,
            unwrapNativeToken,
            operator,       // taker
            address(this),  // owner (we hold the NFT currently)
            new bytes(0)    // No taker callback
        );

        return ERC721_RECEIVED_MAGIC_BYTES;
    }

    
    ///      the order, the `PRESIGNED` signature type will become
    ///      valid for that order and signer.
    
    function preSignERC721Order(LibNFTOrder.ERC721Order memory order)
        public
        override
    {
        require(
            order.maker == msg.sender,
            "ERC721OrdersFeature::preSignERC721Order/ONLY_MAKER"
        );
        bytes32 orderHash = getERC721OrderHash(order);
        LibERC721OrdersStorage.getStorage().preSigned[orderHash] = true;

        emit ERC721OrderPreSigned(
            order.direction,
            order.maker,
            order.taker,
            order.expiry,
            order.nonce,
            order.erc20Token,
            order.erc20TokenAmount,
            order.fees,
            order.erc721Token,
            order.erc721TokenId,
            order.erc721TokenProperties
        );
    }

    // Core settlement logic for selling an ERC721 asset.
    // Used by `sellERC721` and `onERC721Received`.
    function _sellERC721(
        LibNFTOrder.ERC721Order memory buyOrder,
        LibSignature.Signature memory signature,
        uint256 erc721TokenId,
        bool unwrapNativeToken,
        address taker,
        address currentNftOwner,
        bytes memory takerCallbackData
    )
        private
    {
        _sellNFT(
            buyOrder.asNFTOrder(),
            signature,
            SellParams(
                1, // sell amount
                erc721TokenId,
                unwrapNativeToken,
                taker,
                currentNftOwner,
                takerCallbackData
            )
        );

        emit ERC721OrderFilled(
            buyOrder.direction,
            buyOrder.maker,
            taker,
            buyOrder.nonce,
            buyOrder.erc20Token,
            buyOrder.erc20TokenAmount,
            buyOrder.erc721Token,
            erc721TokenId,
            address(0)
        );
    }

    // Core settlement logic for buying an ERC721 asset.
    // Used by `buyERC721` and `batchBuyERC721s`.
    function _buyERC721(
        LibNFTOrder.ERC721Order memory sellOrder,
        LibSignature.Signature memory signature,
        uint256 ethAvailable,
        bytes memory takerCallbackData
    )
        public
        payable
    {
        _buyNFT(
            sellOrder.asNFTOrder(),
            signature,
            BuyParams(
                1, // buy amount
                ethAvailable,
                takerCallbackData
            )
        );

        emit ERC721OrderFilled(
            sellOrder.direction,
            sellOrder.maker,
            msg.sender,
            sellOrder.nonce,
            sellOrder.erc20Token,
            sellOrder.erc20TokenAmount,
            sellOrder.erc721Token,
            sellOrder.erc721TokenId,
            address(0)
        );
    }


    
    ///      the given ERC721 order. Reverts if not.
    
    
    function validateERC721OrderSignature(
        LibNFTOrder.ERC721Order memory order,
        LibSignature.Signature memory signature
    )
        public
        override
        view
    {
        bytes32 orderHash = getERC721OrderHash(order);
        _validateOrderSignature(orderHash, signature, order.maker);
    }

    
    ///      given maker and order hash. Reverts if the signature
    ///      is not valid.
    
    
    
    function _validateOrderSignature(
        bytes32 orderHash,
        LibSignature.Signature memory signature,
        address maker
    )
        internal
        override
        view
    {
        if (signature.signatureType == LibSignature.SignatureType.PRESIGNED) {
            // Check if order hash has been pre-signed by the maker.
            bool isPreSigned = LibERC721OrdersStorage.getStorage().preSigned[orderHash];
            if (!isPreSigned) {
                LibNFTOrdersRichErrors.InvalidSignerError(maker, address(0)).rrevert();
            }
        } else {
            address signer = LibSignature.getSignerOfHash(orderHash, signature);
            if (signer != maker) {
                LibNFTOrdersRichErrors.InvalidSignerError(maker, signer).rrevert();
            }
        }
    }

    
    
    
    
    
    
    ///        1 for ERC721 assets.
    function _transferNFTAssetFrom(
        address token,
        address from,
        address to,
        uint256 tokenId,
        uint256 amount
    )
        internal
        override
    {
        assert(amount == 1);
        _transferERC721AssetFrom(IERC721Token(token), from, to, tokenId);
    }

    
    ///      has been filled by the given amount.
    
    
    ///        that the order has been filled by.
    function _updateOrderState(
        LibNFTOrder.NFTOrder memory order,
        bytes32 /* orderHash */,
        uint128 fillAmount
    )
        internal
        override
    {
        assert(fillAmount == 1);
        _setOrderStatusBit(order.maker, order.nonce);
    }

    function _setOrderStatusBit(address maker, uint256 nonce)
        private
    {
        // The bitvector is indexed by the lower 8 bits of the nonce.
        uint256 flag = 1 << (nonce & 255);
        // Update order status bit vector to indicate that the given order
        // has been cancelled/filled by setting the designated bit to 1.
        LibERC721OrdersStorage.getStorage().orderStatusByMaker
            [maker][uint248(nonce >> 8)] |= flag;
    }

    
    ///      whether or not the given token ID satisfies the required
    ///      properties specified in the order. If the order does not
    ///      specify any properties, this function instead checks
    ///      whether the given token ID matches the ID in the order.
    ///      Reverts if any checks fail, or if the order is selling
    ///      an ERC721 asset.
    
    
    function validateERC721OrderProperties(
        LibNFTOrder.ERC721Order memory order,
        uint256 erc721TokenId
    )
        public
        override
        view
    {
        _validateOrderProperties(
            order.asNFTOrder(),
            erc721TokenId
        );
    }

    
    
    
    function getERC721OrderStatus(LibNFTOrder.ERC721Order memory order)
        public
        override
        view
        returns (LibNFTOrder.OrderStatus status)
    {
        // Only buy orders with `erc721TokenId` == 0 can be property
        // orders.
        if (order.erc721TokenProperties.length > 0 &&
                (order.direction != LibNFTOrder.TradeDirection.BUY_NFT ||
                 order.erc721TokenId != 0))
        {
            return LibNFTOrder.OrderStatus.INVALID;
        }

        // Buy orders cannot use ETH as the ERC20 token, since ETH cannot be
        // transferred from the buyer by a contract.
        if (order.direction == LibNFTOrder.TradeDirection.BUY_NFT &&
            address(order.erc20Token) == NATIVE_TOKEN_ADDRESS)
        {
            return LibNFTOrder.OrderStatus.INVALID;
        }

        // Check for expiry.
        if (order.expiry <= block.timestamp) {
            return LibNFTOrder.OrderStatus.EXPIRED;
        }

        // Check `orderStatusByMaker` state variable to see if the order
        // has been cancelled or previously filled.
        LibERC721OrdersStorage.Storage storage stor =
            LibERC721OrdersStorage.getStorage();
        // `orderStatusByMaker` is indexed by maker and nonce.
        uint256 orderStatusBitVector =
            stor.orderStatusByMaker[order.maker][uint248(order.nonce >> 8)];
        // The bitvector is indexed by the lower 8 bits of the nonce.
        uint256 flag = 1 << (order.nonce & 255);
        // If the designated bit is set, the order has been cancelled or
        // previously filled, so it is now unfillable.
        if (orderStatusBitVector & flag != 0) {
            return LibNFTOrder.OrderStatus.UNFILLABLE;
        }

        // Otherwise, the order is fillable.
        return LibNFTOrder.OrderStatus.FILLABLE;
    }

    
    
    
    function _getOrderInfo(LibNFTOrder.NFTOrder memory order)
        internal
        override
        view
        returns (LibNFTOrder.OrderInfo memory orderInfo)
    {
        LibNFTOrder.ERC721Order memory erc721Order = order.asERC721Order();
        orderInfo.orderHash = getERC721OrderHash(erc721Order);
        orderInfo.status = getERC721OrderStatus(erc721Order);
        orderInfo.orderAmount = 1;
        orderInfo.remainingAmount = orderInfo.status == LibNFTOrder.OrderStatus.FILLABLE ? 1 : 0;
    }

    
    
    
    function getERC721OrderHash(LibNFTOrder.ERC721Order memory order)
        public
        override
        view
        returns (bytes32 orderHash)
    {
        return _getEIP712Hash(LibNFTOrder.getERC721OrderStructHash(order));
    }

    
    ///      maker address and nonce range.
    
    
    ///        by maker address and the upper 248 bits of the
    ///        order nonce. We define `nonceRange` to be these
    ///        248 bits.
    
    ///         given maker and nonce range.
    function getERC721OrderStatusBitVector(address maker, uint248 nonceRange)
        external
        override
        view
        returns (uint256 bitVector)
    {
        LibERC721OrdersStorage.Storage storage stor =
            LibERC721OrdersStorage.getStorage();
        return stor.orderStatusByMaker[maker][nonceRange];
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

pragma solidity ^0.6;






library LibERC721OrdersStorage {

    
    struct Storage {
        // maker => nonce range => order status bit vector
        mapping(address => mapping(uint248 => uint256)) orderStatusByMaker;
        // order hash => isSigned
        mapping(bytes32 => bool) preSigned;
    }

    
    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.ERC721Orders
        );
        // Dip into assembly to change the slot pointed to by the local
        // variable `stor`.
        // See https://solidity.readthedocs.io/en/v0.6.8/assembly.html?highlight=slot#access-to-external-variables-functions-and-libraries
        assembly { stor_slot := storageSlot }
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
    uint256 private constant _FEE_TYPEHASH =
        0xe68c29f1b4e8cce0bbcac76eb1334bdc1dc1f293a517c90e9e532340e1e94115;

    // keccak256(abi.encodePacked(
    //     "Property(",
    //       "address propertyValidator,",
    //       "bytes propertyData",
    //     ")"
    // ))
    uint256 private constant _PROPERTY_TYPEHASH =
        0x6292cf854241cb36887e639065eca63b3af9f7f70270cebeda4c29b6d3bc65e8;

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
    function asNFTOrder(ERC721Order memory erc721Order)
        internal
        pure
        returns (NFTOrder memory nftOrder)
    {
        assembly {
            nftOrder := erc721Order
        }
    }

    // ERC1155Order and NFTOrder fields are aligned with
    // the exception of the last field `erc1155TokenAmount`
    // in ERC1155Order, so we can safely cast an ERC1155Order
    // to an NFTOrder.
    function asNFTOrder(ERC1155Order memory erc1155Order)
        internal
        pure
        returns (NFTOrder memory nftOrder)
    {
        assembly {
            nftOrder := erc1155Order
        }
    }

    // ERC721Order and NFTOrder fields are aligned, so
    // we can safely cast an MFTOrder to an ERC721Order.
    function asERC721Order(NFTOrder memory nftOrder)
        internal
        pure
        returns (ERC721Order memory erc721Order)
    {
        assembly {
            erc721Order := nftOrder
        }
    }

    // NOTE: This is only safe if `nftOrder` was previously
    // cast from an `ERC1155Order` and the original
    // `erc1155TokenAmount` memory word has not been corrupted!
    function asERC1155Order(
        NFTOrder memory nftOrder
    )
        internal
        pure
        returns (ERC1155Order memory erc1155Order)
    {
        assembly {
            erc1155Order := nftOrder
        }
    }

    
    
    
    function getERC721OrderStructHash(ERC721Order memory order)
        internal
        pure
        returns (bytes32 structHash)
    {
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
            if lt(order, 32) { invalid() } // Don't underflow memory.

            let typeHashPos := sub(order, 32) // order - 32
            let feesHashPos := add(order, 224) // order + (32 * 7)
            let propertiesHashPos := add(order, 320) // order + (32 * 10)

            let typeHashMemBefore := mload(typeHashPos)
            let feeHashMemBefore := mload(feesHashPos)
            let propertiesHashMemBefore := mload(propertiesHashPos)

            mstore(typeHashPos, _ERC_721_ORDER_TYPEHASH)
            mstore(feesHashPos, feesHash)
            mstore(propertiesHashPos, propertiesHash)
            structHash := keccak256(typeHashPos, 384 /* 32 * 12 */ )

            mstore(typeHashPos, typeHashMemBefore)
            mstore(feesHashPos, feeHashMemBefore)
            mstore(propertiesHashPos, propertiesHashMemBefore)
        }
        return structHash;
    }

    
    
    
    function getERC1155OrderStructHash(ERC1155Order memory order)
        internal
        pure
        returns (bytes32 structHash)
    {
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
            if lt(order, 32) { invalid() } // Don't underflow memory.

            let typeHashPos := sub(order, 32) // order - 32
            let feesHashPos := add(order, 224) // order + (32 * 7)
            let propertiesHashPos := add(order, 320) // order + (32 * 10)

            let typeHashMemBefore := mload(typeHashPos)
            let feesHashMemBefore := mload(feesHashPos)
            let propertiesHashMemBefore := mload(propertiesHashPos)

            mstore(typeHashPos, _ERC_1155_ORDER_TYPEHASH)
            mstore(feesHashPos, feesHash)
            mstore(propertiesHashPos, propertiesHash)
            structHash := keccak256(typeHashPos, 416 /* 32 * 12 */ )

            mstore(typeHashPos, typeHashMemBefore)
            mstore(feesHashPos, feesHashMemBefore)
            mstore(propertiesHashPos, propertiesHashMemBefore)
        }
        return structHash;
    }

    // Hashes the `properties` array as part of computing the
    // EIP-712 hash of an `ERC721Order` or `ERC1155Order`.
    function _propertiesHash(Property[] memory properties)
        private
        pure
        returns (bytes32 propertiesHash)
    {
        uint256 numProperties = properties.length;
        // We give `properties.length == 0` and `properties.length == 1`
        // special treatment because we expect these to be the most common.
        if (numProperties == 0) {
            propertiesHash = _EMPTY_ARRAY_KECCAK256;
        } else if (numProperties == 1) {
            Property memory property = properties[0];
            if (
                address(property.propertyValidator) == address(0) &&
                property.propertyData.length == 0
            ) {
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
                propertyStructHashArray[i] = keccak256(abi.encode(
                    _PROPERTY_TYPEHASH,
                    properties[i].propertyValidator,
                    keccak256(properties[i].propertyData)
                ));
            }
            assembly {
                propertiesHash := keccak256(add(propertyStructHashArray, 32), mul(numProperties, 32))
            }
        }
    }

    // Hashes the `fees` array as part of computing the
    // EIP-712 hash of an `ERC721Order` or `ERC1155Order`.
    function _feesHash(Fee[] memory fees)
        private
        pure
        returns (bytes32 feesHash)
    {
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
                feeStructHashArray[i] = keccak256(abi.encode(
                    _FEE_TYPEHASH,
                    fees[i].recipient,
                    fees[i].amount,
                    keccak256(fees[i].feeData)
                ));
            }
            assembly {
                feesHash := keccak256(add(feeStructHashArray, 32), mul(numFees, 32))
            }
        }
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

pragma solidity ^0.6;



interface IPropertyValidator {

    
    ///      Should revert if the asset does not satisfy the specified properties.
    
    
    
    function validateProperty(
        address tokenAddress,
        uint256 tokenId,
        bytes calldata propertyData
    )
        external
        view;
}

// 
/*

  Copyright 2021 ZeroEx Intl.
  Modifications copyright (C) 2022 TheOpenDAO

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















contract ERC1155OrdersFeature is
    IFeature,
    IERC1155OrdersFeature,
    FixinERC1155Spender,
    NFTOrders
{
    using LibSafeMathV06 for uint256;
    using LibSafeMathV06 for uint128;
    using LibNFTOrder for LibNFTOrder.ERC1155Order;
    using LibNFTOrder for LibNFTOrder.NFTOrder;

    
    string public constant override FEATURE_NAME = "ERC1155Orders";
    
    uint256 public immutable override FEATURE_VERSION = _encodeVersion(1, 0, 0);

    
    bytes4 private constant ERC1155_RECEIVED_MAGIC_BYTES = this.onERC1155Received.selector;


    constructor(address zeroExAddress, IEtherTokenV06 weth)
        public
        NFTOrders(zeroExAddress, weth)
    {}

    
    ///      Should be delegatecalled by `Migrate.migrate()`.
    
    function migrate()
        external
        returns (bytes4 success)
    {
        _registerFeatureFunction(this.sellERC1155.selector);
        _registerFeatureFunction(this.buyERC1155.selector);
        _registerFeatureFunction(this.cancelERC1155Order.selector);
        _registerFeatureFunction(this.batchCancelERC1155Orders.selector);
        _registerFeatureFunction(this.batchBuyERC1155s.selector);
        _registerFeatureFunction(this.batchBuyERC1155sWithMaxNumber.selector);
        _registerFeatureFunction(this.onERC1155Received.selector);
        _registerFeatureFunction(this.onERC1155Received2.selector);
        _registerFeatureFunction(this.preSignERC1155Order.selector);
        _registerFeatureFunction(this.validateERC1155OrderSignature.selector);
        _registerFeatureFunction(this.validateERC1155OrderProperties.selector);
        _registerFeatureFunction(this.getERC1155OrderInfo.selector);
        _registerFeatureFunction(this.getERC1155OrderHash.selector);
        return LibMigrate.MIGRATE_SUCCESS;
    }

    
    
    
    
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
        LibNFTOrder.ERC1155Order memory buyOrder,
        LibSignature.Signature memory signature,
        uint256 erc1155TokenId,
        uint128 erc1155SellAmount,
        bool unwrapNativeToken,
        bytes memory callbackData
    )
        public
        override
    {
        _sellERC1155(
            buyOrder,
            signature,
            SellParams(
                erc1155SellAmount,
                erc1155TokenId,
                unwrapNativeToken,
                msg.sender, // taker
                msg.sender, // owner
                callbackData
            )
        );
    }

    
    
    
    
    ///        to buy.
    
    ///        `zeroExERC1155OrderCallback` on `msg.sender` after
    ///        the ERC1155 asset has been transferred to `msg.sender`
    ///        but before transferring the ERC20 tokens to the seller.
    ///        Native tokens acquired during the callback can be used
    ///        to fill the order.
    function buyERC1155(
        LibNFTOrder.ERC1155Order memory sellOrder,
        LibSignature.Signature memory signature,
        uint128 erc1155BuyAmount,
        bytes memory callbackData
    )
        public
        override
        payable
    {
        uint256 ethBalanceBefore = address(this).balance
            .safeSub(msg.value);
        _buyERC1155(
            sellOrder,
            signature,
            BuyParams(
                erc1155BuyAmount,
                msg.value,
                callbackData
            )
        );
        uint256 ethBalanceAfter = address(this).balance;
        // Cannot use pre-existing ETH balance
        if (ethBalanceAfter < ethBalanceBefore) {
            LibNFTOrdersRichErrors.OverspentEthError(
                ethBalanceBefore - ethBalanceAfter + msg.value,
                msg.value
            ).rrevert();
        }
        // Refund
        _transferEth(msg.sender, ethBalanceAfter - ethBalanceBefore);
    }

    
    ///      should be the maker of the order. Silently succeeds if
    ///      an order with the same nonce has already been filled or
    ///      cancelled.
    
    function cancelERC1155Order(uint256 orderNonce)
        public
        override
    {
        // The bitvector is indexed by the lower 8 bits of the nonce.
        uint256 flag = 1 << (orderNonce & 255);
        // Update order cancellation bit vector to indicate that the order
        // has been cancelled/filled by setting the designated bit to 1.
        LibERC1155OrdersStorage.getStorage().orderCancellationByMaker
            [msg.sender][uint248(orderNonce >> 8)] |= flag;

        emit ERC1155OrderCancelled(msg.sender, orderNonce);
    }

    
    ///      should be the maker of the orders. Silently succeeds if
    ///      an order with the same nonce has already been filled or
    ///      cancelled.
    
    function batchCancelERC1155Orders(uint256[] calldata orderNonces)
        external
        override
    {
        for (uint256 i = 0; i < orderNonces.length; i++) {
            cancelERC1155Order(orderNonces[i]);
        }
    }

    
    ///      given orders.
    
    
    
    ///        to buy for each order.
    
    ///        callback for each order. Refer to the `callbackData`
    ///        parameter to for `buyERC1155`.
    
    ///        function fails to fill any individual order.
    
    
    ///         each order in `orders` was successfully filled.
    function batchBuyERC1155sWithMaxNumber(
        LibNFTOrder.ERC1155Order[] memory sellOrders,
        LibSignature.Signature[] memory signatures,
        uint128[] calldata erc1155FillAmounts,
        bytes[] memory callbackData,
        bool revertIfIncomplete,
        uint256 maxNFTs
    )
        public
        override
        payable
        returns (bool[] memory successes)
    {
        require(
            sellOrders.length == signatures.length &&
            sellOrders.length == erc1155FillAmounts.length &&
            sellOrders.length == callbackData.length,
            "ERC1155OrdersFeature::batchBuyERC1155s/ARRAY_LENGTH_MISMATCH"
        );
        successes = new bool[](sellOrders.length);

        uint256 ethBalanceBefore = address(this).balance
            .safeSub(msg.value);
        if (revertIfIncomplete) {
            for (uint256 i = 0; i < sellOrders.length; i++) {
                // Will revert if _buyERC1155 reverts.
                _buyERC1155(
                    sellOrders[i],
                    signatures[i],
                    BuyParams(
                        erc1155FillAmounts[i],
                        address(this).balance.safeSub(ethBalanceBefore), // Remaining ETH available
                        callbackData[i]
                    )
                );
                successes[i] = true;
            }
        } else {
            require(maxNFTs > 0, "ERC1155OrdersFeature::batchBuyERC1155s/maxNFTs_CANNOT_BE_ZERO");
            for (uint256 i = 0; i < sellOrders.length; i++) {
                // Delegatecall `_buyERC1155` to catch swallow reverts while
                // preserving execution context.
                // Note that `_buyERC1155` is a public function but should _not_
                // be registered in the Exchange Proxy.
                (successes[i], ) = _implementation.delegatecall(
                    abi.encodeWithSelector(
                        this._buyERC1155.selector,
                        sellOrders[i],
                        signatures[i],
                        BuyParams(
                            erc1155FillAmounts[i],
                            address(this).balance.safeSub(ethBalanceBefore), // Remaining ETH available
                            callbackData[i]
                        )
                    )
                );
                if (successes[i]) {
                    if (--maxNFTs == 0) {
                        break;
                    }
                }
            }
        }

        // Cannot use pre-existing ETH balance
        uint256 ethBalanceAfter = address(this).balance;
        if (ethBalanceAfter < ethBalanceBefore) {
            LibNFTOrdersRichErrors.OverspentEthError(
                msg.value + (ethBalanceBefore - ethBalanceAfter),
                msg.value
            ).rrevert();
        }

        // Refund
        _transferEth(msg.sender, ethBalanceAfter - ethBalanceBefore);
    }

    
    ///      given orders.
    
    
    
    ///        to buy for each order.
    
    ///        callback for each order. Refer to the `callbackData`
    ///        parameter to for `buyERC1155`.
    
    ///        function fails to fill any individual order.
    
    ///         each order in `orders` was successfully filled.
    function batchBuyERC1155s(
        LibNFTOrder.ERC1155Order[] memory sellOrders,
        LibSignature.Signature[] memory signatures,
        uint128[] calldata erc1155FillAmounts,
        bytes[] memory callbackData,
        bool revertIfIncomplete
    )
        public
        override
        payable
        returns (bool[] memory successes)
    {
        return batchBuyERC1155sWithMaxNumber(sellOrders, signatures, erc1155FillAmounts, callbackData, revertIfIncomplete, uint256(-1));
    }

    
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
    ) external override returns (bytes4 success) {
        return onERC1155Received2(operator,from,tokenId,value,data);
    }

    function onERC1155Received2(
        address operator,
        address /* from */,
        uint256 tokenId,
        uint256 value,
        bytes calldata data
    )
        public
        returns (bytes4 success)
    {
        // Decode the order, signature, and `unwrapNativeToken` from
        // `data`. If `data` does not encode such parameters, this
        // will throw.
        (
            uint256 code,
            LibNFTOrder.ERC1155Order memory buyOrder,
            LibSignature.Signature memory signature,
            bool unwrapNativeToken
        ) = abi.decode(
            data,
            (uint256, LibNFTOrder.ERC1155Order, LibSignature.Signature, bool)
        );code;

        // `onERC1155Received` is called by the ERC1155 token contract.
        // Check that it matches the ERC1155 token in the order.
        if (msg.sender != address(buyOrder.erc1155Token)) {
            LibNFTOrdersRichErrors.ERC1155TokenMismatchError(
                msg.sender,
                address(buyOrder.erc1155Token)
            ).rrevert();
        }

        _sellERC1155(
            buyOrder,
            signature,
            SellParams(
                value.safeDowncastToUint128(),
                tokenId,
                unwrapNativeToken,
                operator,       // taker
                address(this),  // owner (we hold the NFT currently)
                new bytes(0)    // No taker callback
            )
        );

        return ERC1155_RECEIVED_MAGIC_BYTES;
    }

    
    ///      the order, the `PRESIGNED` signature type will become
    ///      valid for that order and signer.
    
    function preSignERC1155Order(LibNFTOrder.ERC1155Order memory order)
        public
        override
    {
        require(
            order.maker == msg.sender,
            "ERC1155OrdersFeature::preSignERC1155Order/MAKER_MISMATCH"
        );
        bytes32 orderHash = getERC1155OrderHash(order);

        LibERC1155OrdersStorage.Storage storage stor =
            LibERC1155OrdersStorage.getStorage();
        // Set `preSigned` to true on the order state variable
        // to indicate that the order has been pre-signed.
        stor.orderState[orderHash].preSigned = true;

        emit ERC1155OrderPreSigned(
            order.direction,
            order.maker,
            order.taker,
            order.expiry,
            order.nonce,
            order.erc20Token,
            order.erc20TokenAmount,
            order.fees,
            order.erc1155Token,
            order.erc1155TokenId,
            order.erc1155TokenProperties,
            order.erc1155TokenAmount
        );
    }

    // Core settlement logic for selling an ERC1155 asset.
    // Used by `sellERC1155` and `onERC1155Received`.
    function _sellERC1155(
        LibNFTOrder.ERC1155Order memory buyOrder,
        LibSignature.Signature memory signature,
        SellParams memory params
    )
        private
    {
        uint256 erc20FillAmount = _sellNFT(
            buyOrder.asNFTOrder(),
            signature,
            params
        );

        emit ERC1155OrderFilled(
            buyOrder.direction,
            buyOrder.maker,
            params.taker,
            buyOrder.nonce,
            buyOrder.erc20Token,
            erc20FillAmount,
            buyOrder.erc1155Token,
            params.tokenId,
            params.sellAmount,
            address(0)
        );
    }

    // Core settlement logic for buying an ERC1155 asset.
    // Used by `buyERC1155` and `batchBuyERC1155s`.
    function _buyERC1155(
        LibNFTOrder.ERC1155Order memory sellOrder,
        LibSignature.Signature memory signature,
        BuyParams memory params
    )
        public
        payable
    {
        uint256 erc20FillAmount = _buyNFT(
            sellOrder.asNFTOrder(),
            signature,
            params
        );

        emit ERC1155OrderFilled(
            sellOrder.direction,
            sellOrder.maker,
            msg.sender,
            sellOrder.nonce,
            sellOrder.erc20Token,
            erc20FillAmount,
            sellOrder.erc1155Token,
            sellOrder.erc1155TokenId,
            params.buyAmount,
            address(0)
        );
    }

    
    ///      the given ERC1155 order. Reverts if not.
    
    
    function validateERC1155OrderSignature(
        LibNFTOrder.ERC1155Order memory order,
        LibSignature.Signature memory signature
    )
        public
        override
        view
    {
        bytes32 orderHash = getERC1155OrderHash(order);
        _validateOrderSignature(orderHash, signature, order.maker);
    }

    
    ///      given maker and order hash. Reverts if the signature
    ///      is not valid.
    
    
    
    function _validateOrderSignature(
        bytes32 orderHash,
        LibSignature.Signature memory signature,
        address maker
    )
        internal
        override
        view
    {
        if (signature.signatureType == LibSignature.SignatureType.PRESIGNED) {
            // Check if order hash has been pre-signed by the maker.
            bool isPreSigned = LibERC1155OrdersStorage.getStorage()
                .orderState[orderHash].preSigned;
            if (!isPreSigned) {
                LibNFTOrdersRichErrors.InvalidSignerError(maker, address(0)).rrevert();
            }
        } else {
            address signer = LibSignature.getSignerOfHash(orderHash, signature);
            if (signer != maker) {
                LibNFTOrdersRichErrors.InvalidSignerError(maker, signer).rrevert();
            }
        }
    }

    
    
    
    
    
    
    ///        1 for ERC721 assets.
    function _transferNFTAssetFrom(
        address token,
        address from,
        address to,
        uint256 tokenId,
        uint256 amount
    )
        internal
        override
    {
        _transferERC1155AssetFrom(IERC1155Token(token), from, to, tokenId, amount);
    }

    
    ///      has been filled by the given amount.
    
    
    ///        that the order has been filled by.
    function _updateOrderState(
        LibNFTOrder.NFTOrder memory /* order */,
        bytes32 orderHash,
        uint128 fillAmount
    )
        internal
        override
    {
        LibERC1155OrdersStorage.Storage storage stor = LibERC1155OrdersStorage.getStorage();
        uint128 filledAmount = stor.orderState[orderHash].filledAmount;
        // Filled amount should never overflow 128 bits
        assert(filledAmount + fillAmount > filledAmount);
        stor.orderState[orderHash].filledAmount = filledAmount + fillAmount;
    }

    
    ///      whether or not the given token ID satisfies the required
    ///      properties specified in the order. If the order does not
    ///      specify any properties, this function instead checks
    ///      whether the given token ID matches the ID in the order.
    ///      Reverts if any checks fail, or if the order is selling
    ///      an ERC1155 asset.
    
    
    function validateERC1155OrderProperties(
        LibNFTOrder.ERC1155Order memory order,
        uint256 erc1155TokenId
    )
        public
        override
        view
    {
        _validateOrderProperties(
            order.asNFTOrder(),
            erc1155TokenId
        );
    }

    
    
    
    function getERC1155OrderInfo(LibNFTOrder.ERC1155Order memory order)
        public
        override
        view
        returns (LibNFTOrder.OrderInfo memory orderInfo)
    {
        orderInfo.orderAmount = order.erc1155TokenAmount;
        orderInfo.orderHash = getERC1155OrderHash(order);

        // Only buy orders with `erc1155TokenId` == 0 can be property
        // orders.
        if (order.erc1155TokenProperties.length > 0 &&
                (order.direction != LibNFTOrder.TradeDirection.BUY_NFT ||
                 order.erc1155TokenId != 0))
        {
            orderInfo.status = LibNFTOrder.OrderStatus.INVALID;
            return orderInfo;
        }

        // Buy orders cannot use ETH as the ERC20 token, since ETH cannot be
        // transferred from the buyer by a contract.
        if (order.direction == LibNFTOrder.TradeDirection.BUY_NFT &&
            address(order.erc20Token) == NATIVE_TOKEN_ADDRESS)
        {
            orderInfo.status = LibNFTOrder.OrderStatus.INVALID;
            return orderInfo;
        }

        // Check for expiry.
        if (order.expiry <= block.timestamp) {
            orderInfo.status = LibNFTOrder.OrderStatus.EXPIRED;
            return orderInfo;
        }

        {
            LibERC1155OrdersStorage.Storage storage stor =
                LibERC1155OrdersStorage.getStorage();

            LibERC1155OrdersStorage.OrderState storage orderState =
                stor.orderState[orderInfo.orderHash];
            orderInfo.remainingAmount = order.erc1155TokenAmount
                .safeSub128(orderState.filledAmount);

            // `orderCancellationByMaker` is indexed by maker and nonce.
            uint256 orderCancellationBitVector =
                stor.orderCancellationByMaker[order.maker][uint248(order.nonce >> 8)];
            // The bitvector is indexed by the lower 8 bits of the nonce.
            uint256 flag = 1 << (order.nonce & 255);

            if (orderInfo.remainingAmount == 0 ||
                orderCancellationBitVector & flag != 0)
            {
                orderInfo.status = LibNFTOrder.OrderStatus.UNFILLABLE;
                return orderInfo;
            }
        }

        // Otherwise, the order is fillable.
        orderInfo.status = LibNFTOrder.OrderStatus.FILLABLE;
    }

    
    
    
    function _getOrderInfo(LibNFTOrder.NFTOrder memory order)
        internal
        override
        view
        returns (LibNFTOrder.OrderInfo memory orderInfo)
    {
        return getERC1155OrderInfo(order.asERC1155Order());
    }

    
    
    
    function getERC1155OrderHash(LibNFTOrder.ERC1155Order memory order)
        public
        override
        view
        returns (bytes32 orderHash)
    {
        return _getEIP712Hash(LibNFTOrder.getERC1155OrderStructHash(order));
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

pragma solidity ^0.6;






library LibERC1155OrdersStorage {

    struct OrderState {
        // The amount (denominated in the ERC1155 asset)
        // that the order has been filled by.
        uint128 filledAmount;
        // Whether the order has been pre-signed.
        bool preSigned;
    }

    
    struct Storage {
        // Mapping from order hash to order state:
        mapping(bytes32 => OrderState) orderState;
        // maker => nonce range => order cancellation bit vector
        mapping(address => mapping(uint248 => uint256)) orderCancellationByMaker;
    }

    
    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.ERC1155Orders
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
  Modifications copyright (C) 2022 TheOpenDAO

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
    IERC721OrdersFeature,
    IERC1155OrdersFeature,
    IERC165Feature,
    INFTAuctionsFeature,
    INFTToolsFeature
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
    )
        external;

    
    ///      pulled from `owner`.
    
    
    
    function getSpendableERC20BalanceOf(IERC20TokenV06 token, address owner)
        external
        view
        returns (uint256 amount);

    
    
    function getAllowanceTarget() external view returns (address target);
}

// 
/*

  Copyright 2021 TheOpenDAO

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











contract NFTToolsFeature is
    IFeature,
    FixinERC721Spender,
    FixinERC1155Spender,
    FixinEIP712,
    FixinCommon,
    INFTToolsFeature
{
    
    string public constant override FEATURE_NAME = "NFTTools";

    
    uint256 public immutable override FEATURE_VERSION = _encodeVersion(1, 0, 0);

    constructor(address zeroExAddress) public FixinEIP712(zeroExAddress) { }

    
    ///      Should be delegatecalled by `Migrate.migrate()`.
    
    function migrate() external virtual returns (bytes4 success) {
        _registerFeatureFunction(this.batchTransferNFTAssetsFrom.selector);
        return LibMigrate.MIGRATE_SUCCESS;
    }

    
    
    
    function batchTransferNFTAssetsFrom(TransferERC721AsseetsParam[] calldata erc721s, TransferERC1155AsseetsParam[] calldata erc1155s) external override {
        uint256 len = erc721s.length;
        uint256 i = 0;
        for(; i < len; ++i) {
            _transferERC721AssetFrom(erc721s[i].token, msg.sender, erc721s[i].to, erc721s[i].tokenId);
        }
        len = erc1155s.length;
        i = 0;
        for(; i < len; ++i) {
            _transferERC1155AssetFrom(erc1155s[i].token, msg.sender, erc1155s[i].to, erc1155s[i].tokenId, erc1155s[i].amount);
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














contract OwnableFeature is
    IFeature,
    IOwnableFeature,
    FixinCommon
{

    
    string public constant override FEATURE_NAME = "Ownable";
    
    uint256 public immutable override FEATURE_VERSION = _encodeVersion(1, 0, 0);

    using LibRichErrorsV06 for bytes;

    
    ///      to allow the bootstrappers to call `extend()`. Ownership should be
    ///      transferred to the real owner by the bootstrapper after
    ///      bootstrapping is complete.
    
    function bootstrap() external returns (bytes4 success) {
        // Set the owner to ourselves to allow bootstrappers to call `extend()`.
        LibOwnableStorage.getStorage().owner = address(this);

        // Register feature functions.
        SimpleFunctionRegistryFeature(address(this))._extendSelf(this.transferOwnership.selector, _implementation);
        SimpleFunctionRegistryFeature(address(this))._extendSelf(this.owner.selector, _implementation);
        SimpleFunctionRegistryFeature(address(this))._extendSelf(this.migrate.selector, _implementation);
        return LibBootstrap.BOOTSTRAP_SUCCESS;
    }

    
    ///      Only directly callable by the owner.
    
    function transferOwnership(address newOwner)
        external
        override
        onlyOwner
    {
        LibOwnableStorage.Storage storage proxyStor = LibOwnableStorage.getStorage();

        if (newOwner == address(0)) {
            LibOwnableRichErrors.TransferOwnerToZeroError().rrevert();
        } else {
            proxyStor.owner = newOwner;
            emit OwnershipTransferred(msg.sender, newOwner);
        }
    }

    
    ///      The result of the function being called should be the magic bytes
    ///      0x2c64c5ef (`keccack('MIGRATE_SUCCESS')`). Only callable by the owner.
    ///      Temporarily sets the owner to ourselves so we can perform admin functions.
    ///      Before returning, the owner will be set to `newOwner`.
    
    
    
    function migrate(address target, bytes calldata data, address newOwner)
        external
        override
        onlyOwner
    {
        if (newOwner == address(0)) {
            LibOwnableRichErrors.TransferOwnerToZeroError().rrevert();
        }

        LibOwnableStorage.Storage storage stor = LibOwnableStorage.getStorage();
        // The owner will be temporarily set to `address(this)` inside the call.
        stor.owner = address(this);

        // Perform the migration.
        LibMigrate.delegatecallMigrateFunction(target, data);

        // Update the owner.
        stor.owner = newOwner;

        emit Migrated(msg.sender, target, newOwner);
    }

    
    
    function owner() external override view returns (address owner_) {
        return LibOwnableStorage.getStorage().owner;
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






library LibOwnableStorage {

    
    struct Storage {
        // The owner of this contract.
        address owner;
    }

    
    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.Ownable
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






library LibBootstrap {

    
    ///      This is `keccack('BOOTSTRAP_SUCCESS')`.
    bytes4 internal constant BOOTSTRAP_SUCCESS = 0xd150751b;

    using LibRichErrorsV06 for bytes;

    
    
    
    function delegatecallBootstrapFunction(
        address target,
        bytes memory data
    )
        internal
    {
        (bool success, bytes memory resultData) = target.delegatecall(data);
        if (!success ||
            resultData.length != 32 ||
            abi.decode(resultData, (bytes4)) != BOOTSTRAP_SUCCESS)
        {
            LibProxyRichErrors.BootstrapCallFailedError(target, resultData).rrevert();
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













contract SimpleFunctionRegistryFeature is
    IFeature,
    ISimpleFunctionRegistryFeature,
    FixinCommon
{
    
    string public constant override FEATURE_NAME = "SimpleFunctionRegistry";
    
    uint256 public immutable override FEATURE_VERSION = _encodeVersion(1, 0, 0);

    using LibRichErrorsV06 for bytes;

    
    
    function bootstrap()
        external
        returns (bytes4 success)
    {
        // Register the registration functions (inception vibes).
        _extend(this.extend.selector, _implementation);
        _extend(this._extendSelf.selector, _implementation);
        // Register the rollback function.
        _extend(this.rollback.selector, _implementation);
        // Register getters.
        _extend(this.getRollbackLength.selector, _implementation);
        _extend(this.getRollbackEntryAtIndex.selector, _implementation);
        return LibBootstrap.BOOTSTRAP_SUCCESS;
    }

    
    ///      Only directly callable by an authority.
    
    
    function rollback(bytes4 selector, address targetImpl)
        external
        override
        onlyOwner
    {
        (
            LibSimpleFunctionRegistryStorage.Storage storage stor,
            LibProxyStorage.Storage storage proxyStor
        ) = _getStorages();

        address currentImpl = proxyStor.impls[selector];
        if (currentImpl == targetImpl) {
            // Do nothing if already at targetImpl.
            return;
        }
        // Walk history backwards until we find the target implementation.
        address[] storage history = stor.implHistory[selector];
        uint256 i = history.length;
        for (; i > 0; --i) {
            address impl = history[i - 1];
            history.pop();
            if (impl == targetImpl) {
                break;
            }
        }
        if (i == 0) {
            LibSimpleFunctionRegistryRichErrors.NotInRollbackHistoryError(
                selector,
                targetImpl
            ).rrevert();
        }
        proxyStor.impls[selector] = targetImpl;
        emit ProxyFunctionUpdated(selector, currentImpl, targetImpl);
    }

    
    ///      Only directly callable by an authority.
    
    
    function extend(bytes4 selector, address impl)
        external
        override
        onlyOwner
    {
        _extend(selector, impl);
    }

    
    ///      Only callable from within.
    ///      This function is only used during the bootstrap process and
    ///      should be deregistered by the deployer after bootstrapping is
    ///      complete.
    
    
    function _extendSelf(bytes4 selector, address impl)
        external
        onlySelf
    {
        _extend(selector, impl);
    }

    
    
    
    ///         the function.
    function getRollbackLength(bytes4 selector)
        external
        override
        view
        returns (uint256 rollbackLength)
    {
        return LibSimpleFunctionRegistryStorage.getStorage().implHistory[selector].length;
    }

    
    
    
    
    ///         index `idx`.
    function getRollbackEntryAtIndex(bytes4 selector, uint256 idx)
        external
        override
        view
        returns (address impl)
    {
        return LibSimpleFunctionRegistryStorage.getStorage().implHistory[selector][idx];
    }

    
    
    
    function _extend(bytes4 selector, address impl)
        private
    {
        (
            LibSimpleFunctionRegistryStorage.Storage storage stor,
            LibProxyStorage.Storage storage proxyStor
        ) = _getStorages();

        address oldImpl = proxyStor.impls[selector];
        address[] storage history = stor.implHistory[selector];
        history.push(oldImpl);
        proxyStor.impls[selector] = impl;
        emit ProxyFunctionUpdated(selector, oldImpl, impl);
    }

    
    
    
    function _getStorages()
        private
        pure
        returns (
            LibSimpleFunctionRegistryStorage.Storage storage stor,
            LibProxyStorage.Storage storage proxyStor
        )
    {
        return (
            LibSimpleFunctionRegistryStorage.getStorage(),
            LibProxyStorage.getStorage()
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


library LibProxyRichErrors {

    // solhint-disable func-name-mixedcase

    function NotImplementedError(bytes4 selector)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("NotImplementedError(bytes4)")),
            selector
        );
    }

    function InvalidBootstrapCallerError(address actual, address expected)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("InvalidBootstrapCallerError(address,address)")),
            actual,
            expected
        );
    }

    function InvalidDieCallerError(address actual, address expected)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("InvalidDieCallerError(address,address)")),
            actual,
            expected
        );
    }

    function BootstrapCallFailedError(address target, bytes memory resultData)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("BootstrapCallFailedError(address,bytes)")),
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






library LibProxyStorage {

    
    struct Storage {
        // Mapping of function selector -> function implementation
        mapping(bytes4 => address) impls;
        // The owner of the proxy contract.
        address owner;
    }

    
    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.Proxy
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






library LibSimpleFunctionRegistryStorage {

    
    struct Storage {
        // Mapping of function selector -> implementation history.
        mapping(bytes4 => address[]) implHistory;
    }

    
    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.SimpleFunctionRegistry
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


library LibSimpleFunctionRegistryRichErrors {

    // solhint-disable func-name-mixedcase

    function NotInRollbackHistoryError(bytes4 selector, address targetImpl)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            bytes4(keccak256("NotInRollbackHistoryError(bytes4,address)")),
            selector,
            targetImpl
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










contract InitialMigration {

    
    struct BootstrapFeatures {
        SimpleFunctionRegistryFeature registry;
        OwnableFeature ownable;
    }

    
    ///      the governor.
    address public immutable initializeCaller;
    
    address private immutable _implementation;

    
    ///      to `initializeCaller_`.
    
    constructor(address initializeCaller_) public {
        initializeCaller = initializeCaller_;
        _implementation = address(this);
    }

    
    ///      transfers ownership to `owner`, then self-destructs.
    ///      Only callable by `initializeCaller` set in the contstructor.
    
    
    ///        been constructed with this contract as the bootstrapper.
    
    
    function initializeZeroEx(
        address payable owner,
        ZeroEx zeroEx,
        BootstrapFeatures memory features
    )
        public
        virtual
        returns (ZeroEx _zeroEx)
    {
        // Must be called by the allowed initializeCaller.
        require(msg.sender == initializeCaller, "InitialMigration/INVALID_SENDER");

        // Bootstrap the initial feature set.
        IBootstrapFeature(address(zeroEx)).bootstrap(
            address(this),
            abi.encodeWithSelector(this.bootstrap.selector, owner, features)
        );

        // Self-destruct. This contract should not hold any funds but we send
        // them to the owner just in case.
        this.die(owner);

        return zeroEx;
    }

    
    ///      The `ZeroEx` contract will delegatecall into this function.
    
    
    
    function bootstrap(address owner, BootstrapFeatures memory features)
        public
        virtual
        returns (bytes4 success)
    {
        // Deploy and migrate the initial features.
        // Order matters here.

        // Initialize Registry.
        LibBootstrap.delegatecallBootstrapFunction(
            address(features.registry),
            abi.encodeWithSelector(
                SimpleFunctionRegistryFeature.bootstrap.selector
            )
        );

        // Initialize OwnableFeature.
        LibBootstrap.delegatecallBootstrapFunction(
            address(features.ownable),
            abi.encodeWithSelector(
                OwnableFeature.bootstrap.selector
            )
        );

        // De-register `SimpleFunctionRegistryFeature._extendSelf`.
        SimpleFunctionRegistryFeature(address(this)).rollback(
            SimpleFunctionRegistryFeature._extendSelf.selector,
            address(0)
        );

        // Transfer ownership to the real owner.
        OwnableFeature(address(this)).transferOwnership(owner);

        success = LibBootstrap.BOOTSTRAP_SUCCESS;
    }

    
    
    function die(address payable ethRecipient) public virtual {
        require(msg.sender == _implementation, "InitialMigration/INVALID_SENDER");
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










///      interacting with the 0x protocol.
contract ZeroEx {
    // solhint-disable separate-by-one-line-in-contract,indent,var-name-mixedcase
    using LibBytesV06 for bytes;

    
    ///      After constructing this contract, `bootstrap()` should be called
    ///      by `bootstrap()` to seed the initial feature set.
    
    constructor(address bootstrapper) public {
        // Temporarily create and register the bootstrap feature.
        // It will deregister itself after `bootstrap()` has been called.
        BootstrapFeature bootstrap = new BootstrapFeature(bootstrapper);
        LibProxyStorage.getStorage().impls[bootstrap.bootstrap.selector] =
            address(bootstrap);
    }

    // solhint-disable state-visibility

    
    fallback() external payable {
        bytes4 selector = msg.data.readBytes4(0);
        address impl = getFunctionImplementation(selector);
        if (impl == address(0)) {
            _revertWithData(LibProxyRichErrors.NotImplementedError(selector));
        }

        (bool success, bytes memory resultData) = impl.delegatecall(msg.data);
        if (!success) {
            _revertWithData(resultData);
        }
        _returnWithData(resultData);
    }

    
    receive() external payable {}

    // solhint-enable state-visibility

    
    
    
    function getFunctionImplementation(bytes4 selector)
        public
        view
        returns (address impl)
    {
        return LibProxyStorage.getStorage().impls[selector];
    }

    
    
    function _revertWithData(bytes memory data) private pure {
        assembly { revert(add(data, 32), mload(data)) }
    }

    
    
    function _returnWithData(bytes memory data) private pure {
        assembly { return(add(data, 32), mload(data)) }
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
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                from,
                to
            ));
        }
        if (to > b.length) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
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

    
    ///      When `from == 0`, the original array will match the slice.
    ///      In other cases its state will be corrupted.
    
    
    
    
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
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                from,
                to
            ));
        }
        if (to > b.length) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
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
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanZeroRequired,
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
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
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
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
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
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
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
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
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
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsFourRequired,
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









contract BootstrapFeature is
    IBootstrapFeature
{
    // solhint-disable state-visibility,indent
    
    ///      This has to be immutable to persist across delegatecalls.
    address immutable private _deployer;
    
    ///      This has to be immutable to persist across delegatecalls.
    address immutable private _implementation;
    
    ///      This has to be immutable to persist across delegatecalls.
    address immutable private _bootstrapCaller;
    // solhint-enable state-visibility,indent

    using LibRichErrorsV06 for bytes;

    
    ///      After constructing this contract, `bootstrap()` should be called
    ///      to seed the initial feature set.
    
    constructor(address bootstrapCaller) public {
        _deployer = msg.sender;
        _implementation = address(this);
        _bootstrapCaller = bootstrapCaller;
    }

    
    ///      into `target`. Before exiting the `bootstrap()` function will
    ///      deregister itself from the proxy to prevent being called again.
    
    
    function bootstrap(address target, bytes calldata callData) external override {
        // Only the bootstrap caller can call this function.
        if (msg.sender != _bootstrapCaller) {
            LibProxyRichErrors.InvalidBootstrapCallerError(
                msg.sender,
                _bootstrapCaller
            ).rrevert();
        }
        // Deregister.
        LibProxyStorage.getStorage().impls[this.bootstrap.selector] = address(0);
        // Self-destruct.
        BootstrapFeature(_implementation).die();
        // Call the bootstrapper.
        LibBootstrap.delegatecallBootstrapFunction(target, callData);
    }

    
    ///      Can only be called by the deployer.
    function die() external {
        assert(address(this) == _implementation);
        if (msg.sender != _deployer) {
            LibProxyRichErrors.InvalidDieCallerError(msg.sender, _deployer).rrevert();
        }
        selfdestruct(msg.sender);
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







contract ERC165Feature is
    IFeature,
    FixinCommon
{
    
    string public constant override FEATURE_NAME = "ERC165";
    
    uint256 public immutable override FEATURE_VERSION = _encodeVersion(1, 0, 0);

    
    ///      ERC165 interface. This function should use at most 30,000 gas.
    
    
    ///         0x Exchange Proxy.
    function supportInterface(bytes4 interfaceId)
        external
        pure
        returns (bool isSupported)
    {
        return interfaceId == 0x01ffc9a7 || // ERC-165 support
               interfaceId == 0x150b7a02 || // ERC-721 `ERC721TokenReceiver` support
               interfaceId == 0x4e2312e0;   // ERC-1155 `ERC1155TokenReceiver` support
    }
}