// SPDX-License-Identifier: AGPL-3.0-only

// 
pragma solidity >=0.8.0;



abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}

// 
pragma solidity ^0.8.13;


/// ID.
interface IAccountRegistry {
    
    /// Subject must not yet have an account.
    function createAccount(address subject, string calldata metadata)
        external
        returns (uint64 id);

    
    function resolveId(address subject) external view returns (uint64 id);
}
// 
pragma solidity ^0.8.13;

/*

███╗   ███╗███████╗████████╗ █████╗ ██╗      █████╗ ██████╗ ███████╗██╗
████╗ ████║██╔════╝╚══██╔══╝██╔══██╗██║     ██╔══██╗██╔══██╗██╔════╝██║
██╔████╔██║█████╗     ██║   ███████║██║     ███████║██████╔╝█████╗  ██║
██║╚██╔╝██║██╔══╝     ██║   ██╔══██║██║     ██╔══██║██╔══██╗██╔══╝  ██║
██║ ╚═╝ ██║███████╗   ██║   ██║  ██║███████╗██║  ██║██████╔╝███████╗███████╗
╚═╝     ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝


Deployed by Metalabel with 💖 as a permanent application on the Ethereum blockchain.

Metalabel is a growing universe of tools, knowledge, and resources for
metalabels and cultural collectives.

Our purpose is to establish the metalabel as key infrastructure for creative
collectives and to inspire a new culture of creative collaboration and mutual
support.

OUR SQUAD

Anna Bulbrook (Curator)
Austin Robey (Community)
Brandon Valosek (Engineer)
Ilya Yudanov (Designer)
Lauren Dorman (Engineer)
Rob Kalin (Board)
Yancey Strickler (Director)

https://metalabel.xyz

*/





/// ID.
/// - Accounts are identified by a uint64 ID
/// - Accounts are owned by an address
/// - Accounts can broadcast arbitrary strings, keyed by a topic, as blockchain events
contract AccountRegistry is IAccountRegistry, Owned {
    // ---
    // Events
    // ---

    
    event AccountCreated(
        uint64 indexed id,
        address indexed subject,
        string metadata
    );

    
    event AccountBroadcast(uint64 indexed id, string topic, string message);

    
    event AccountTransfered(uint64 indexed id, address newOwner);

    
    event AccountIssuerSet(address indexed issuer, bool authorized);

    // ---
    // Errors
    // ---

    
    error NoAccount();

    
    error AccountAlreadyExists();

    
    /// create an account.
    error NotAuthorizedAccountIssuer();

    // ---
    // Storage
    // ---

    
    uint64 public totalAccountCount;

    
    mapping(address => uint64) public accountIds;

    
    /// authorized to issue accounts.
    mapping(address => bool) public isAccountIssuer;

    // ---
    // Constructor
    // ---

    constructor(address _contractOwner) Owned(_contractOwner) {}

    // ---
    // Owner functionality
    // ---

    
    function setAccountIssuer(address issuer, bool authorized)
        external
        onlyOwner
    {
        isAccountIssuer[issuer] = authorized;
        emit AccountIssuerSet(issuer, authorized);
    }

    // ---
    // Account creation functionality
    // ---

    
    function createAccount(address subject, string calldata metadata)
        external
        returns (uint64 id)
    {
        if (accountIds[subject] != 0) revert AccountAlreadyExists();

        // So long as an owner is set, account issuance is permissioned and
        // msg.sender must be an approved account issuer
        if (owner != address(0) && !isAccountIssuer[msg.sender]) {
            revert NotAuthorizedAccountIssuer();
        }

        id = ++totalAccountCount;
        accountIds[subject] = id;
        emit AccountCreated(id, subject, metadata);
    }

    // ---
    // Account functionality
    // ---

    
    function broadcast(string calldata topic, string calldata message)
        external
    {
        uint64 id = accountIds[msg.sender];
        if (id == 0) revert NoAccount();

        emit AccountBroadcast(id, topic, message);
    }

    
    /// have an account, and msg.sender must currently own the account.
    function transferAccount(address newOwner) external {
        uint64 id = accountIds[msg.sender];
        if (id == 0) revert NoAccount();
        if (accountIds[newOwner] != 0) revert AccountAlreadyExists();

        accountIds[newOwner] = id;
        delete accountIds[msg.sender];
        emit AccountTransfered(id, newOwner);
    }

    // ---
    // Views
    // ---

    
    function resolveId(address subject) external view returns (uint64 id) {
        id = accountIds[subject];
    }
}
