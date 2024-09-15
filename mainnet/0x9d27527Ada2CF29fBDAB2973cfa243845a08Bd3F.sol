// SPDX-License-Identifier: MIT


// 

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// 

pragma solidity ^0.8.0;



/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// 
pragma solidity 0.8.9;






abstract contract ERC721Base is IERC165, IERC721 {
    using Address for address;

    bytes4 internal constant ERC721_RECEIVED = 0x150b7a02;
    bytes4 internal constant ERC165ID = 0x01ffc9a7;

    uint256 internal constant OPERATOR_FLAG = 0x8000000000000000000000000000000000000000000000000000000000000000;
    uint256 internal constant NOT_OPERATOR_FLAG = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    mapping(uint256 => uint256) internal _owners;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => bool)) internal _operatorsForAll;
    mapping(uint256 => address) internal _operators;

    function name() public pure virtual returns (string memory) {
        revert("NOT_IMPLEMENTED");
    }

    
    
    
    function approve(address operator, uint256 id) external override {
        (address owner, uint256 blockNumber) = _ownerAndBlockNumberOf(id);
        require(owner != address(0), "NONEXISTENT_TOKEN");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "UNAUTHORIZED_APPROVAL");
        _approveFor(owner, blockNumber, operator, id);
    }

    
    
    
    
    function transferFrom(
        address from,
        address to,
        uint256 id
    ) external override {
        (address owner, bool operatorEnabled) = _ownerAndOperatorEnabledOf(id);
        require(owner != address(0), "NONEXISTENT_TOKEN");
        require(owner == from, "NOT_OWNER");
        require(to != address(0), "NOT_TO_ZEROADDRESS");
        require(to != address(this), "NOT_TO_THIS");
        if (msg.sender != from) {
            require(
                (operatorEnabled && _operators[id] == msg.sender) || isApprovedForAll(from, msg.sender),
                "UNAUTHORIZED_TRANSFER"
            );
        }
        _transferFrom(from, to, id);
    }

    
    
    
    
    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) external override {
        safeTransferFrom(from, to, id, "");
    }

    
    
    
    function setApprovalForAll(address operator, bool approved) external override {
        _setApprovalForAll(msg.sender, operator, approved);
    }

    
    
    
    function balanceOf(address owner) public view override returns (uint256 balance) {
        require(owner != address(0), "ZERO_ADDRESS_OWNER");
        balance = _balances[owner];
    }

    
    
    
    function ownerOf(uint256 id) external view override returns (address owner) {
        owner = _ownerOf(id);
        require(owner != address(0), "NONEXISTENT_TOKEN");
    }

    
    
    
    
    function ownerAndLastTransferBlockNumberOf(uint256 id) internal view returns (address owner, uint256 blockNumber) {
        return _ownerAndBlockNumberOf(id);
    }

    struct OwnerData {
        address owner;
        uint256 lastTransferBlockNumber;
    }

    
    
    
    function ownerAndLastTransferBlockNumberList(uint256[] calldata ids)
        external
        view
        returns (OwnerData[] memory ownersData)
    {
        ownersData = new OwnerData[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            uint256 data = _owners[ids[i]];
            ownersData[i].owner = address(uint160(data));
            ownersData[i].lastTransferBlockNumber = (data >> 160) & 0xFFFFFFFFFFFFFFFFFFFFFF;
        }
    }

    
    
    
    function getApproved(uint256 id) external view override returns (address) {
        (address owner, bool operatorEnabled) = _ownerAndOperatorEnabledOf(id);
        require(owner != address(0), "NONEXISTENT_TOKEN");
        if (operatorEnabled) {
            return _operators[id];
        } else {
            return address(0);
        }
    }

    
    
    
    
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool isOperator) {
        return _operatorsForAll[owner][operator];
    }

    
    
    
    
    
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) public override {
        (address owner, bool operatorEnabled) = _ownerAndOperatorEnabledOf(id);
        require(owner != address(0), "NONEXISTENT_TOKEN");
        require(owner == from, "NOT_OWNER");
        require(to != address(0), "NOT_TO_ZEROADDRESS");
        require(to != address(this), "NOT_TO_THIS");
        if (msg.sender != from) {
            require(
                (operatorEnabled && _operators[id] == msg.sender) || isApprovedForAll(from, msg.sender),
                "UNAUTHORIZED_TRANSFER"
            );
        }
        _safeTransferFrom(from, to, id, data);
    }

    
    
    
    function supportsInterface(bytes4 id) public pure virtual override returns (bool) {
        /// 0x01ffc9a7 is ERC165.
        /// 0x80ac58cd is ERC721
        /// 0x5b5e139f is for ERC721 metadata
        return id == 0x01ffc9a7 || id == 0x80ac58cd || id == 0x5b5e139f;
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) internal {
        _transferFrom(from, to, id);
        if (to.isContract()) {
            require(_checkOnERC721Received(msg.sender, from, to, id, data), "ERC721_TRANSFER_REJECTED");
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 id
    ) internal virtual {}

    function _transferFrom(
        address from,
        address to,
        uint256 id
    ) internal {
        _beforeTokenTransfer(from, to, id);
        unchecked {
            _balances[to]++;
            if (from != address(0)) {
                _balances[from]--;
            }
        }
        _owners[id] = (block.number << 160) | uint256(uint160(to));
        emit Transfer(from, to, id);
    }

    
    function _approveFor(
        address owner,
        uint256 blockNumber,
        address operator,
        uint256 id
    ) internal {
        if (operator == address(0)) {
            _owners[id] = (blockNumber << 160) | uint256(uint160(owner));
        } else {
            _owners[id] = OPERATOR_FLAG | (blockNumber << 160) | uint256(uint160(owner));
            _operators[id] = operator;
        }
        emit Approval(owner, operator, id);
    }

    
    function _setApprovalForAll(
        address sender,
        address operator,
        bool approved
    ) internal {
        _operatorsForAll[sender][operator] = approved;

        emit ApprovalForAll(sender, operator, approved);
    }

    
    
    
    
    
    
    
    function _checkOnERC721Received(
        address operator,
        address from,
        address to,
        uint256 id,
        bytes memory _data
    ) internal returns (bool) {
        bytes4 retval = IERC721Receiver(to).onERC721Received(operator, from, id, _data);
        return (retval == ERC721_RECEIVED);
    }

    
    function _ownerOf(uint256 id) internal view returns (address owner) {
        return address(uint160(_owners[id]));
    }

    
    
    
    
    function _ownerAndOperatorEnabledOf(uint256 id) internal view returns (address owner, bool operatorEnabled) {
        uint256 data = _owners[id];
        owner = address(uint160(data));
        operatorEnabled = (data & OPERATOR_FLAG) == OPERATOR_FLAG;
    }

    // @dev Get the owner and operatorEnabled status of a token.
    
    
    
    function _ownerAndBlockNumberOf(uint256 id) internal view returns (address owner, uint256 blockNumber) {
        uint256 data = _owners[id];
        owner = address(uint160(data));
        blockNumber = (data >> 160) & 0xFFFFFFFFFFFFFFFFFFFFFF;
    }

    // from https://github.com/Uniswap/v3-periphery/blob/main/contracts/base/Multicall.sol
    
    
    
    
    function multicall(bytes[] calldata data) public payable returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            if (!success) {
                // Next 5 lines from https://ethereum.stackexchange.com/a/83577
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            results[i] = result;
        }
    }
}

// 
pragma solidity 0.8.9;






abstract contract ERC721BaseWithERC4494Permit is ERC721Base {
    using Address for address;

    bytes32 public constant PERMIT_TYPEHASH =
        keccak256("Permit(address spender,uint256 tokenId,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_FOR_ALL_TYPEHASH =
        keccak256("PermitForAll(address spender,uint256 nonce,uint256 deadline)");
    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    uint256 private immutable _deploymentChainId;
    bytes32 private immutable _deploymentDomainSeparator;

    mapping(address => uint256) internal _userNonces;

    constructor() {
        uint256 chainId;
        //solhint-disable-next-line no-inline-assembly
        assembly {
            chainId := chainid()
        }
        _deploymentChainId = chainId;
        _deploymentDomainSeparator = _calculateDomainSeparator(chainId);
    }

    
    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return _DOMAIN_SEPARATOR();
    }

    
    
    
    function nonces(address account) external view virtual returns (uint256 nonce) {
        return _userNonces[account];
    }

    
    
    
    function nonces(uint256 id) public view virtual returns (uint256 nonce) {
        (address owner, uint256 blockNumber) = _ownerAndBlockNumberOf(id);
        require(owner != address(0), "NONEXISTENT_TOKEN");
        return blockNumber;
    }

    
    
    
    function tokenNonces(uint256 id) external view returns (uint256 nonce) {
        return nonces(id);
    }

    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        bytes memory sig
    ) external {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        (address owner, uint256 blockNumber) = _ownerAndBlockNumberOf(tokenId);
        require(owner != address(0), "NONEXISTENT_TOKEN");

        // We use blockNumber as nonce as we already store it per tokens. It can thus act as an increasing transfer counter.
        // while technically multiple transfer could happen in the same block, the signed message would be using a previous block.
        // And the transfer would use then a more recent blockNumber, invalidating that message when transfer is executed.
        _requireValidPermit(owner, spender, tokenId, deadline, blockNumber, sig);

        _approveFor(owner, blockNumber, spender, tokenId);
    }

    function permitForAll(
        address signer,
        address spender,
        uint256 deadline,
        bytes memory sig
    ) external {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        _requireValidPermitForAll(signer, spender, deadline, _userNonces[signer]++, sig);

        _setApprovalForAll(signer, spender, true);
    }

    
    
    
    function supportsInterface(bytes4 id) public pure virtual override returns (bool) {
        return
            super.supportsInterface(id) ||
            id == type(IERC4494).interfaceId ||
            id == type(IERC4494Alternative).interfaceId;
    }

    // -------------------------------------------------------- INTERNAL --------------------------------------------------------------------

    function _requireValidPermit(
        address signer,
        address spender,
        uint256 id,
        uint256 deadline,
        uint256 nonce,
        bytes memory sig
    ) internal view {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                _DOMAIN_SEPARATOR(),
                keccak256(abi.encode(PERMIT_TYPEHASH, spender, id, nonce, deadline))
            )
        );
        require(SignatureChecker.isValidSignatureNow(signer, digest, sig), "INVALID_SIGNATURE");
    }

    function _requireValidPermitForAll(
        address signer,
        address spender,
        uint256 deadline,
        uint256 nonce,
        bytes memory sig
    ) internal view {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                _DOMAIN_SEPARATOR(),
                keccak256(abi.encode(PERMIT_FOR_ALL_TYPEHASH, spender, nonce, deadline))
            )
        );
        require(SignatureChecker.isValidSignatureNow(signer, digest, sig), "INVALID_SIGNATURE");
    }

    
    function _DOMAIN_SEPARATOR() internal view returns (bytes32) {
        uint256 chainId;
        //solhint-disable-next-line no-inline-assembly
        assembly {
            chainId := chainid()
        }

        // in case a fork happen, to support the chain that had to change its chainId,, we compute the domain operator
        return chainId == _deploymentChainId ? _deploymentDomainSeparator : _calculateDomainSeparator(chainId);
    }

    
    function _calculateDomainSeparator(uint256 chainId) private view returns (bytes32) {
        return keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name())), chainId, address(this)));
    }
}

// 



/*********************************
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░██░░░████░░██░░░████░░░ *
 * ░░██████░░░████████░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 *********************************/

// LICENSE
// ERC721Checkpointable.sol uses and modifies part of Compound Lab's Comp.sol:
// https://github.com/compound-finance/compound-protocol/blob/ae4388e780a8d596d97619d9704a931a2752c2bc/contracts/Governance/Comp.sol
//
// Comp.sol source code Copyright 2020 Compound Labs, Inc. licensed under the BSD-3-Clause license.
// With modifications by Nounders DAO.
//
// Additional conditions of BSD-3-Clause can be found here: https://opensource.org/licenses/BSD-3-Clause
//
// MODIFICATIONS
// Checkpointing logic from Comp.sol has been used with the following modifications:
// - `delegates` is renamed to `_delegates` and is set to private
// - `delegates` is a public function that uses the `_delegates` mapping look-up, but unlike
//   Comp.sol, returns the delegator's own address if there is no delegate.
//   This avoids the delegator needing to "delegate to self" with an additional transaction
// - `_transferTokens()` is renamed `_beforeTokenTransfer()` and adapted to hook into OpenZeppelin's ERC721 hooks.

pragma solidity 0.8.9;



abstract contract ERC721Checkpointable is ERC721BaseWithERC4494Permit {
    bool internal _useCheckpoints = true; // can only be disabled and never re-enabled

    
    uint8 public constant decimals = 0;

    
    mapping(address => address) private _delegates;

    
    struct Checkpoint {
        uint32 fromBlock;
        uint96 votes;
    }

    
    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

    
    mapping(address => uint32) public numCheckpoints;

    
    bytes32 public constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    /**
     * @notice The votes a delegator can delegate, which is the current balance of the delegator.
     * @dev Used when calling `_delegate()`
     */
    function votesToDelegate(address delegator) public view returns (uint96) {
        return safe96(balanceOf(delegator), "ERC721Checkpointable::votesToDelegate: amount exceeds 96 bits");
    }

    /**
     * @notice Overrides the standard `Comp.sol` delegates mapping to return
     * the delegator's own address if they haven't delegated.
     * This avoids having to delegate to oneself.
     */
    function delegates(address delegator) public view returns (address) {
        address current = _delegates[delegator];
        return current == address(0) ? delegator : current;
    }

    /**
     * @notice Adapted from `_transferTokens()` in `Comp.sol` to update delegate votes.
     * @dev hooks into ERC721Base's `ERC721._transfer`
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        super._beforeTokenTransfer(from, to, tokenId);
        if (_useCheckpoints) {
            
            _moveDelegates(delegates(from), delegates(to), 1);
        }
    }

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegatee The address to delegate votes to
     */
    function delegate(address delegatee) public {
        if (delegatee == address(0)) delegatee = msg.sender;
        return _delegate(msg.sender, delegatee);
    }

    /**
     * @notice Delegates votes from signatory to `delegatee`
     * @param delegatee The address to delegate votes to
     * @param nonce The contract state required to match the signature
     * @param expiry The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                _DOMAIN_SEPARATOR(),
                keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry))
            )
        );
        // TODO support smart contract wallet via IERC721, require change in function signature to know which signer to call first
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "ERC721Checkpointable::delegateBySig: invalid signature");
        require(nonce == _userNonces[signatory]++, "ERC721Checkpointable::delegateBySig: invalid nonce");
        require(block.timestamp <= expiry, "ERC721Checkpointable::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getCurrentVotes(address account) public view returns (uint96) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getVotes(address account) external view returns (uint96) {
        return getCurrentVotes(account);
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint256 blockNumber) public view returns (uint96) {
        require(blockNumber < block.number, "ERC721Checkpointable::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPastVotes(address account, uint256 blockNumber) external view returns (uint96) {
        return this.getPriorVotes(account, blockNumber);
    }

    function _delegate(address delegator, address delegatee) internal {
        
        address currentDelegate = delegates(delegator);

        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        uint96 amount = votesToDelegate(delegator);

        _moveDelegates(currentDelegate, delegatee, amount);
    }

    function _moveDelegates(
        address srcRep,
        address dstRep,
        uint96 amount
    ) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint96 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint96 srcRepNew = sub96(srcRepOld, amount, "ERC721Checkpointable::_moveDelegates: amount underflows");
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint96 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint96 dstRepNew = add96(dstRepOld, amount, "ERC721Checkpointable::_moveDelegates: amount overflows");
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint96 oldVotes,
        uint96 newVotes
    ) internal {
        uint32 blockNumber = safe32(
            block.number,
            "ERC721Checkpointable::_writeCheckpoint: block number exceeds 32 bits"
        );

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function safe96(uint256 n, string memory errorMessage) internal pure returns (uint96) {
        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function add96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {
        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {
        require(b <= a, errorMessage);
        return a - b;
    }
}

abstract contract WithSupportForOpenSeaProxies {
    address internal immutable _proxyRegistryAddress;

    constructor(address proxyRegistryAddress) {
        _proxyRegistryAddress = proxyRegistryAddress;
    }

    function _isOpenSeaProxy(address owner, address operator) internal view returns (bool) {
        if (_proxyRegistryAddress == address(0)) {
            return false;
        }
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(_proxyRegistryAddress);
        return address(proxyRegistry.proxies(owner)) == operator;
    }
}

contract BleepsRoles {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event TokenURIAdminSet(address newTokenURIAdmin);
    event RoyaltyAdminSet(address newRoyaltyAdmin);
    event MinterAdminSet(address newMinterAdmin);
    event GuardianSet(address newGuardian);
    event MinterSet(address newMinter);

    bytes32 internal constant ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;
    ENS internal immutable _ens;

    
    address public owner;

    
    address public tokenURIAdmin;

    
    address public royaltyAdmin;

    
    /// could be given to the DAO later so instrument can be added, the sale of these new bleeps could benenfit the DAO too and add new members.
    address public minterAdmin;

    
    /// Once all 1024 potential bleeps (there could be less, at minimum there are 576 bleeps) are minted, no minter can mint anymore
    address public minter;

    
    /// For example: the royalty setup could be frozen.
    address public guardian;

    constructor(
        address ens,
        address initialOwner,
        address initialTokenURIAdmin,
        address initialMinterAdmin,
        address initialRoyaltyAdmin,
        address initialGuardian
    ) {
        _ens = ENS(ens);
        owner = initialOwner;
        tokenURIAdmin = initialTokenURIAdmin;
        royaltyAdmin = initialRoyaltyAdmin;
        minterAdmin = initialMinterAdmin;
        guardian = initialGuardian;
        emit OwnershipTransferred(address(0), initialOwner);
        emit TokenURIAdminSet(initialTokenURIAdmin);
        emit RoyaltyAdminSet(initialRoyaltyAdmin);
        emit MinterAdminSet(initialMinterAdmin);
        emit GuardianSet(initialGuardian);
    }

    function setENSName(string memory name) external {
        require(msg.sender == owner, "NOT_AUTHORIZED");
        ReverseRegistrar reverseRegistrar = ReverseRegistrar(_ens.owner(ADDR_REVERSE_NODE));
        reverseRegistrar.setName(name);
    }

    function withdrawERC20(IERC20 token, address to) external {
        require(msg.sender == owner, "NOT_AUTHORIZED");
        token.transfer(to, token.balanceOf(address(this)));
    }

    /**
     * @notice Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external {
        address oldOwner = owner;
        require(msg.sender == oldOwner);
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @notice set the new tokenURIAdmin that can change the tokenURI
     * Can only be called by the current tokenURI admin.
     */
    function setTokenURIAdmin(address newTokenURIAdmin) external {
        require(
            msg.sender == tokenURIAdmin || (msg.sender == guardian && newTokenURIAdmin == address(0)),
            "NOT_AUTHORIZED"
        );
        tokenURIAdmin = newTokenURIAdmin;
        emit TokenURIAdminSet(newTokenURIAdmin);
    }

    /**
     * @notice set the new royaltyAdmin that can change the royalties
     * Can only be called by the current royalty admin.
     */
    function setRoyaltyAdmin(address newRoyaltyAdmin) external {
        require(
            msg.sender == royaltyAdmin || (msg.sender == guardian && newRoyaltyAdmin == address(0)),
            "NOT_AUTHORIZED"
        );
        royaltyAdmin = newRoyaltyAdmin;
        emit RoyaltyAdminSet(newRoyaltyAdmin);
    }

    /**
     * @notice set the new minterAdmin that can set the minter for Bleeps
     * Can only be called by the current minter admin.
     */
    function setMinterAdmin(address newMinterAdmin) external {
        require(
            msg.sender == minterAdmin || (msg.sender == guardian && newMinterAdmin == address(0)),
            "NOT_AUTHORIZED"
        );
        minterAdmin = newMinterAdmin;
        emit MinterAdminSet(newMinterAdmin);
    }

    /**
     * @notice set the new guardian that can freeze the other admins (except owner).
     * Can only be called by the current guardian.
     */
    function setGuardian(address newGuardian) external {
        require(msg.sender == guardian, "NOT_AUTHORIZED");
        guardian = newGuardian;
        emit GuardianSet(newGuardian);
    }

    /**
     * @notice set the new minter that can mint Bleeps (up to 1024).
     * Can only be called by the minter admin.
     */
    function setMinter(address newMinter) external {
        require(msg.sender == minterAdmin, "NOT_AUTHORIZED");
        minter = newMinter;
        emit MinterSet(newMinter);
    }
}
// 

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 *
 * _Available since v4.1._
 */
interface IERC1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}

// 

pragma solidity ^0.8.0;



// 

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

// 

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// 

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
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

// 

pragma solidity ^0.8.0;





/**
 * @dev Signature verification helper: Provide a single mechanism to verify both private-key (EOA) ECDSA signature and
 * ERC1271 contract sigantures. Using this instead of ECDSA.recover in your contract will make them compatible with
 * smart contract wallets such as Argent and Gnosis.
 *
 * Note: unlike ECDSA signatures, contract signature's are revocable, and the outcome of this function can thus change
 * through time. It could return true at block N and false at block N+1 (or the opposite).
 *
 * _Available since v4.1._
 */
library SignatureChecker {
    function isValidSignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool) {
        (address recovered, ECDSA.RecoverError error) = ECDSA.tryRecover(hash, signature);
        if (error == ECDSA.RecoverError.NoError && recovered == signer) {
            return true;
        }

        (bool success, bytes memory result) = signer.staticcall(
            abi.encodeWithSelector(IERC1271.isValidSignature.selector, hash, signature)
        );
        return (success && result.length == 32 && abi.decode(result, (bytes4)) == IERC1271.isValidSignature.selector);
    }
}

// 
pragma solidity 0.8.9;

interface IERC4494 {
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    
    
    
    function nonces(uint256 tokenId) external view returns (uint256);

    
    
    
    
    
    
    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        bytes memory signature
    ) external;
}

interface IERC4494Alternative {
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    
    
    
    function tokenNonces(uint256 tokenId) external view returns (uint256);

    
    
    
    
    
    
    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        bytes memory signature
    ) external;
}

// 
pragma solidity 0.8.9;

contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

// 
pragma solidity 0.8.9;









contract Bleeps is IERC721, WithSupportForOpenSeaProxies, ERC721Checkpointable, BleepsRoles {
    event RoyaltySet(address receiver, uint256 royaltyPer10Thousands);
    event TokenURIContractSet(ITokenURI newTokenURIContract);
    event CheckpointingDisablerSet(address newCheckpointingDisabler);
    event CheckpointingDisabled();

    
    ITokenURI public tokenURIContract;

    struct Royalty {
        address receiver;
        uint96 per10Thousands;
    }

    Royalty internal _royalty;

    
    address public checkpointingDisabler;

    
    
    
    
    
    
    
    
    
    
    
    
    constructor(
        address ens,
        address initialOwner,
        address initialTokenURIAdmin,
        address initialMinterAdmin,
        address initialRoyaltyAdmin,
        address initialGuardian,
        address openseaProxyRegistry,
        address initialRoyaltyReceiver,
        uint96 imitialRoyaltyPer10Thousands,
        ITokenURI initialTokenURIContract,
        address initialCheckpointingDisabler
    )
        WithSupportForOpenSeaProxies(openseaProxyRegistry)
        BleepsRoles(ens, initialOwner, initialTokenURIAdmin, initialMinterAdmin, initialRoyaltyAdmin, initialGuardian)
    {
        tokenURIContract = initialTokenURIContract;
        emit TokenURIContractSet(initialTokenURIContract);
        checkpointingDisabler = initialCheckpointingDisabler;
        emit CheckpointingDisablerSet(initialCheckpointingDisabler);

        _royalty.receiver = initialRoyaltyReceiver;
        _royalty.per10Thousands = imitialRoyaltyPer10Thousands;
        emit RoyaltySet(initialRoyaltyReceiver, imitialRoyaltyPer10Thousands);
    }

    
    function name() public pure override returns (string memory) {
        return "Bleeps";
    }

    
    function symbol() external pure returns (string memory) {
        return "BLEEP";
    }

    
    function contractURI() external view returns (string memory) {
        return tokenURIContract.contractURI(_royalty.receiver, _royalty.per10Thousands);
    }

    
    function tokenURI(uint256 id) external view returns (string memory) {
        return tokenURIContract.tokenURI(id);
    }

    
    
    function setTokenURIContract(ITokenURI newTokenURIContract) external {
        require(msg.sender == tokenURIAdmin, "NOT_AUTHORIZED");
        tokenURIContract = newTokenURIContract;
        emit TokenURIContractSet(newTokenURIContract);
    }

    
    
    
    function owners(uint256[] calldata ids) external view returns (address[] memory addresses) {
        addresses = new address[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            addresses[i] = address(uint160(_owners[id]));
        }
    }

    
    
    
    
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override(ERC721Base, IERC721)
        returns (bool isOperator)
    {
        return super.isApprovedForAll(owner, operator) || _isOpenSeaProxy(owner, operator);
    }

    
    
    
    function supportsInterface(bytes4 id)
        public
        pure
        virtual
        override(ERC721BaseWithERC4494Permit, IERC165)
        returns (bool)
    {
        return super.supportsInterface(id) || id == 0x2a55205a; /// 0x2a55205a is ERC2981 (royalty standard)
    }

    
    
    
    
    
    function royaltyInfo(uint256 id, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = _royalty.receiver;
        royaltyAmount = (salePrice * uint256(_royalty.per10Thousands)) / 10000;
    }

    
    
    
    function setRoyaltyParameters(address newReceiver, uint96 royaltyPer10Thousands) external {
        require(msg.sender == royaltyAdmin, "NOT_AUTHORIZED");
        // require(royaltyPer10Thousands <= 50, "ROYALTY_TOO_HIGH"); ?
        _royalty.receiver = newReceiver;
        _royalty.per10Thousands = royaltyPer10Thousands;
        emit RoyaltySet(newReceiver, royaltyPer10Thousands);
    }

    
    /// This can be used if the governance system can switch to use ownerAndLastTransferBlockNumberOf instead of checkpoints
    function disableTheUseOfCheckpoints() external {
        require(msg.sender == checkpointingDisabler, "NOT_AUTHORIZED");
        _useCheckpoints = false;
        checkpointingDisabler = address(0);
        emit CheckpointingDisablerSet(address(0));
        emit CheckpointingDisabled();
    }

    
    
    function setCheckpointingDisabler(address newCheckpointingDisabler) external {
        require(msg.sender == checkpointingDisabler, "NOT_AUTHORIZED");
        checkpointingDisabler = newCheckpointingDisabler;
        emit CheckpointingDisablerSet(newCheckpointingDisabler);
    }

    
    
    
    function mint(uint16 id, address to) external {
        require(msg.sender == minter, "ONLY_MINTER_ALLOWED");
        require(id < 1024, "INVALID_BLEEP");

        require(to != address(0), "NOT_TO_ZEROADDRESS");
        require(to != address(this), "NOT_TO_THIS");
        address owner = _ownerOf(id);
        require(owner == address(0), "ALREADY_CREATED");
        _safeTransferFrom(address(0), to, id, "");
    }

    
    
    
    function multiMint(uint16[] calldata ids, address[] calldata tos) external {
        require(msg.sender == minter, "ONLY_MINTER_ALLOWED");

        address to;
        if (tos.length == 1) {
            to = tos[0];
        }
        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            if (tos.length > 1) {
                to = tos[i];
            }
            require(to != address(0), "NOT_TO_ZEROADDRESS");
            require(to != address(this), "NOT_TO_THIS");
            require(id < 1024, "INVALID_BLEEP");
            address owner = _ownerOf(id);
            require(owner == address(0), "ALREADY_CREATED");
            _safeTransferFrom(address(0), to, id, "");
        }
    }

    
    
    
    
    function sound(uint256 id) external pure returns (uint8 note, uint8 instrument) {
        note = uint8(id & 0x3F);
        instrument = uint8(uint256(id >> 6) & 0x0F);
    }
}

// 
pragma solidity 0.8.9;



interface ReverseRegistrar {
    function setName(string memory name) external returns (bytes32);
}

interface ENS {
    function owner(bytes32 node) external view returns (address);
}

// 
pragma solidity 0.8.9;

interface ITokenURI {
    function tokenURI(uint256 id) external view returns (string memory);

    function contractURI(address receiver, uint96 per10Thousands) external view returns (string memory);
}