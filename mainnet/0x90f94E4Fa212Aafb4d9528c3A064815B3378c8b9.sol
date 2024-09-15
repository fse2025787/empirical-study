// SPDX-License-Identifier: AGPL-3.0


// 
pragma solidity >=0.4.22 <0.9.0;




struct BatchPermissionEntry {
    bytes4 target;
    address caller;
    bool state;
}



interface IExecutionPermissions_Events {
    /// Log attempt to transfer ownership of contract instance
    ///
    
    
    event OwnerNominated(address indexed from, address indexed to);

    /// Log ownership transfer completion
    ///
    
    
    event OwnershipClaimed(address indexed from, address indexed to);
}



interface IExecutionPermissions_Functions {
    /*************************************************************************/
    /* Views on-chain */
    /*************************************************************************/

    /// Check execution permissions of target function for given caller
    ///
    
    
    ///
    
    ///
    
    ///
    /// ```solidity
    /// import {
    ///     IExecutionPermissions
    /// } from "./contracts/interfaces/IExecutionPermissions.sol";
    ///
    /// contract ExampleUsage {
    ///     /* ... */
    ///
    ///     address public refPermissions;
    ///
    ///     /* ... */
    ///
    ///     constructor(address _refPermissions) {
    ///         /* ... */
    ///         refPermissions = _refPermissions;
    ///     }
    ///
    ///     modifier onlyPermitted() {
    ///         require(
    ///             IExecutionPermissions(refPermissions).isPermitted(
    ///                 bytes4(msg.data),
    ///                 msg.sender
    ///             ),
    ///             "ExampleUsage: sender not permitted"
    ///         );
    ///         _;
    ///     }
    ///
    ///     function restricted() external onlyPermitted {
    ///         /* ... */
    ///     }
    ///
    ///     /* ... */
    /// }
    /// ```
    function isPermitted(bytes4 target, address caller)
        external
        view
        returns (bool);

    /// Check execution permissions of target function for given caller
    ///
    
    
    ///
    
    ///      implicit conversion of function signature string to ID
    ///
    
    ///
    
    ///
    /// ```solidity
    /// import {
    ///     IExecutionPermissions
    /// } from "./contracts/interfaces/IExecutionPermissions.sol";
    ///
    /// contract ExampleUsage {
    ///     /* ... */
    ///
    ///     address public refPermissions;
    ///
    ///     /* ... */
    ///
    ///     constructor(address _refPermissions) {
    ///         /* ... */
    ///         refPermissions = _refPermissions;
    ///     }
    ///
    ///     function restricted() external {
    ///         string memory target = "restricted()";
    ///         address caller = msg.sender;
    ///         require(isPermitted(target, caller), "Not permitted");
    ///         /* ... */
    ///     }
    ///
    ///     /* ... */
    /// }
    /// ```
    function isPermitted(string memory target, address caller)
        external
        view
        returns (bool);

    /*************************************************************************/
    /* Mutations */
    /*************************************************************************/

    /// Assign multiple permission entries in one transaction
    ///
    
    ///
    
    ///      fees of multiple `setTargetPermission(bytes4,address,bool)` calls
    ///
    
    ///
    
    ///
    /// ```solidity
    /// import {
    ///     IExecutionPermissions,
    ///     BatchPermissionEntry
    /// } from "./contracts/interfaces/IExecutionPermissions.sol";
    ///
    /// contract ExampleUsage {
    ///     /* ... */
    ///
    ///     address public owner;
    ///     address public refPermissions;
    ///
    ///     /* ... */
    ///
    ///     constructor(address _refPermissions) {
    ///         owner = msg.sender;
    ///         refPermissions = _refPermissions;
    ///     }
    ///
    ///     /* ... */
    ///
    ///     modifier onlyOwner() {
    ///         require(msg.sender == owner, "ExampleUsage: sender not permitted");
    ///         _;
    ///     }
    ///
    ///     /* ... */
    ///
    ///     function setBatchPermission(BatchPermissionEntry[] memory entries)
    ///         external
    ///         onlyOwner
    ///     {
    ///         IExecutionPermissions(refPermissions).setBatchPermission(entries);
    ///     }
    /// }
    /// ```
    function setBatchPermission(BatchPermissionEntry[] memory entries)
        external
        payable;

    /// Assign single function caller permission state
    ///
    
    
    
    ///
    
    ///
    
    ///
    /// ```solidity
    /// import {
    ///     IExecutionPermissions,
    ///     BatchPermissionEntry
    /// } from "./contracts/interfaces/IExecutionPermissions.sol";
    ///
    /// contract ExampleUsage {
    ///     /* ... */
    ///
    ///     address public owner;
    ///     address public refPermissions;
    ///
    ///     /* ... */
    ///
    ///     constructor(address _refPermissions) {
    ///         owner = msg.sender;
    ///         refPermissions = _refPermissions;
    ///     }
    ///
    ///     /* ... */
    ///
    ///     modifier onlyOwner() {
    ///         require(msg.sender == owner, "ExampleUsage: sender not permitted");
    ///         _;
    ///     }
    ///
    ///     /* ... */
    ///
    ///     function setTargetPermission(
    ///         bytes4 target,
    ///         address caller,
    ///         bool state
    ///     ) external onlyOwner {
    ///         IExecutionPermissions(refPermissions).setTargetPermission(
    ///             target,
    ///             caller,
    ///             state
    ///         );
    ///     }
    /// }
    /// ```
    function setTargetPermission(
        bytes4 target,
        address caller,
        bool state
    ) external payable;

    /// Set registration state for calling contract instance
    ///
    
    ///
    
    ///      this with `false` before calling new reference with `true`
    ///
    
    ///
    
    ///
    /// ```solidity
    /// import {
    ///     IExecutionPermissions
    /// } from "./contracts/interfaces/IExecutionPermissions.sol";
    ///
    /// contract ExampleUsage {
    ///     /* ... */
    ///
    ///     address public owner;
    ///     address public refPermissions;
    ///
    ///     /* ... */
    ///
    ///     constructor(address _refPermissions) {
    ///         owner = msg.sender;
    ///         refPermissions = _refPermissions;
    ///     }
    ///
    ///     /* ... */
    ///
    ///     modifier onlyOwner() {
    ///         require(msg.sender == owner, "ExampleUsage: sender not permitted");
    ///         _;
    ///     }
    ///
    ///     /* ... */
    ///
    ///     function setRegistered(bool state) external onlyOwner {
    ///         IExecutionPermissions(refPermissions).setRegistered(state);
    ///     }
    /// }
    /// ```
    function setRegistered(bool state) external payable;

    /// Set registration state for referenced contract instance
    ///
    
    
    ///
    
    
    
    ///
    
    ///
    
    ///
    /// ### Node Web3JS set state for owned contract
    ///
    /// ```javascript
    /// const { PRIVATE_KEY } = process.env;
    ///
    /// if (PRIVATE_KEY) {
    ///   const account = web3.eth.accounts.privateKeyToAccount(PRIVATE_KEY);
    ///
    ///   ExecutionPermissions
    ///     .methods
    ///     .setRegistered("0x0...DEADBEEF", true)
    ///     .send({ from: account.address })
    ///     .then((receipt) => {
    ///       console.log("tip ->", JSON.stringify({ receipt }, null, 2));
    ///     });
    /// }
    /// ```
    function setRegistered(address ref, bool state) external payable;

    /// Show some support developers of this contract
    ///
    
    ///
    
    ///
    /// ### Node Web3JS show appreciation for owner of `ExecutionPermissions`
    ///
    /// ```javascript
    /// const { PRIVATE_KEY } = process.env;
    ///
    /// if (PRIVATE_KEY) {
    ///   const account = web3.eth.accounts.privateKeyToAccount(PRIVATE_KEY);
    ///
    ///   ExecutionPermissions
    ///     .methods
    ///     .tip()
    ///     .send({
    ///       from: account.address,
    ///       value: web3.utils.toWei("0.1"),
    ///     }).then((receipt) => {
    ///       console.log("tip ->", JSON.stringify({ receipt }, null, 2));
    ///     });
    /// }
    /// ```
    function tip() external payable;

    /*************************************************************************/
    /* Administration */
    /*************************************************************************/

    /// Allow owner of `ExecutionPermissions` to receive tips
    ///
    
    
    ///
    
    ///
    
    
    ///
    
    ///
    /// ### Node Web3JS transfer contract balance to owner
    ///
    /// ```javascript
    /// const { PRIVATE_KEY } = process.env;
    ///
    /// if (PRIVATE_KEY) {
    ///   const account = web3.eth.accounts.privateKeyToAccount(PRIVATE_KEY);
    ///
    ///   web3.eth.getBalance(ExecutionPermissions.address).then((balance) => {
    ///     const parameters = {
    ///       to: account.address,
    ///       amount: balance,
    ///     };
    ///
    ///     return ExecutionPermissions
    ///       .methods
    ///       .withdraw(...Object.values(parameters))
    ///       .send({ from: account.address });
    ///   }).then((receipt) => {
    ///     console.log("withdraw ->", JSON.stringify({ receipt }, null, 2));
    ///   });
    /// }
    /// ```
    function withdraw(address to, uint256 amount) external payable;

    /// Initiate transfer of contract ownership
    ///
    
    ///
    
    
    ///
    
    
    ///
    
    ///
    /// ### Node Web3JS nominate new owner
    ///
    /// ```javascript
    /// const { PRIVATE_KEY } = process.env;
    /// const { NEW_OWNER_ADDRESS } = process.env;
    ///
    /// if (PRIVATE_KEY && NEW_OWNER_ADDRESS) {
    ///   const account = web3.eth.accounts.privateKeyToAccount(PRIVATE_KEY);
    ///
    ///   web3.eth.getBalance(ExecutionPermissions.address).then((balance) => {
    ///     return ExecutionPermissions
    ///       .methods
    ///       .nominateOwner(NEW_OWNER_ADDRESS)
    ///       .send({ from: account.address });
    ///   }).then((receipt) => {
    ///     console.log("nominateOwner ->", JSON.stringify({ receipt }, null, 2));
    ///   });
    /// }
    /// ```
    function nominateOwner(address newOwner) external payable;

    /// Accept transfer of contract ownership
    ///
    
    
    ///
    
    
    ///
    
    ///
    /// ### Node Web3JS assume ownership of contract
    ///
    /// ```javascript
    /// const { PRIVATE_KEY } = process.env;
    ///
    /// if (PRIVATE_KEY) {
    ///   const account = web3.eth.accounts.privateKeyToAccount(PRIVATE_KEY);
    ///
    ///   web3.eth.getBalance(ExecutionPermissions.address).then((balance) => {
    ///     return ExecutionPermissions
    ///       .methods
    ///       .claimOwnership()
    ///       .send({ from: account.address });
    ///   }).then((receipt) => {
    ///     console.log("claimOwnership ->", JSON.stringify({ receipt }, null, 2));
    ///   });
    /// }
    /// ```
    function claimOwnership() external payable;
}



interface IExecutionPermissions_Variables {
    /// Check execution permissions of referenced contract function for given caller
    ///
    
    ///
    
    
    
    ///
    
    ///
    /// ### Web3JS check permissions of contract function caller
    ///
    /// ```javascript
    /// function getTargetPermission({
    ///   ExecutionPermissions,
    ///   ref,
    ///   target,
    ///   caller,
    /// } = {}) {
    ///   if (target.length !== 10) {
    ///     target = web3.eth.abi.encodeFunctionSignature(target);
    ///   }
    ///   return ExecutionPermissions.methods.permissions(ref, target, caller).call();
    /// }
    ///
    /// getTargetPermission({
    ///   ExecutionPermissions,
    ///   ref: "0x0...1",
    ///   target: "someFunctionName(address,string,uint256)",
    ///   caller: "0x0...2",
    /// }).then((response) => {
    ///   console.assert(typeof response === "boolean", "Unexpected response type");
    ///   console.log("getTargetPermission ->", { response });
    /// });
    /// ```
    function permissions(
        address ref,
        bytes4 target,
        address caller
    ) external view returns (bool);

    /// Check registration status of referenced contract
    ///
    
    ///
    
    ///
    
    ///
    /// ### Web3JS check registration status of contract
    ///
    /// ```javascript
    /// function getRegistrationStatus({
    ///   ExecutionPermissions,
    ///   ref,
    /// } = {}) {
    ///   return ExecutionPermissions.methods.registered(ref).call();
    /// }
    ///
    /// getTargetPermission({
    ///   ExecutionPermissions,
    ///   ref: '0x0...1',
    ///   target: "setBatchPermission(BatchPermissionEntry[])",
    ///   caller: ADDRESS,
    /// }).then((response) => {
    ///   console.assert(typeof response === "boolean", "Unexpected response type");
    ///   console.log("getTargetPermission ->", { response });
    /// });
    /// ```
    function registered(address ref) external view returns (bool);

    /// Obtain current owner address
    ///
    
    ///
    
    ///
    /// ### Web3JS check what address owns contract instance
    ///
    /// ```javascript
    /// ExecutionPermissions.methods.owner().then((response) => {
    ///   console.assert(typeof response === "string", "Unexpected response type");
    ///   console.log("owner ->", { response });
    /// })
    /// ```
    function owner() external view returns (address);

    /// Obtain new owner nominated address
    ///
    
    ///
    
    ///
    /// ### Web3JS check what address is nominated to own contract
    ///
    /// ```javascript
    /// ExecutionPermissions.methods.nominated_owner().then((response) => {
    ///   console.assert(typeof response === "string", "Unexpected response type");
    ///   console.log("nominated_owner ->", { response });
    /// })
    /// ```
    function nominated_owner() external view returns (address);
}
// 
pragma solidity >=0.4.22 <0.9.0;

/* prettier-ignore */








contract ExecutionPermissions is
    IExecutionPermissions_Events,
    IExecutionPermissions_Functions
{
    /// Map contract to function target to caller to permission
    
    mapping(address => mapping(bytes4 => mapping(address => bool)))
        public permissions;

    /// Map contract to registered state
    
    mapping(address => bool) public registered;

    /// Store current owner of this contract instance
    
    address public owner;

    /// Store address of possible new owner of this contract instance
    
    address public nominated_owner;

    ///
    constructor() {
        owner = msg.sender;
        emit OwnershipClaimed(address(0), msg.sender);
    }

    /*************************************************************************/
    /* Modifiers */
    /*************************************************************************/

    modifier onlyRegistered() {
        require(
            registered[msg.sender],
            "ExecutionPermissions: instance not registered"
        );
        _;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "ExecutionPermissions: caller not owner");
        _;
    }

    /*************************************************************************/
    /* Views */
    /*************************************************************************/

    
    
    function isPermitted(bytes4 target, address caller)
        external
        view
        virtual
        override
        onlyRegistered
        returns (bool)
    {
        return permissions[msg.sender][target][caller];
    }

    
    
    function isPermitted(string memory target, address caller)
        external
        view
        virtual
        override
        onlyRegistered
        returns (bool)
    {
        return
            permissions[msg.sender][bytes4(keccak256(bytes(target)))][caller];
    }

    /*************************************************************************/
    /* Mutations */
    /*************************************************************************/

    
    
    function setBatchPermission(BatchPermissionEntry[] memory entries)
        external
        payable
        virtual
        override
        onlyRegistered
    {
        uint256 length = entries.length;
        BatchPermissionEntry memory entry;
        for (uint256 i; i < length; ) {
            entry = entries[i];
            permissions[msg.sender][entry.target][entry.caller] = entry.state;

            unchecked {
                ++i;
            }
        }
    }

    
    
    function setTargetPermission(
        bytes4 target,
        address caller,
        bool state
    ) external payable virtual override onlyRegistered {
        permissions[msg.sender][target][caller] = state;
    }

    
    
    function setRegistered(bool state) external payable virtual override {
        require(
            msg.sender.code.length > 0,
            "ExecutionPermissions: instance not initialized"
        );

        registered[msg.sender] = state;
    }

    
    
    function setRegistered(address ref, bool state)
        external
        payable
        virtual
        override
    {
        require(
            ref.code.length > 0,
            "ExecutionPermissions: instance not initialized"
        );

        address refOwner;
        try IOwnable(ref).owner() returns (address result) {
            refOwner = result;
        } catch {
            revert(
                "ExecutionPermissions: instance does not implement `.owner()`"
            );
        }

        require(
            msg.sender == refOwner,
            "ExecutionPermissions: not instance owner"
        );

        registered[ref] = state;
    }

    
    
    function tip() external payable virtual override {}

    /*************************************************************************/
    /* Administration */
    /*************************************************************************/

    
    
    function withdraw(address to, uint256 amount)
        external
        payable
        virtual
        override
        onlyOwner
    {
        (bool success, ) = to.call{ value: amount }("");
        require(success, "ExecutionPermissions: transfer failed");
    }

    
    
    
    function nominateOwner(address newOwner)
        external
        payable
        virtual
        override
        onlyOwner
    {
        require(
            newOwner != address(0),
            "ExecutionPermissions: new owner cannot be zero address"
        );

        nominated_owner = newOwner;
        emit OwnerNominated(owner, newOwner);
    }

    
    
    
    function claimOwnership() external payable virtual override {
        require(
            nominated_owner != address(0),
            "ExecutionPermissions: new owner cannot be zero address"
        );

        require(
            nominated_owner == msg.sender,
            "ExecutionPermissions: sender not nominated"
        );

        address previousOwner = owner;
        owner = msg.sender;
        emit OwnershipClaimed(previousOwner, msg.sender);
    }
}

// 
pragma solidity >=0.4.22 <0.9.0;


interface IOwnable {
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    
    function owner() external view returns (address);

    
    function renounceOwnership() external payable;

    
    function transferOwnership(address newOwner) external payable;
}




///

///
/// ### Node Web3JS initialize contract instance
///
/// ```javascript
/// const Web3 = require('web3');
///
/// const { abi } = require('./build/contracts/IExecutionPermissions.json');
///
/// const { ADDRESS } = process.env;
///
/// const web3 = new Web3('http://localhost:8545');
///
/// const ExecutionPermissions = new web3.eth.Contract(abi, ADDRESS);
/// ```
interface IExecutionPermissions is
    IExecutionPermissions_Events,
    IExecutionPermissions_Functions,
    IExecutionPermissions_Variables
{

}