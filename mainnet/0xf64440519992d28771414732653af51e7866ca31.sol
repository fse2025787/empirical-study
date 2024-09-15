// SPDX-License-Identifier: GPL-3.0-or-later

/**
 *Submitted for verification at Etherscan.io on 2021-10-04
*/

// 

pragma solidity >=0.8.0 <0.9.0;



interface IBentoBoxMinimal {
    
    function registerProtocol() external;

    
    function setMasterContractApproval(
        address user,
        address masterContract,
        bool approved,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    
    
    
    
    
    function toShare(
        address token,
        uint256 amount,
        bool roundUp
    ) external view returns (uint256 share);

    
    
    
    
    
    
    
    
    function deposit(
        address token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external payable returns (uint256 amountOut, uint256 shareOut);

    
    
    
    
    
    function transfer(
        address token,
        address from,
        address to,
        uint256 share
    ) external;
}



contract LexLocker {
    IBentoBoxMinimal immutable bento;
    address public lexDAO;
    address immutable wETH;
    uint256 lockerCount;
    bytes32 public immutable DOMAIN_SEPARATOR;
    bytes32 public constant INVOICE_HASH = keccak256("DepositWithInvoiceSig(address depositor,address receiver,address resolver,string details)");

    mapping(uint256 => string) public agreements;
    mapping(uint256 => Locker) public lockers;
    mapping(address => Resolver) public resolvers;

    constructor(IBentoBoxMinimal _bento, address _lexDAO, address _wETH) {
        bento = _bento;
        bento.registerProtocol();
        lexDAO = _lexDAO;
        wETH = _wETH;
        
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("LexLocker")),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
    }
    
    
    event Deposit(
        bool bento,
        bool nft,
        address indexed depositor, 
        address indexed receiver, 
        address resolver,
        address token, 
        uint256 value, 
        uint256 indexed registration,
        string details);
    event DepositWithInvoiceSig(address indexed depositor, address indexed receiver);
    event Release(uint256 indexed registration);
    event Withdraw(uint256 indexed registration);
    event Lock(uint256 indexed registration, string details);
    event Resolve(uint256 indexed registration, uint256 indexed depositorAward, uint256 indexed receiverAward, string details);
    event RegisterResolver(address indexed resolver, bool indexed active, uint256 indexed fee);
    event RegisterAgreement(uint256 indexed index, string agreement);
    event UpdateLexDAO(address indexed lexDAO);
    
    
    struct Locker {
        bool bento;
        bool nft; 
        bool locked;
        address depositor;
        address receiver;
        address resolver;
        address token;
        uint256 value;
        uint256 termination;
    }
    
    
    struct Resolver {
        bool active;
        uint8 fee;
    }
    
    // **** ESCROW PROTOCOL **** //
    // ------------------------ //
    
    /// - locked funds can be released by `msg.sender` `depositor` 
    /// - both parties can {lock} for `resolver`. 
    
    
    
    
    
    
    
    function deposit(
        address receiver, 
        address resolver, 
        address token, 
        uint256 value,
        uint256 termination,
        bool nft, 
        string memory details
    ) public payable returns (uint256 registration) {
        require(resolvers[resolver].active, "resolver not active");
        require(resolver != msg.sender && resolver != receiver, "resolver cannot be party"); 
   
        
        if (msg.value != 0) {
            require(msg.value == value, "wrong msg.value");
            
            if (token != address(0)) token = address(0);
            if (nft) nft = false;
        } else {
            safeTransferFrom(token, msg.sender, address(this), value);
        }
 
        
        unchecked {
            lockerCount++;
        }
        registration = lockerCount;
        lockers[registration] = Locker(false, nft, false, msg.sender, receiver, resolver, token, value, termination);
        
        emit Deposit(false, nft, msg.sender, receiver, resolver, token, value, registration, details);
    }

    
    /// - locked funds can be released by `msg.sender` `depositor` 
    /// - both parties can {lock} for `resolver`. 
    
    
    
    
    
    
    
    function depositBento(
        address receiver, 
        address resolver, 
        address token, 
        uint256 value,
        uint256 termination,
        bool wrapBento,
        string memory details
    ) public payable returns (uint256 registration) {
        require(resolvers[resolver].active, "resolver not active");
        require(resolver != msg.sender && resolver != receiver, "resolver cannot be party"); 
 
        
        value = bento.toShare(token, value, false);

        
        if (msg.value != 0) {
            require(msg.value == value, "wrong msg.value");
            
            if (token != wETH) token = wETH;
            bento.deposit{value: msg.value}(address(0), address(this), address(this), 0, msg.value);
        } else if (wrapBento) {
            safeTransferFrom(token, msg.sender, address(bento), value);
            bento.deposit(token, address(bento), address(this), 0, value);
        } else {
            bento.transfer(token, msg.sender, address(this), value);
        }

        
        unchecked {
            lockerCount++;
        }
        registration = lockerCount;
        lockers[registration] = Locker(true, false, false, msg.sender, receiver, resolver, token, value, termination);
        
        emit Deposit(true, false, msg.sender, receiver, resolver, token, value, registration, details);
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function depositWithInvoiceSig(
        address receiver, 
        address resolver, 
        address token, 
        uint256 value,
        uint256 termination,
        bool bentoBoxed,
        bool nft, 
        bool wrapBento,
        string memory details,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable {
        
        bytes32 digest =
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(
                            INVOICE_HASH,
                            msg.sender,
                            receiver,
                            resolver,
                            details
                        )
                    )
                )
            );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress == receiver, "invalid invoice");

        
        if (!bentoBoxed) {
            deposit(receiver, resolver, token, value, termination, nft, details);
        } else {
            depositBento(receiver, resolver, token, value, termination, wrapBento, details);
        }
        
        emit DepositWithInvoiceSig(msg.sender, receiver);
    }
    
    
    /// - can only be called by `depositor` if not `locked`
    /// - can be called after `termination` as optional extension.
    
    function release(uint256 registration) external {
        Locker storage locker = lockers[registration]; 
        
        require(!locker.locked, "locked");
        require(msg.sender == locker.depositor, "not depositor");
        
        
        if (locker.token == address(0)) { 
            safeTransferETH(locker.receiver, locker.value);
        } else if (locker.bento) { 
            bento.transfer(locker.token, address(this), locker.receiver, locker.value);
        } else if (!locker.nft) { 
            safeTransfer(locker.token, locker.receiver, locker.value);
        } else { 
            safeTransferFrom(locker.token, address(this), locker.receiver, locker.value);
        }
        
        delete lockers[registration];
        
        emit Release(registration);
    }
    
    
    /// - can only be called by `depositor` if `termination` reached.
    
    function withdraw(uint256 registration) external {
        Locker storage locker = lockers[registration];
        
        require(msg.sender == locker.depositor, "not depositor");
        require(!locker.locked, "locked");
        require(block.timestamp >= locker.termination, "not terminated");
        
        
        if (locker.token == address(0)) { 
            safeTransferETH(locker.depositor, locker.value);
        } else if (locker.bento) { 
            bento.transfer(locker.token, address(this), locker.depositor, locker.value);
        } else if (!locker.nft) { 
            safeTransfer(locker.token, locker.depositor, locker.value);
        } else { 
            safeTransferFrom(locker.token, address(this), locker.depositor, locker.value);
        }
        
        delete lockers[registration];
        
        emit Withdraw(registration);
    }

    // **** DISPUTE PROTOCOL **** //
    // ------------------------- //
    
    
    
    function lock(uint256 registration, string calldata details) external {
        Locker storage locker = lockers[registration];
        
        require(msg.sender == locker.depositor || msg.sender == locker.receiver, "not party");
        
        locker.locked = true;
        
        emit Lock(registration, details);
    }
    
    
    /// - `resolverFee` is automatically deducted from both parties' awards.
    
    
    
    
    function resolve(uint256 registration, uint256 depositorAward, uint256 receiverAward, string calldata details) external {
        Locker storage locker = lockers[registration]; 
        
        require(msg.sender == locker.resolver, "not resolver");
        require(locker.locked, "not locked");
        require(depositorAward + receiverAward == locker.value, "not remainder");
        
        
        uint256 resolverFee = locker.value / resolvers[locker.resolver].fee;
        depositorAward -= resolverFee / 2;
        receiverAward -= resolverFee / 2;
        
        
        if (locker.token == address(0)) { 
            safeTransferETH(locker.depositor, depositorAward);
            safeTransferETH(locker.receiver, receiverAward);
            safeTransferETH(locker.resolver, resolverFee);
        } else if (locker.bento) { 
            bento.transfer(locker.token, address(this), locker.depositor, depositorAward);
            bento.transfer(locker.token, address(this), locker.receiver, receiverAward);
            bento.transfer(locker.token, address(this), locker.resolver, resolverFee);
        } else if (!locker.nft) { 
            safeTransfer(locker.token, locker.depositor, depositorAward);
            safeTransfer(locker.token, locker.receiver, receiverAward);
            safeTransfer(locker.token, locker.resolver, resolverFee);
        } else { 
            if (depositorAward != 0) {
                safeTransferFrom(locker.token, address(this), locker.depositor, locker.value);
            } else {
                safeTransferFrom(locker.token, address(this), locker.receiver, locker.value);
            }
        }
        
        delete lockers[registration];
        
        emit Resolve(registration, depositorAward, receiverAward, details);
    }
    
    
    
    
    function registerResolver(bool active, uint8 fee) external {
        resolvers[msg.sender] = Resolver(active, fee);
        emit RegisterResolver(msg.sender, active, fee);
    }

    // **** LEXDAO PROTOCOL **** //
    // ------------------------ //
    
    
    
    function registerAgreement(uint256 index, string calldata agreement) external {
        require(msg.sender == lexDAO, "not LexDAO");
        agreements[index] = agreement;
        emit RegisterAgreement(index, agreement);
    }

    
    
    function updateLexDAO(address _lexDAO) external {
        require(msg.sender == lexDAO, "not LexDAO");
        lexDAO = _lexDAO;
        emit UpdateLexDAO(_lexDAO);
    }

    // **** BATCHER UTILITIES **** //
    // -------------------------- //
    
    function multicall(bytes[] calldata data) external returns (bytes[] memory results) {
        results = new bytes[](data.length);
        unchecked {
            for (uint256 i = 0; i < data.length; i++) {
                (bool success, bytes memory result) = address(this).delegatecall(data[i]);
                if (!success) {
                    if (result.length < 68) revert();
                    assembly { result := add(result, 0x04) }
                    revert(abi.decode(result, (string)));
                }
                results[i] = result;
            }
        }
    }

    
    
    
    
    
    
    
    function permitThis(
        address token,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        
        (bool success, ) = token.call(abi.encodeWithSelector(0xd505accf, msg.sender, address(this), amount, deadline, v, r, s));
        require(success, "permit failed");
    }

    
    
    
    
    
    
    
    function permitThisAllowed(
        address token,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        
        (bool success, ) = token.call(abi.encodeWithSelector(0x8fcbaf0c, msg.sender, address(this), nonce, expiry, true, v, r, s));
        require(success, "permit failed");
    }

    
    
    
    
    function setBentoApproval(uint8 v, bytes32 r, bytes32 s) external {
        bento.setMasterContractApproval(msg.sender, address(this), true, v, r, s);
    }
    
    // **** TRANSFER HELPERS **** //
    // ------------------------- //
    
    
    
    
    function safeTransfer(address token, address recipient, uint256 value) private {
        
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, recipient, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "transfer failed");
    }

    
    
    
    
    
    function safeTransferFrom(address token, address sender, address recipient, uint256 value) private {
        
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, sender, recipient, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "pull failed");
    }
    
    
    
    
    function safeTransferETH(address recipient, uint256 value) private {
        (bool success, ) = recipient.call{value: value}("");
        require(success, "eth transfer failed");
    }
}