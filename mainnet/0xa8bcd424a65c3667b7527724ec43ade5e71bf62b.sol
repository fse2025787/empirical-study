
/******************************************************************************\

file:   RegBase.sol
ver:    0.3.3
updated:12-Sep-2017
author: Darryl Morris (o0ragman0o)
email:  o0ragman0o AT gmail.com

This file is part of the SandalStraps framework

`RegBase` provides an inheriting contract the minimal API to be compliant with 
`Registrar`.  It includes a set-once, `bytes32 public regName` which is refered
to by `Registrar` lookups.

An owner updatable `address public owner` state variable is also provided and is
required by `Factory.createNew()`.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

Release notes:
* Framworking changing to Factory v0.3.3 usage
\******************************************************************************/

pragma solidity ^0.4.13;

contract RegBaseAbstract
{
    
    /// lookup
    
    bytes32 public regName;

    
    /// string in a StringsMap
    
    bytes32 public resource;
    
    
    
    address public owner;
    
    
    
    address public newOwner;

//
// Events
//

    
    event ChangeOwnerTo(address indexed _newOwner);

    
    event ChangedOwner(address indexed _oldOwner, address indexed _newOwner);

    
    event ReceivedOwnership(address indexed _kAddr);

    
    event ChangedResource(bytes32 indexed _resource);

//
// Function Abstracts
//

    
    function destroy() public;

    
    
    function changeOwner(address _owner) public returns (bool);

    
    function acceptOwnership() public returns (bool);

    
    
    function changeResource(bytes32 _resource) public returns (bool);
}


contract RegBase is RegBaseAbstract
{
//
// Constants
//

    bytes32 constant public VERSION = "RegBase v0.3.3";

//
// State Variables
//

    // Declared in RegBaseAbstract for reasons that an inherited abstract
    // function is not seen as implimented by a public state identifier of
    // the same name.
    
//
// Modifiers
//

    // Permits only the owner
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

//
// Functions
//

    
    /// typically msg.sender
    
    
    /// owner
    
    /// `_owner` else `_creator` else msg.sender
    function RegBase(address _creator, bytes32 _regName, address _owner)
    {
        require(_regName != 0x0);
        regName = _regName;
        owner = _owner != 0x0 ? _owner : 
                _creator != 0x0 ? _creator : msg.sender;
    }
    
    
    function destroy()
        public
        onlyOwner
    {
        selfdestruct(msg.sender);
    }
    
    
    
    function changeOwner(address _owner)
        public
        onlyOwner
        returns (bool)
    {
        ChangeOwnerTo(_owner);
        newOwner = _owner;
        return true;
    }
    
    
    function acceptOwnership()
        public
        returns (bool)
    {
        require(msg.sender == newOwner);
        ChangedOwner(owner, msg.sender);
        owner = newOwner;
        delete newOwner;
        return true;
    }

    
    
    function changeResource(bytes32 _resource)
        public
        onlyOwner
        returns (bool)
    {
        resource = _resource;
        ChangedResource(_resource);
        return true;
    }
}

/******************************************************************************\

file:   Factory.sol
ver:    0.3.3
updated:12-Sep-2017
author: Darryl Morris (o0ragman0o)
email:  o0ragman0o AT gmail.com

This file is part of the SandalStraps framework

Factories are a core but independant concept of the SandalStraps framework and 
can be used to create SandalStraps compliant 'product' contracts from embed
bytecode.

The abstract Factory contract is to be used as a SandalStraps compliant base for
product specific factories which must impliment the createNew() function.

is itself compliant with `Registrar` by inhereting `RegBase` and
compiant with `Factory` through the `createNew(bytes32 _name, address _owner)`
API.

An optional creation fee can be set and manually collected by the owner.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

Release Notes
-------------
* Changed from`withdaw(<value>)` to `withdrawAll()`
\******************************************************************************/

pragma solidity ^0.4.13;

// import "./RegBase.sol";

contract Factory is RegBase
{
//
// Constants
//

    // Deriving factories should have `bytes32 constant public regName` being
    // the product's contract name, e.g for products "Foo":
    // bytes32 constant public regName = "Foo";

    // Deriving factories should have `bytes32 constant public VERSION` being
    // the product's contract name appended with 'Factory` and the version
    // of the product, e.g for products "Foo":
    // bytes32 constant public VERSION "FooFactory 0.0.1";

//
// State Variables
//

    
    uint public value;

//
// Events
//

    // Is triggered when a product is created
    event Created(address indexed _creator, bytes32 indexed _regName, address indexed _addr);

//
// Modifiers
//

    // To check that the correct fee has bene paid
    modifier feePaid() {
        require(msg.value == value || msg.sender == owner);
        _;
    }

//
// Functions
//

    
    /// typically msg.sender
    
    
    /// owner
    
    /// `_owner` else `_creator` else msg.sender
    function Factory(address _creator, bytes32 _regName, address _owner)
        RegBase(_creator, _regName, _owner)
    {
        // nothing left to construct
    }
    
    
    
    function set(uint _fee) 
        onlyOwner
        returns (bool)
    {
        value = _fee;
        return true;
    }

    
    function withdrawAll()
        public
        returns (bool)
    {
        owner.transfer(this.balance);
        return true;
    }

    
    
    /// a SandalStraps registrar
    
    /// msg.sender if 0x0
    
    function createNew(bytes32 _regName, address _owner) 
        payable returns(address kAddr_);
}

/******************************************************************************\

file:   Forwarder.sol
ver:    0.3.0
updated:4-Oct-2017
author: Darryl Morris (o0ragman0o)
email:  o0ragman0o AT gmail.com

This file is part of the SandalStraps framework

Forwarder acts as a proxy address for payment pass-through.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

Release Notes
-------------
* Name change from 'Redirector' to 'Forwarder'
* Changes state name from 'payTo' to 'forwardTo'

\******************************************************************************/

pragma solidity ^0.4.13;

// import "https://github.com/o0ragman0o/SandalStraps/contracts/Factory.sol";

contract Forwarder is RegBase {
//
// Constants
//

    bytes32 constant public VERSION = "Forwarder v0.3.0";

//
// State
//

    address public forwardTo;
    
//
// Events
//
    
    event Forwarded(
        address indexed _from,
        address indexed _to,
        uint _value);

//
// Functions
//

    function Forwarder(address _creator, bytes32 _regName, address _owner)
        public
        RegBase(_creator, _regName, _owner)
    {
        // forwardTo will be set to msg.sender of if _owner == 0x0 or _owner
        // otherwise
        forwardTo = owner;
    }
    
    function ()
        public
        payable 
    {
        Forwarded(msg.sender, forwardTo, msg.value);
        require(forwardTo.call.value(msg.value)(msg.data));
    }
    
    function changeForwardTo(address _forwardTo)
        public
        returns (bool)
    {
        // Only owner or forwarding address can change forwarding address 
        require(msg.sender == owner || msg.sender == forwardTo);
        forwardTo = _forwardTo;
        return true;
    }
}


contract ForwarderFactory is Factory
{
//
// Constants
//

    
    bytes32 constant public regName = "forwarder";
    
    
    bytes32 constant public VERSION = "ForwarderFactory v0.3.0";

//
// Functions
//

    
    /// typically msg.sender
    
    
    /// owner
    
    /// `_owner` else `_creator` else msg.sender
    function ForwarderFactory(
            address _creator, bytes32 _regName, address _owner) public
        Factory(_creator, regName, _owner)
    {
        // _regName is ignored as `regName` is already a constant
        // nothing to construct
    }

    
    
    /// a SandalStraps registrar
    
    /// msg.sender if 0x0
    
    function createNew(bytes32 _regName, address _owner)
        public
        payable
        feePaid
        returns (address kAddr_)
    {
        kAddr_ = address(new Forwarder(msg.sender, _regName, _owner));
        Created(msg.sender, _regName, kAddr_);
    }
}