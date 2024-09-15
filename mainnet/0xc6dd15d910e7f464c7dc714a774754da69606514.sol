// SPDX-License-Identifier: MIT

// 
pragma solidity ^0.8.17;




interface ISignatureTransfer {
    
    
    error InvalidAmount(uint256 maxAmount);

    
    
    error LengthMismatch();

    
    event UnorderedNonceInvalidation(address indexed owner, uint256 word, uint256 mask);

    
    struct TokenPermissions {
        // ERC20 token address
        address token;
        // the maximum amount that can be spent
        uint256 amount;
    }

    
    struct PermitTransferFrom {
        TokenPermissions permitted;
        // a unique value for every token owner's signature to prevent signature replays
        uint256 nonce;
        // deadline on the permit signature
        uint256 deadline;
    }

    
    
    
    struct SignatureTransferDetails {
        // recipient address
        address to;
        // spender requested amount
        uint256 requestedAmount;
    }

    
    
    
    struct PermitBatchTransferFrom {
        // the tokens and corresponding amounts permitted for a transfer
        TokenPermissions[] permitted;
        // a unique value for every token owner's signature to prevent signature replays
        uint256 nonce;
        // deadline on the permit signature
        uint256 deadline;
    }

    
    
    
    
    
    function nonceBitmap(address, uint256) external view returns (uint256);

    
    
    
    
    
    
    function permitTransferFrom(
        PermitTransferFrom memory permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external;

    
    
    
    
    
    
    
    
    
    
    function permitWitnessTransferFrom(
        PermitTransferFrom memory permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes32 witness,
        string calldata witnessTypeString,
        bytes calldata signature
    ) external;

    
    
    
    
    
    function permitTransferFrom(
        PermitBatchTransferFrom memory permit,
        SignatureTransferDetails[] calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external;

    
    
    
    
    
    
    
    
    
    function permitWitnessTransferFrom(
        PermitBatchTransferFrom memory permit,
        SignatureTransferDetails[] calldata transferDetails,
        address owner,
        bytes32 witness,
        string calldata witnessTypeString,
        bytes calldata signature
    ) external;

    
    
    
    
    function invalidateUnorderedNonces(uint256 wordPos, uint256 mask) external;
}

// 
pragma solidity ^0.8.16;

struct BackupWitness {
    address[] signers;
    uint256 threshold;
}

library BackupWitnessLib {
    string private constant TOKEN_PERMISSIONS_TYPE = "TokenPermissions(address token,uint256 amount)";

    bytes internal constant WITNESS_TYPE = abi.encodePacked("TokenBackups(", "address[] signers,", "uint256 threshold)");

    bytes32 internal constant WITNESS_TYPE_HASH = keccak256(WITNESS_TYPE);

    string internal constant PERMIT2_WITNESS_TYPE =
        string(abi.encodePacked("TokenBackups witness)", WITNESS_TYPE, TOKEN_PERMISSIONS_TYPE));

    
    function hash(BackupWitness memory witness) internal pure returns (bytes32) {
        return keccak256(abi.encode(WITNESS_TYPE_HASH, keccak256(abi.encodePacked(witness.signers)), witness.threshold));
    }
}

pragma solidity 0.8.17;




contract EIP712 {
    // Cache the domain separator as an immutable value, but also store the chain id that it
    // corresponds to, in order to invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    bytes32 private constant _HASHED_NAME = keccak256("TokenBackups");
    bytes32 private constant _TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    constructor() {
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME);
    }

    
    
    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        return block.chainid == _CACHED_CHAIN_ID
            ? _CACHED_DOMAIN_SEPARATOR
            : _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME);
    }

    
    function _buildDomainSeparator(bytes32 typeHash, bytes32 nameHash) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, "1", block.chainid, address(this)));
    }

    
    function _hashTypedData(bytes32 dataHash) internal view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), dataHash));
    }
}

// 
pragma solidity ^0.8.17;

interface IERC1271 {
    
    
    
    
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}

// 
pragma solidity ^0.8.16;



struct RecoveryInfo {
    address oldAddress;
    ISignatureTransfer.SignatureTransferDetails[] transferDetails;
}

library PalSignatureLib {
    bytes internal constant SIGNATURE_TRANSFER_DETAILS_TYPE =
        abi.encodePacked("SignatureTransferDetails(", "address to,", "uint256 requestedAmount)");

    bytes32 internal constant SIGNATURE_TRANSFER_DETAILS_TYPE_HASH = keccak256(SIGNATURE_TRANSFER_DETAILS_TYPE);

    bytes internal constant RECOVERY_SIGS_TYPE = abi.encodePacked(
        "RecoveryInfo(",
        "address oldAddress,",
        "uint256 sigDeadline,",
        "SignatureTransferDetails[] details)",
        SIGNATURE_TRANSFER_DETAILS_TYPE
    );

    bytes32 internal constant RECOVERY_SIGS_TYPE_HASH = keccak256(RECOVERY_SIGS_TYPE);

    function hash(ISignatureTransfer.SignatureTransferDetails memory details) internal pure returns (bytes32) {
        return keccak256(abi.encode(SIGNATURE_TRANSFER_DETAILS_TYPE_HASH, details.to, details.requestedAmount));
    }

    function hash(ISignatureTransfer.SignatureTransferDetails[] memory details) internal pure returns (bytes32) {
        bytes32[] memory hashes = new bytes32[](details.length);
        for (uint256 i = 0; i < details.length; i++) {
            hashes[i] = hash(details[i]);
        }
        return keccak256(abi.encodePacked(hashes));
    }

    
    function hash(RecoveryInfo memory data, uint256 sigDeadline) internal pure returns (bytes32) {
        return keccak256(abi.encode(RECOVERY_SIGS_TYPE_HASH, data.oldAddress, sigDeadline, hash(data.transferDetails)));
    }
}

// 
pragma solidity ^0.8.13;







contract TokenBackups is EIP712 {
    using BackupWitnessLib for BackupWitness;
    using PalSignatureLib for RecoveryInfo;

    error NotEnoughSignatures();
    error InvalidThreshold();
    error InvalidNewAddress();
    error InvalidSigner();
    error InvalidSignature();
    error NotSorted();
    error InvalidSignatureLength();
    error InvalidContractSignature();
    error InvalidSignerLength();
    error SignatureExpired();

    bytes32 constant UPPER_BIT_MASK = (0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);

    // Sigs from your friends!!!
    // Both inputs should be sorted in ascending order by address.
    struct Pal {
        bytes sig;
        address addr;
        uint256 sigDeadline;
    }

    ISignatureTransfer private immutable _PERMIT2;

    constructor(address permit2) {
        _PERMIT2 = ISignatureTransfer(permit2);
    }

    function recover(
        Pal[] calldata pals,
        bytes calldata backup,
        ISignatureTransfer.PermitBatchTransferFrom calldata permitData,
        RecoveryInfo calldata recoveryInfo,
        BackupWitness calldata witnessData
    ) public {
        _verifySignatures(pals, recoveryInfo, witnessData);

        // owner is the old account address
        _PERMIT2.permitWitnessTransferFrom(
            permitData,
            recoveryInfo.transferDetails,
            recoveryInfo.oldAddress,
            witnessData.hash(),
            BackupWitnessLib.PERMIT2_WITNESS_TYPE,
            backup
        );
    }

    // revert if invalid
    // Note: sigs must be sorted
    function _verifySignatures(Pal[] calldata pals, RecoveryInfo calldata details, BackupWitness calldata witness)
        internal
        view
    {
        if (witness.threshold == 0) {
            revert InvalidThreshold();
        }

        if (witness.signers.length < witness.threshold) {
            revert InvalidSignerLength();
        }

        if (pals.length != witness.threshold) {
            revert NotEnoughSignatures();
        }

        address lastOwner = address(0);
        address currentOwner;

        for (uint256 i = 0; i < pals.length; ++i) {
            Pal calldata pal = pals[i];
            if (pal.sigDeadline < block.timestamp) {
                revert SignatureExpired();
            }
            bytes32 msgHash = details.hash(pal.sigDeadline);

            currentOwner = pal.addr;

            _verifySignature(pal.sig, _hashTypedData(msgHash), currentOwner);

            if (currentOwner <= lastOwner) {
                revert NotSorted();
            }

            bool isSigner;
            for (uint256 j = 0; j < witness.signers.length; j++) {
                if (witness.signers[j] == currentOwner) {
                    isSigner = true;
                    break;
                }
            }

            if (!isSigner) {
                revert InvalidSigner();
            }

            lastOwner = currentOwner;
        }
    }

    function _verifySignature(bytes calldata signature, bytes32 hash, address claimedSigner) private view {
        bytes32 r;
        bytes32 s;
        uint8 v;
        if (claimedSigner.code.length == 0) {
            if (signature.length == 65) {
                (r, s) = abi.decode(signature, (bytes32, bytes32));
                v = uint8(signature[64]);
            } else if (signature.length == 64) {
                // EIP-2098
                bytes32 vs;
                (r, vs) = abi.decode(signature, (bytes32, bytes32));
                s = vs & UPPER_BIT_MASK;
                v = uint8(uint256(vs >> 255)) + 27;
            } else {
                revert InvalidSignatureLength();
            }
            address signer = ecrecover(hash, v, r, s);
            if (signer == address(0)) revert InvalidSignature();

            if (signer != claimedSigner) revert InvalidSigner();
        } else {
            bytes4 magicValue = IERC1271(claimedSigner).isValidSignature(hash, signature);
            if (magicValue != IERC1271.isValidSignature.selector) revert InvalidContractSignature();
        }
    }
}