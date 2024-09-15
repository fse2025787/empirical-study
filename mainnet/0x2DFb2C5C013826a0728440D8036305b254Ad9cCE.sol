// SPDX-License-Identifier: MIT


// 
pragma solidity >=0.8.4 <0.9.0;



interface IKeep3rJobFundableCredits {
  // Events

  
  
  
  
  
  event TokenCreditAddition(address indexed _job, address indexed _token, address indexed _provider, uint256 _amount);

  
  
  
  
  
  event TokenCreditWithdrawal(address indexed _job, address indexed _token, address indexed _receiver, uint256 _amount);

  // Errors

  
  error TokenUnallowed();

  
  error JobTokenCreditsLocked();

  
  error InsufficientJobTokenCredits();

  // Variables

  
  
  function jobTokenCreditsAddedAt(address _job, address _token) external view returns (uint256 _timestamp);

  // Methods

  
  
  
  
  function addTokenCreditsToJob(
    address _job,
    address _token,
    uint256 _amount
  ) external;

  
  
  
  
  
  function withdrawTokenCreditsFromJob(
    address _job,
    address _token,
    uint256 _amount,
    address _receiver
  ) external;
}



interface IKeep3rJobFundableLiquidity {
  // Events

  
  
  event LiquidityApproval(address _liquidity);

  
  
  event LiquidityRevocation(address _liquidity);

  
  
  
  
  
  event LiquidityAddition(address indexed _job, address indexed _liquidity, address indexed _provider, uint256 _amount);

  
  
  
  
  
  event LiquidityWithdrawal(address indexed _job, address indexed _liquidity, address indexed _receiver, uint256 _amount);

  
  
  
  
  
  event LiquidityCreditsReward(address indexed _job, uint256 _rewardedAt, uint256 _currentCredits, uint256 _periodCredits);

  
  
  
  
  event LiquidityCreditsForced(address indexed _job, uint256 _rewardedAt, uint256 _currentCredits);

  // Errors

  
  error LiquidityPairApproved();

  
  error LiquidityPairUnexistent();

  
  error LiquidityPairUnapproved();

  
  error JobLiquidityUnexistent();

  
  error JobLiquidityInsufficient();

  
  error JobLiquidityLessThanMin();

  // Structs

  
  struct TickCache {
    int56 current; // Tracks the current tick
    int56 difference; // Stores the difference between the current tick and the last tick
    uint256 period; // Stores the period at which the last observation was made
  }

  // Variables

  
  
  function approvedLiquidities() external view returns (address[] memory _list);

  
  
  
  
  function liquidityAmount(address _job, address _liquidity) external view returns (uint256 _amount);

  
  
  
  function rewardedAt(address _job) external view returns (uint256 _timestamp);

  
  
  
  function workedAt(address _job) external view returns (uint256 _timestamp);

  // Methods

  
  
  
  function jobLiquidityCredits(address _job) external view returns (uint256 _amount);

  
  
  
  function jobPeriodCredits(address _job) external view returns (uint256 _amount);

  
  
  
  function totalJobCredits(address _job) external view returns (uint256 _amount);

  
  
  
  
  
  function quoteLiquidity(address _liquidity, uint256 _amount) external view returns (uint256 _periodCredits);

  
  
  
  function observeLiquidity(address _liquidity) external view returns (TickCache memory _tickCache);

  
  
  
  function forceLiquidityCreditsToJob(address _job, uint256 _amount) external;

  
  
  function approveLiquidity(address _liquidity) external;

  
  
  function revokeLiquidity(address _liquidity) external;

  
  
  
  
  function addLiquidityToJob(
    address _job,
    address _liquidity,
    uint256 _amount
  ) external;

  
  
  
  
  
  function unbondLiquidityFromJob(
    address _job,
    address _liquidity,
    uint256 _amount
  ) external;

  
  
  
  
  function withdrawLiquidityFromJob(
    address _job,
    address _liquidity,
    address _receiver
  ) external;
}

// 
pragma solidity >=0.8.7 <0.9.0;

interface IGovernable {
  event PendingGovernorSet(address _pendingGovernor);

  event PendingGovernorAccepted();

  function setPendingGovernor(address _pendingGovernor) external;

  function acceptPendingGovernor() external;

  function governor() external view returns (address);

  function pendingGovernor() external view returns (address);

  function isGovernor(address _account) external view returns (bool _isGovernor);

  function isPendingGovernor(address _account) external view returns (bool _isPendingGovernor);
}
// 
pragma solidity >=0.8.7 <0.9.0;




interface IDCAKeep3rJob is IGovernable {
  
  struct WorkCall {
    // The actual call to the swapper contract
    bytes swapperCall;
    uint256 nonce;
    uint256 chainId;
    uint256 deadline;
  }

  
  error ZeroAddress();

  
  error SignerCannotSignWork();

  
  error InvalidNonce();

  
  error DeadlineExpired();

  
  error InvalidChainId();

  
  error SwapperCallFailed();

  
  error NotAKeeper();

  
  
  event NewSwapperSet(address newSwapper);

  
  
  
  event ModifiedAddressPermission(address affected, bool canSign);

  
  
  function swapper() external returns (address);

  
  
  function keep3r() external returns (IKeep3rJobs);

  
  
  function canAddressSignWork(address _address) external returns (bool);

  
  
  function nonce() external returns (uint256);

  
  
  
  function setSwapper(address _swapper) external;

  
  
  
  
  function setIfAddressCanSign(address _address, bool _canSign) external;

  
  
  /// NotAKeeper if the caller is not a keep3r
  /// SignerCannotSignWork if the address who signed the message cannot sign work
  /// InvalidNonce if the nonce is invalid
  /// DeadlineExpired if the deadline has expired
  /// InvalidChainId if the chain id is invalid
  /// SwapperCallFailed if the call to the swapper failed
  
  
  function work(bytes calldata _bytes, bytes calldata _signature) external;
}

// 
pragma solidity >=0.8.7 <0.9.0;



abstract contract Governable is IGovernable {
  address private _governor;
  address private _pendingGovernor;

  constructor(address __governor) {
    require(__governor != address(0), 'Governable: zero address');
    _governor = __governor;
  }

  function governor() external view override returns (address) {
    return _governor;
  }

  function pendingGovernor() external view override returns (address) {
    return _pendingGovernor;
  }

  function setPendingGovernor(address __pendingGovernor) external virtual override onlyGovernor {
    _setPendingGovernor(__pendingGovernor);
  }

  function _setPendingGovernor(address __pendingGovernor) internal {
    require(__pendingGovernor != address(0), 'Governable: zero address');
    _pendingGovernor = __pendingGovernor;
    emit PendingGovernorSet(__pendingGovernor);
  }

  function acceptPendingGovernor() external virtual override onlyPendingGovernor {
    _acceptPendingGovernor();
  }

  function _acceptPendingGovernor() internal {
    require(_pendingGovernor != address(0), 'Governable: no pending governor');
    _governor = _pendingGovernor;
    _pendingGovernor = address(0);
    emit PendingGovernorAccepted();
  }

  function isGovernor(address _account) public view override returns (bool _isGovernor) {
    return _account == _governor;
  }

  function isPendingGovernor(address _account) public view override returns (bool _isPendingGovernor) {
    return _account == _pendingGovernor;
  }

  modifier onlyGovernor() {
    require(isGovernor(msg.sender), 'Governable: only governor');
    _;
  }

  modifier onlyPendingGovernor() {
    require(isPendingGovernor(msg.sender), 'Governable: only pending governor');
    _;
  }
}



interface IKeep3rJobManager {
  // Events

  
  
  
  event JobAddition(address indexed _job, address indexed _jobOwner);

  // Errors

  
  error JobAlreadyAdded();

  
  error AlreadyAKeeper();

  // Methods

  
  
  function addJob(address _job) external;
}



interface IKeep3rJobWorkable {
  // Events

  
  
  event KeeperValidation(uint256 _gasLeft);

  
  
  
  
  
  
  event KeeperWork(address indexed _credit, address indexed _job, address indexed _keeper, uint256 _amount, uint256 _gasLeft);

  // Errors

  
  error JobUnapproved();

  
  error InsufficientFunds();

  // Methods

  
  
  
  function isKeeper(address _keeper) external returns (bool _isKeeper);

  
  
  
  
  
  
  
  function isBondedKeeper(
    address _keeper,
    address _bond,
    uint256 _minBond,
    uint256 _earned,
    uint256 _age
  ) external returns (bool _isBondedKeeper);

  
  
  
  function worked(address _keeper) external;

  
  
  
  
  function bondedPayment(address _keeper, uint256 _payment) external;

  
  
  
  
  
  function directTokenPayment(
    address _token,
    address _keeper,
    uint256 _amount
  ) external;
}



interface IKeep3rJobOwnership {
  // Events

  
  
  
  
  event JobOwnershipChange(address indexed _job, address indexed _owner, address indexed _pendingOwner);

  
  
  
  
  event JobOwnershipAssent(address indexed _job, address indexed _previousOwner, address indexed _newOwner);

  // Errors

  
  error OnlyJobOwner();

  
  error OnlyPendingJobOwner();

  // Variables

  
  
  function jobOwner(address _job) external view returns (address _owner);

  
  
  function jobPendingOwner(address _job) external view returns (address _pendingOwner);

  // Methods

  
  function changeJobOwnership(address _job, address _newOwner) external;

  
  function acceptJobOwnership(address _job) external;
}



interface IKeep3rJobMigration {
  // Events

  
  
  
  event JobMigrationRequested(address indexed _fromJob, address _toJob);

  
  
  
  event JobMigrationSuccessful(address _fromJob, address indexed _toJob);

  // Errors

  
  error JobMigrationImpossible();

  
  error JobMigrationUnavailable();

  
  error JobMigrationLocked();

  // Variables

  
  
  function pendingJobMigrations(address _fromJob) external view returns (address _toJob);

  // Methods

  
  
  
  function migrateJob(address _fromJob, address _toJob) external;

  
  
  
  
  function acceptJobMigration(address _fromJob, address _toJob) external;
}



interface IKeep3rJobDisputable is IKeep3rJobFundableCredits, IKeep3rJobFundableLiquidity {
  // Events

  
  
  
  
  
  event JobSlashToken(address indexed _job, address _token, address indexed _slasher, uint256 _amount);

  
  
  
  
  
  event JobSlashLiquidity(address indexed _job, address _liquidity, address indexed _slasher, uint256 _amount);

  // Errors

  
  error JobTokenUnexistent();

  
  error JobTokenInsufficient();

  // Methods

  
  
  
  
  function slashTokenFromJob(
    address _job,
    address _token,
    uint256 _amount
  ) external;

  
  
  
  
  function slashLiquidityFromJob(
    address _job,
    address _liquidity,
    uint256 _amount
  ) external;
}
// 
pragma solidity >=0.8.7 <0.9.0;





contract DCAKeep3rJob is Governable, IDCAKeep3rJob {
  using ECDSA for bytes32;

  IKeep3rJobs public immutable keep3r;
  uint256 public nonce;
  address public swapper;
  mapping(address => bool) public canAddressSignWork;

  constructor(
    address _swapper,
    IKeep3rJobs _keep3r,
    address _governor
  ) Governable(_governor) {
    if (address(_keep3r) == address(0)) revert ZeroAddress();
    if (address(_swapper) != address(0)) swapper = _swapper;
    keep3r = _keep3r;
  }

  function setSwapper(address _swapper) external onlyGovernor {
    if (address(_swapper) == address(0)) revert ZeroAddress();
    swapper = _swapper;
    emit NewSwapperSet(_swapper);
  }

  function setIfAddressCanSign(address _address, bool _canSign) external onlyGovernor {
    if (_address == address(0)) revert ZeroAddress();
    canAddressSignWork[_address] = _canSign;
    emit ModifiedAddressPermission(_address, _canSign);
  }

  function work(bytes calldata _bytes, bytes calldata _signature) external {
    if (!keep3r.isKeeper(msg.sender)) revert NotAKeeper();

    address _signer = keccak256(_bytes).toEthSignedMessageHash().recover(_signature);
    if (!canAddressSignWork[_signer]) revert SignerCannotSignWork();

    WorkCall memory _call = abi.decode(_bytes, (WorkCall));
    if (_call.nonce != nonce++) revert InvalidNonce();
    if (_call.deadline < block.timestamp) revert DeadlineExpired();
    if (_call.chainId != block.chainid) revert InvalidChainId();

    _callSwapper(_call.swapperCall);

    keep3r.worked(msg.sender);
  }

  function _callSwapper(bytes memory _call) internal virtual {
    // solhint-disable-next-line avoid-low-level-calls
    (bool _success, ) = swapper.call(_call);
    if (!_success) revert SwapperCallFailed();
  }
}

// 

pragma solidity ^0.8.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// solhint-disable-next-line no-empty-blocks
interface IKeep3rJobs is IKeep3rJobOwnership, IKeep3rJobDisputable, IKeep3rJobMigration, IKeep3rJobManager, IKeep3rJobWorkable {

}
