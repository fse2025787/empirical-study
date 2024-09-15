
/**
 *Submitted for verification at Etherscan.io on 2019-07-04
*/

// File: contracts/ERC721/ERC721ReceiverDraft.sol

pragma solidity ^0.4.24;




///  ERC721 asset contracts.

///  https://github.com/ethereum/EIPs/commit/2bddd126def7c046e1e62408dc2b51bdd9e57f0f
///  to https://github.com/ethereum/EIPs/commit/27788131d5975daacbab607076f2ee04624f9dbb 
///  and is not the final interface.
///  Due to the extended period of time this revision was specified in the draft,
///  we are supporting both this and the newer (final) interface in order to be 
///  compatible with any ERC721 implementations that may have used this interface.
contract ERC721ReceiverDraft {

    
    ///  Equals to `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`,
    ///  which can be also obtained as `ERC721ReceiverDraft(0).onERC721Received.selector`
    
    bytes4 internal constant ERC721_RECEIVED_DRAFT = 0xf0b9e5ba;

    
    
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. This function MUST use 50,000 gas or less. Return of other
    ///  than the magic value MUST result in the transaction being reverted.
    ///  Note: the contract address is always the message sender.
    
    
    
    
    ///  unless throwing
    function onERC721Received(address _from, uint256 _tokenId, bytes data) external returns(bytes4);
}

// File: contracts/ERC721/ERC721ReceiverFinal.sol

pragma solidity ^0.4.24;




///  ERC721 asset contracts.

contract ERC721ReceiverFinal {

    
    ///  Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`,
    ///  which can be also obtained as `ERC721ReceiverFinal(0).onERC721Received.selector`
    
    bytes4 internal constant ERC721_RECEIVED_FINAL = 0x150b7a02;

    
    
    /// after a `safetransfer`. This function MAY throw to revert and reject the
    /// transfer. Return of other than the magic value MUST result in the
    /// transaction being reverted.
    /// Note: the contract address is always the message sender.
    
    
    
    
    
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes _data
    )
    public
        returns (bytes4);
}

// File: contracts/ERC721/ERC721Receivable.sol

pragma solidity ^0.4.24;




///  See ERC721 specification


///  where no NFTs have been transferred. Since it's not a reliable source of
///  truth about ERC721 tokens being transferred, we save the gas and don't
///  bother emitting a (potentially spurious) event as found in 
///  https://github.com/OpenZeppelin/openzeppelin-solidity/blob/5471fc808a17342d738853d7bf3e9e5ef3108074/contracts/mocks/ERC721ReceiverMock.sol
contract ERC721Receivable is ERC721ReceiverDraft, ERC721ReceiverFinal {

    
    
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. This function MUST use 50,000 gas or less. Return of other
    ///  than the magic value MUST result in the transaction being reverted.
    ///  Note: the contract address is always the message sender.
    
    
    
    
    ///  unless throwing
    function onERC721Received(address _from, uint256 _tokenId, bytes data) external returns(bytes4) {
        _from;
        _tokenId;
        data;

        // emit ERC721Received(_operator, _from, _tokenId, _data, gasleft());

        return ERC721_RECEIVED_DRAFT;
    }

    
    
    /// after a `safetransfer`. This function MAY throw to revert and reject the
    /// transfer. Return of other than the magic value MUST result in the
    /// transaction being reverted.
    /// Note: the contract address is always the message sender.
    
    
    
    
    
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes _data
    )
        public
        returns(bytes4)
    {
        _operator;
        _from;
        _tokenId;
        _data;

        // emit ERC721Received(_operator, _from, _tokenId, _data, gasleft());

        return ERC721_RECEIVED_FINAL;
    }

}

// File: contracts/ERC223/ERC223Receiver.sol

pragma solidity ^0.4.24;




contract ERC223Receiver {
    
    bytes4 public constant ERC223_ID = 0xc0ee0b8a;

    struct TKN {
        address sender;
        uint value;
        bytes data;
        bytes4 sig;
    }
    
    
    
    
    
    function tokenFallback(address _from, uint _value, bytes _data) public pure {
        _from;
        _value;
        _data;
    //   TKN memory tkn;
    //   tkn.sender = _from;
    //   tkn.value = _value;
    //   tkn.data = _data;
    //   uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
    //   tkn.sig = bytes4(u);
      
      /* tkn variable is analogue of msg variable of Ether transaction
      *  tkn.sender is person who initiated this token transaction   (analogue of msg.sender)
      *  tkn.value the number of tokens that were sent   (analogue of msg.value)
      *  tkn.data is data of token transaction   (analogue of msg.data)
      *  tkn.sig is 4 bytes signature of function
      *  if data of token transaction is a function execution
      */

    }
}

// File: contracts/ERC1271/ERC1271.sol

pragma solidity ^0.4.24;

contract ERC1271 {

    
    bytes4 internal constant ERC1271_VALIDSIGNATURE = 0x1626ba7e;

    
    
    
    ///  MUST return the bytes4 magic value 0x1626ba7e when function passes.
    ///  MUST NOT modify state (using STATICCALL for solc < 0.5, view modifier for solc > 0.5)
    ///  MUST allow external calls
    function isValidSignature(
        bytes32 hash, 
        bytes _signature)
        external
        view 
        returns (bytes4);
}

// File: contracts/ECDSA.sol

pragma solidity ^0.4.24;



library ECDSA {

    
    
    
    
    function extractSignature(bytes sigData, uint256 offset) internal pure returns  (bytes32 r, bytes32 s, uint8 v) {
        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solium-disable-next-line security/no-inline-assembly
        assembly {
             let dataPointer := add(sigData, offset)
             r := mload(add(dataPointer, 0x20))
             s := mload(add(dataPointer, 0x40))
             v := byte(0, mload(add(dataPointer, 0x60)))
        }
    
        return (r, s, v);
    }
}

// File: contracts/Wallet/CoreWallet.sol

pragma solidity ^0.4.24;








///  the simplest possible multisig solution, a two-of-two signature scheme. It devolves nicely
///  to "one-of-one" (i.e. singlesig) by simply having the cosigner set to the same value as
///  the main signer.
/// 
///  Most "advanced" functionality (deadman's switch, multiday recovery flows, blacklisting, etc)
///  can be implemented externally to this smart contract, either as an additional smart contract
///  (which can be tracked as a signer without cosigner, or as a cosigner) or as an off-chain flow
///  using a public/private key pair as cosigner. Of course, the basic cosigning functionality could
///  also be implemented in this way, but (A) the complexity and gas cost of two-of-two multisig (as
///  implemented here) is negligable even if you don't need the cosigner functionality, and
///  (B) two-of-two multisig (as implemented here) handles a lot of really common use cases, most
///  notably third-party gas payment and off-chain blacklisting and fraud detection.
contract CoreWallet is ERC721Receivable, ERC223Receiver, ERC1271  {

    using ECDSA for bytes;

    
    ///  See that EIP for more info: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-191.md
    byte public constant EIP191_VERSION_DATA = byte(0);
    byte public constant EIP191_PREFIX = byte(0x19);

    
    string public constant VERSION = "1.0.0";

    
    ///  the authVersion to an address (for lookups in the authorizations mapping)
    ///  by using the '+' operator (which is cheaper than a shift and a mask). See the
    ///  comment on the `authorizations` variable for how this is used.
    uint256 public constant AUTH_VERSION_INCREMENTOR = (1 << 160);
    
    
    ///  shift this value right by 160 bits). Starts as `1 << 160` (`AUTH_VERSION_INCREMENTOR`)
    ///  See the comment on the `authorizations` variable for how this is used.
    uint256 public authVersion;

    
    ///  the assets owned by this wallet.
    ///
    ///  The keys in this mapping are authorized addresses with a version number prepended,
    ///  like so: (authVersion,96)(address,160). The current authVersion MUST BE included
    ///  for each look-up; this allows us to effectively clear the entire mapping of its
    ///  contents merely by incrementing the authVersion variable. (This is important for
    ///  the emergencyRecovery() method.) Inspired by https://ethereum.stackexchange.com/a/42540
    ///
    ///  The values in this mapping are 256bit words, whose lower 20 bytes constitute "cosigners"
    ///  for each address. If an address maps to itself, then that address is said to have no cosigner.
    ///
    ///  The upper 12 bytes are reserved for future meta-data purposes.  The meta-data could refer
    ///  to the key (authorized address) or the value (cosigner) of the mapping.
    ///
    ///  Addresses that map to a non-zero cosigner in the current authVersion are called
    ///  "authorized addresses".
    mapping(uint256 => uint256) public authorizations;

    
    ///  Used for replay prevention. The nonce value in the transaction must exactly equal the current
    ///  nonce value in the wallet for that key. (This mirrors the way Ethereum's transaction nonce works.)
    mapping(address => uint256) public nonces;

    
    ///  resets ALL authorization for this wallet, and must therefore be treated with utmost security.
    ///  Reasonable choices for recoveryAddress include:
    ///       - the address of a private key in cold storage
    ///       - a physically secured hardware wallet
    ///       - a multisig smart contract, possibly with a time-delayed challenge period
    ///       - the zero address, if you like performing without a safety net ;-)
    address public recoveryAddress;

    
    ///  is necessary since it is common for this wallet smart contract to be used as the "library
    ///  code" for an clone contract. See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1167.md
    ///  for more information about clone contracts.
    bool public initialized;
    
    
    modifier onlyRecoveryAddress() {
        require(msg.sender == recoveryAddress, "sender must be recovery address");
        _;
    }

    
    ///  since this contract will often be used as a "clone". (See above.)
    modifier onlyOnce() {
        require(!initialized, "must not already be initialized");
        initialized = true;
        _;
    }
    
    
    ///  In practice, it means that those methods can only be called by a signer/cosigner
    ///  pair that is currently authorized. Theoretically, we could factor out the
    ///  signer/cosigner verification code and use it explicitly in this modifier, but that
    ///  would either result in duplicated code, or additional overhead in the invoke()
    ///  calls (due to the stack manipulation for calling into the shared verification function).
    ///  Doing it this way makes calling the administration functions more expensive (since they
    ///  go through a explict call() instead of just branching within the contract), but it
    ///  makes invoke() more efficient. We assume that invoke() will be used much, much more often
    ///  than any of the administration functions.
    modifier onlyInvoked() {
        require(msg.sender == address(this), "must be called from `invoke()`");
        _;
    }
    
    
    ///  authorized address is removed ("deauthorized"), cosigner will be address(0) in
    ///  this event.
    ///  
    ///  NOTE: When emergencyRecovery() is called, all existing addresses are deauthorized
    ///  WITHOUT Authorized(addr, 0) being emitted. If you are keeping an off-chain mirror of
    ///  authorized addresses, you must also watch for EmergencyRecovery events.
    
    
    
    event Authorized(address authorizedAddress, uint256 cosigner);
    
    
    ///  ALL previously authorized addresses have been deauthorized and the only authorized
    ///  address is the authorizedAddress indicated in this event.
    
    
    
    event EmergencyRecovery(address authorizedAddress, uint256 cosigner);

    
    ///  parameters may be zero.
    
    
    
    event RecoveryAddressChanged(address previousRecoveryAddress, address newRecoveryAddress);

    
    ///  (i.e. This event is not fired if the contract receives ether as part of a method invocation)
    
    
    event Received(address from, uint value);

    
    ///  both simple send ether transactions, as well as other smart contract invocations.
    
    
    
    
    event InvocationSuccess(
        bytes32 hash,
        uint256 result,
        uint256 numOperations
    );

    
    ///  not the clone pattern is being used.
    
    
    
    function init(address _authorizedAddress, uint256 _cosigner, address _recoveryAddress) public onlyOnce {
        require(_authorizedAddress != _recoveryAddress, "Do not use the recovery address as an authorized address.");
        require(address(_cosigner) != _recoveryAddress, "Do not use the recovery address as a cosigner.");
        require(_authorizedAddress != address(0), "Authorized addresses must not be zero.");
        require(address(_cosigner) != address(0), "Initial cosigner must not be zero.");
        
        recoveryAddress = _recoveryAddress;
        // set initial authorization value
        authVersion = AUTH_VERSION_INCREMENTOR;
        // add initial authorized address
        authorizations[authVersion + uint256(_authorizedAddress)] = _cosigner;
        
        emit Authorized(_authorizedAddress, _cosigner);
    }

    
    ///  named functions. In particular, this method is called when we are the target of a simple send transaction
    ///  or when someone tries to call a method that we don't implement. We assume that a "correct" invocation of
    ///  this method only occurs when someone is trying to transfer ether to this wallet, in which case and the
    ///  `msg.data.length` will be 0.
    ///
    ///  NOTE: Some smart contracts send 0 eth as part of a more complex
    ///  operation (-cough- CryptoKitties -cough-) ; ideally, we'd `require(msg.value > 0)` here, but to work
    ///  with those kinds of smart contracts, we accept zero sends and just skip logging in that case.
    function() external payable {
        require(msg.data.length == 0, "Invalid transaction.");
        if (msg.value > 0) {
            emit Received(msg.sender, msg.value);
        }
    }
    
    
    ///   - Add a new signer/cosigner pair (cosigner must be non-zero)
    ///   - Set or change the cosigner for an existing signer (if authorizedAddress != cosigner)
    ///   - Remove the cosigning requirement for a signer (if authorizedAddress == cosigner)
    ///   - Remove a signer (if cosigner == address(0))
    
    
    
    function setAuthorized(address _authorizedAddress, uint256 _cosigner) external onlyInvoked {
        // TODO: Allowing a signer to remove itself is actually pretty terrible; it could result in the user
        //  removing their only available authorized key. Unfortunately, due to how the invocation forwarding
        //  works, we don't actually _know_ which signer was used to call this method, so there's no easy way
        //  to prevent this.
        
        // TODO: Allowing the backup key to be set as an authorized address bypasses the recovery mechanisms.
        //  Dapper can prevent this with offchain logic and the cosigner, but it would be nice to have 
        //  this enforced by the smart contract logic itself.
        
        require(_authorizedAddress != address(0), "Authorized addresses must not be zero.");
        require(_authorizedAddress != recoveryAddress, "Do not use the recovery address as an authorized address.");
        require(address(_cosigner) == address(0) || address(_cosigner) != recoveryAddress, "Do not use the recovery address as a cosigner.");
 
        authorizations[authVersion + uint256(_authorizedAddress)] = _cosigner;
        emit Authorized(_authorizedAddress, _cosigner);
    }
    
    
    ///  a sole new authorized address with optional cosigner. THIS IS A SCORCHED EARTH SOLUTION, and great
    ///  care should be taken to ensure that this method is never called unless it is a last resort. See the
    ///  comments above about the proper kinds of addresses to use as the recoveryAddress to ensure this method
    ///  is not trivially abused.
    
    
    function emergencyRecovery(address _authorizedAddress, uint256 _cosigner) external onlyRecoveryAddress {
        require(_authorizedAddress != address(0), "Authorized addresses must not be zero.");
        require(_authorizedAddress != recoveryAddress, "Do not use the recovery address as an authorized address.");
        require(address(_cosigner) != address(0), "The cosigner must not be zero.");

        // Incrementing the authVersion number effectively erases the authorizations mapping. See the comments
        // on the authorizations variable (above) for more information.
        authVersion += AUTH_VERSION_INCREMENTOR;

        // Store the new signer/cosigner pair as the only remaining authorized address
        authorizations[authVersion + uint256(_authorizedAddress)] = _cosigner;
        emit EmergencyRecovery(_authorizedAddress, _cosigner);
    }

    
    ///  Can be updated by any authorized address. This address should be set with GREAT CARE. See the
    ///  comments above about the proper kinds of addresses to use as the recoveryAddress to ensure this
    ///  mechanism is not trivially abused.
    
    
    function setRecoveryAddress(address _recoveryAddress) external onlyInvoked {
        require(
            address(authorizations[authVersion + uint256(_recoveryAddress)]) == address(0),
            "Do not use an authorized address as the recovery address."
        );
 
        address previous = recoveryAddress;
        recoveryAddress = _recoveryAddress;

        emit RecoveryAddressChanged(previous, recoveryAddress);
    }

    
    ///  a recovery operation. Anyone can call this method to delete the old unused storage and
    ///  get themselves a bit of gas refund in the bargin.
    
    
    
    function recoverGas(uint256 _version, address[] _keys) external {
        // TODO: should this be 0xffffffffffffffffffffffff ?
        require(_version > 0 && _version < 0xffffffff, "Invalid version number.");
        
        uint256 shiftedVersion = _version << 160;

        require(shiftedVersion < authVersion, "You can only recover gas from expired authVersions.");

        for (uint256 i = 0; i < _keys.length; ++i) {
            delete(authorizations[shiftedVersion + uint256(_keys[i])]);
        }
    }

    
    ///  See https://github.com/ethereum/EIPs/issues/1271
    
    ///  MUST return the bytes4 magic value `0x1626ba7e` when function passes.
    ///  MUST NOT modify state (using `STATICCALL` for solc < 0.5, `view` modifier for solc > 0.5)
    ///  MUST allow external calls
    
    ///  the following tightly packed arguments: `0x19,0x0,wallet_address,hash`
    
    
    function isValidSignature(bytes32 hash, bytes _signature) external view returns (bytes4) {
        
        // We 'hash the hash' for the following reasons:
        // 1. `hash` is not the hash of an Ethereum transaction
        // 2. signature must target this wallet to avoid replaying the signature for another wallet
        // with the same key
        // 3. Gnosis does something similar: 
        // https://github.com/gnosis/safe-contracts/blob/102e632d051650b7c4b0a822123f449beaf95aed/contracts/GnosisSafe.sol
        bytes32 operationHash = keccak256(
            abi.encodePacked(
            EIP191_PREFIX,
            EIP191_VERSION_DATA,
            this,
            hash));

        bytes32[2] memory r;
        bytes32[2] memory s;
        uint8[2] memory v;
        address signer;
        address cosigner;

        // extract 1 or 2 signatures depending on length
        if (_signature.length == 65) {
            (r[0], s[0], v[0]) = _signature.extractSignature(0);
            signer = ecrecover(operationHash, v[0], r[0], s[0]);
            cosigner = signer;
        } else if (_signature.length == 130) {
            (r[0], s[0], v[0]) = _signature.extractSignature(0);
            (r[1], s[1], v[1]) = _signature.extractSignature(65);
            signer = ecrecover(operationHash, v[0], r[0], s[0]);
            cosigner = ecrecover(operationHash, v[1], r[1], s[1]);
        } else {
            return 0;
        }
            
        // check for valid signature
        if (signer == address(0)) {
            return 0;
        }

        // check for valid signature
        if (cosigner == address(0)) {
            return 0;
        }

        // check to see if this is an authorized key
        if (address(authorizations[authVersion + uint256(signer)]) != cosigner) {
            return 0;
        }

        return ERC1271_VALIDSIGNATURE;
    }

    
    
    
    ///  uses less than 30,000 gas.
    
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
        // I am not sure why the linter is complaining about the whitespace
        return
            interfaceID == this.supportsInterface.selector || // ERC165
            interfaceID == ERC721_RECEIVED_FINAL || // ERC721 Final
            interfaceID == ERC721_RECEIVED_DRAFT || // ERC721 Draft
            interfaceID == ERC223_ID || // ERC223
            interfaceID == ERC1271_VALIDSIGNATURE; // ERC1271
    }

    
    ///  as both the signer and cosigner. Will only succeed if `msg.sender` is an authorized
    ///  signer for this wallet, with no cosigner, saving transaction size and gas in that case.
    
    function invoke0(bytes data) external {
        // The nonce doesn't need to be incremented for transactions that don't include explicit signatures;
        // the built-in nonce of the native ethereum transaction will protect against replay attacks, and we
        // can save the gas that would be spent updating the nonce variable

        // The operation should be approved if the signer address has no cosigner (i.e. signer == cosigner)
        require(address(authorizations[authVersion + uint256(msg.sender)]) == msg.sender, "Invalid authorization.");

        internalInvoke(0, data);
    }

    
    ///  address. Uses `msg.sender` as the cosigner.
    
    
    
    
    
    ///  between this function and `invoke2()`
    
    function invoke1CosignerSends(uint8 v, bytes32 r, bytes32 s, uint256 nonce, address authorizedAddress, bytes data) external {
        // check signature version
        require(v == 27 || v == 28, "Invalid signature version.");

        // calculate hash
        bytes32 operationHash = keccak256(
            abi.encodePacked(
            EIP191_PREFIX,
            EIP191_VERSION_DATA,
            this,
            nonce,
            authorizedAddress,
            data));
 
        // recover signer
        address signer = ecrecover(operationHash, v, r, s);

        // check for valid signature
        require(signer != address(0), "Invalid signature.");

        // check nonce
        require(nonce == nonces[signer], "must use correct nonce");

        // check signer
        require(signer == authorizedAddress, "authorized addresses must be equal");

        // Get cosigner
        address requiredCosigner = address(authorizations[authVersion + uint256(signer)]);
        
        // The operation should be approved if the signer address has no cosigner (i.e. signer == cosigner) or
        // if the actual cosigner matches the required cosigner.
        require(requiredCosigner == signer || requiredCosigner == msg.sender, "Invalid authorization.");

        // increment nonce to prevent replay attacks
        nonces[signer] = nonce + 1;

        // call internal function
        internalInvoke(operationHash, data);
    }

    
    ///  address. Uses `msg.sender` as the authorized address.
    
    
    
    
    function invoke1SignerSends(uint8 v, bytes32 r, bytes32 s, bytes data) external {
        // check signature version
        // `ecrecover` will infact return 0 if given invalid
        // so perhaps this check is redundant
        require(v == 27 || v == 28, "Invalid signature version.");
        
        uint256 nonce = nonces[msg.sender];

        // calculate hash
        bytes32 operationHash = keccak256(
            abi.encodePacked(
            EIP191_PREFIX,
            EIP191_VERSION_DATA,
            this,
            nonce,
            msg.sender,
            data));
 
        // recover cosigner
        address cosigner = ecrecover(operationHash, v, r, s);
        
        // check for valid signature
        require(cosigner != address(0), "Invalid signature.");

        // Get required cosigner
        address requiredCosigner = address(authorizations[authVersion + uint256(msg.sender)]);
        
        // The operation should be approved if the signer address has no cosigner (i.e. signer == cosigner) or
        // if the actual cosigner matches the required cosigner.
        require(requiredCosigner == cosigner || requiredCosigner == msg.sender, "Invalid authorization.");

        // increment nonce to prevent replay attacks
        nonces[msg.sender] = nonce + 1;
 
        internalInvoke(operationHash, data);
    }

    
    ///  address, the second to derive the cosigner. The value of `msg.sender` is ignored.
    
    
    
    
    
    
    function invoke2(uint8[2] v, bytes32[2] r, bytes32[2] s, uint256 nonce, address authorizedAddress, bytes data) external {
        // check signature versions
        // `ecrecover` will infact return 0 if given invalid
        // so perhaps these checks are redundant
        require(v[0] == 27 || v[0] == 28, "invalid signature version v[0]");
        require(v[1] == 27 || v[1] == 28, "invalid signature version v[1]");
 
        bytes32 operationHash = keccak256(
            abi.encodePacked(
            EIP191_PREFIX,
            EIP191_VERSION_DATA,
            this,
            nonce,
            authorizedAddress,
            data));
 
        // recover signer and cosigner
        address signer = ecrecover(operationHash, v[0], r[0], s[0]);
        address cosigner = ecrecover(operationHash, v[1], r[1], s[1]);

        // check for valid signatures
        require(signer != address(0), "Invalid signature for signer.");
        require(cosigner != address(0), "Invalid signature for cosigner.");

        // check signer address
        require(signer == authorizedAddress, "authorized addresses must be equal");

        // check nonces
        require(nonce == nonces[signer], "must use correct nonce for signer");

        // Get Mapping
        address requiredCosigner = address(authorizations[authVersion + uint256(signer)]);
        
        // The operation should be approved if the signer address has no cosigner (i.e. signer == cosigner) or
        // if the actual cosigner matches the required cosigner.
        require(requiredCosigner == signer || requiredCosigner == cosigner, "Invalid authorization.");

        // increment nonce to prevent replay attacks
        nonces[signer]++;

        internalInvoke(operationHash, data);
    }

    
    
    
    ///  The data is prefixed with a global 1 byte revert flag
    ///  If revert is 1, then any revert from a `call()` operation is rethrown.
    ///  Otherwise, the error is recorded in the `result` field of the `InvocationSuccess` event.
    ///  Immediately following the revert byte (no padding), the data format is then is a series
    ///  of 1 or more tightly packed tuples:
    ///  `<target(20),amount(32),datalength(32),data>`
    ///  If `datalength == 0`, the data field must be omitted
    function internalInvoke(bytes32 operationHash, bytes data) internal {
        // keep track of the number of operations processed
        uint256 numOps;
        // keep track of the result of each operation as a bit
        uint256 result;

        // We need to store a reference to this string as a variable so we can use it as an argument to
        // the revert call from assembly.
        string memory invalidLengthMessage = "Data field too short";
        string memory callFailed = "Call failed";

        // At an absolute minimum, the data field must be at least 85 bytes
        // <revert(1), to_address(20), value(32), data_length(32)>
        require(data.length >= 85, invalidLengthMessage);

        // Forward the call onto its actual target. Note that the target address can be `self` here, which is
        // actually the required flow for modifying the configuration of the authorized keys and recovery address.
        //
        // The assembly code below loads data directly from memory, so the enclosing function must be marked `internal`
        assembly {
            // A cursor pointing to the revert flag, starts after the length field of the data object
            let memPtr := add(data, 32)

            // The revert flag is the leftmost byte from memPtr
            let revertFlag := byte(0, mload(memPtr))

            // A pointer to the end of the data object
            let endPtr := add(memPtr, mload(data))

            // Now, memPtr is a cursor pointing to the begining of the current sub-operation
            memPtr := add(memPtr, 1)

            // Loop through data, parsing out the various sub-operations
            for { } lt(memPtr, endPtr) { } {
                // Load the length of the call data of the current operation
                // 52 = to(20) + value(32)
                let len := mload(add(memPtr, 52))
                
                // Compute a pointer to the end of the current operation
                // 84 = to(20) + value(32) + size(32)
                let opEnd := add(len, add(memPtr, 84))

                // Bail if the current operation's data overruns the end of the enclosing data buffer
                // NOTE: Comment out this bit of code and uncomment the next section if you want
                // the solidity-coverage tool to work.
                // See https://github.com/sc-forks/solidity-coverage/issues/287
                if gt(opEnd, endPtr) {
                    // The computed end of this operation goes past the end of the data buffer. Not good!
                    revert(add(invalidLengthMessage, 32), mload(invalidLengthMessage))
                }
                // NOTE: Code that is compatible with solidity-coverage
                // switch gt(opEnd, endPtr)
                // case 1 {
                //     revert(add(invalidLengthMessage, 32), mload(invalidLengthMessage))
                // }

                // This line of code packs in a lot of functionality!
                //  - load the target address from memPtr, the address is only 20-bytes but mload always grabs 32-bytes,
                //    so we have to divide the result by 2^96 to effectively right-shift by 12 bytes.
                //  - load the value field, stored at memPtr+20
                //  - pass a pointer to the call data, stored at memPtr+84
                //  - use the previously loaded len field as the size of the call data
                //  - make the call (passing all remaining gas to the child call)
                //  - check the result (0 == reverted)
                if eq(0, call(gas, div(mload(memPtr), exp(2, 96)), mload(add(memPtr, 20)), add(memPtr, 84), len, 0, 0)) {
                    
                    switch revertFlag
                    case 1 {
                        revert(add(callFailed, 32), mload(callFailed))
                    }
                    default {
                        // mark this operation as failed
                        // create the appropriate bit, 'or' with previous
                        result := or(result, exp(2, numOps))
                    }
                }

                // increment our counter
                numOps := add(numOps, 1)
             
                // Update mem pointer to point to the next sub-operation
                memPtr := opEnd
            }
        }

        // emit single event upon success
        emit InvocationSuccess(operationHash, result, numOps);
    }
}

// File: contracts/Wallet/CloneableWallet.sol

pragma solidity ^0.4.24;





///  It is meant to be deployed and serve as the contract that you clone
///  in an EIP 1167 clone setup.


///  the clone wallet; use `FullWallet` if you think users will overtake
///  the transaction threshold over the lifetime of the wallet.
contract CloneableWallet is CoreWallet {

    
    ///  of `CoreWallet`
    constructor () public {
        initialized = true;
    }
}

// File: contracts/Wallet/FullWallet.sol

pragma solidity ^0.4.24;





///  the full code and not a clone shim
contract FullWallet is CoreWallet {

    
    ///  smart contract wallet. Useful if you anticipate that the lifetime gas savings of being able to call
    ///  this contract directly will outweigh the cost of deploying a complete copy of this contract.
    ///  Comment out this constructor and use the one above if you wish to save gas deployment costs by
    ///  using a clonable instance.
    
    
    
    constructor (address _authorized, uint256 _cosigner, address _recoveryAddress) public {
        init(_authorized, _cosigner, _recoveryAddress);
    }
}

// File: contracts/Ownership/Ownable.sol

pragma solidity ^0.4.24;




///  and provides basic authorization functions.
contract Ownable {

    
    address public owner;

    
    ///  as the owner.
    
    event OwnershipRenounced(address indexed previousOwner);
    
    
    
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor() public {
        owner = msg.sender;
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner, "must be owner");
        _;
    }

    
    function renounceOwnership() external onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    
    
    function transferOwnership(address _newOwner) external onlyOwner {
        _transferOwnership(_newOwner);
    }

    
    
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0), "cannot renounce ownership");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

// File: contracts/Ownership/HasNoEther.sol

pragma solidity ^0.4.24;




contract HasNoEther is Ownable {

    
    constructor() public payable {
        require(msg.value == 0, "must not send Ether");
    }

    
    function() external {}

    
    function reclaimEther() external onlyOwner {
        owner.transfer(address(this).balance);
    }
}

// File: contracts/WalletFactory/CloneFactory.sol

pragma solidity ^0.4.24;





contract CloneFactory {
    event CloneCreated(address indexed target, address clone);

    function createClone(address target) internal returns (address result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            result := create(0, clone, 0x37)
        }
    }
}

// File: contracts/WalletFactory/WalletFactory.sol

pragma solidity ^0.4.24;







contract WalletFactory is HasNoEther, CloneFactory {
    
    ///  deployment contains all the Wallet code.
    address public cloneWalletAddress;

    
    
    
    
    ///  contained wallet; `false` if the wallet is a clone wallet
    event WalletCreated(address wallet, address authorizedAddress, bool full);

    constructor(address _cloneWalletAddress) public {
        cloneWalletAddress = _cloneWalletAddress;
    }

    
    
    
    function setCloneWalletAddress(address _newCloneWalletAddress) public onlyOwner {
        cloneWalletAddress = _newCloneWalletAddress;
    }

    
    
    
    
    
    function deployCloneWallet(
        address _recoveryAddress,
        address _authorizedAddress,
        uint256 _cosigner
    )
        public 
    {
        address clone = createClone(cloneWalletAddress);
        CloneableWallet(clone).init(_authorizedAddress, _cosigner, _recoveryAddress);
        emit WalletCreated(clone, _authorizedAddress, false);
    }

    
    
    
    
    
    function deployFullWallet(
        address _recoveryAddress,
        address _authorizedAddress,
        uint256 _cosigner
    )
        public 
    {
        address full = new FullWallet(_authorizedAddress, _cosigner, _recoveryAddress);
        emit WalletCreated(full, _authorizedAddress, true);
    }
}