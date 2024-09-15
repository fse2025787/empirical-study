
//File: contracts/Owned.sol
pragma solidity ^0.4.19;





///  authorization control functions, this simplifies & the implementation of
///  user permissions; this contract has three work flows for a change in
///  ownership, the first requires the new owner to validate that they have the
///  ability to accept ownership, the second allows the ownership to be
///  directly transfered without requiring acceptance, and the third allows for
///  the ownership to be removed to allow for decentralization 
contract Owned {

    address public owner;
    address public newOwnerCandidate;

    event OwnershipRequested(address indexed by, address indexed to);
    event OwnershipTransferred(address indexed from, address indexed to);
    event OwnershipRemoved();

    
    function Owned() public {
        owner = msg.sender;
    }

    
    /// modifier
    modifier onlyOwner() {
        require (msg.sender == owner);
        _;
    }
    
    
    ///  be called first by the current `owner` then `acceptOwnership()` must be
    ///  called by the `newOwnerCandidate`
    
    ///  new owner
    
    function proposeOwnership(address _newOwnerCandidate) public onlyOwner {
        newOwnerCandidate = _newOwnerCandidate;
        OwnershipRequested(msg.sender, newOwnerCandidate);
    }

    
    ///  transfer of ownership
    function acceptOwnership() public {
        require(msg.sender == newOwnerCandidate);

        address oldOwner = owner;
        owner = newOwnerCandidate;
        newOwnerCandidate = 0x0;

        OwnershipTransferred(oldOwner, owner);
    }

    
    ///  be called and it will immediately assign ownership to the `newOwner`
    
    
    function changeOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != 0x0);

        address oldOwner = owner;
        owner = _newOwner;
        newOwnerCandidate = 0x0;

        OwnershipTransferred(oldOwner, owner);
    }

    
    ///  be called and it will immediately assign ownership to the 0x0 address;
    ///  it requires a 0xdece be input as a parameter to prevent accidental use
    
    
    function removeOwnership(address _dac) public onlyOwner {
        require(_dac == 0xdac);
        owner = 0x0;
        newOwnerCandidate = 0x0;
        OwnershipRemoved();     
    }
} 
//File: contracts/ERC20.sol
pragma solidity ^0.4.19;


/**
 * @title ERC20
 * @dev A standard interface for tokens.
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 */
contract ERC20 {
  
    
    function totalSupply() public constant returns (uint256 supply);

    
    function balanceOf(address _owner) public constant returns (uint256 balance);

    
    function transfer(address _to, uint256 _value) public returns (bool success);

    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    
    function approve(address _spender, uint256 _value) public returns (bool success);

    
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}
//File: contracts/Escapable.sol
pragma solidity ^0.4.19;
/*
    Copyright 2016, Jordi Baylina
    Contributor: Adri&#224; Massanet <<a href=/cdn-cgi/l/email-protection class=__cf_email__ data-cfemail=670603150e06270408030204080913021f13490e08>[email&#160;protected]</a>>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/






///  contract; it creates an escape hatch function that can be called in an
///  emergency that will allow designated addresses to send any ether or tokens
///  held in the contract to an `escapeHatchDestination` as long as they were
///  not blacklisted
contract Escapable is Owned {
    address public escapeHatchCaller;
    address public escapeHatchDestination;
    mapping (address=>bool) private escapeBlacklist; // Token contract addresses

    
    ///  `escapeHatchCaller`
    
    ///  to call `escapeHatch()` to send the ether in this contract to the
    ///  `escapeHatchDestination` it would be ideal that `escapeHatchCaller`
    ///  cannot move funds out of `escapeHatchDestination`
    
    ///  Multisig) to send the ether held in this contract; if a neutral address
    ///  is required, the WHG Multisig is an option:
    ///  0x8Ff920020c8AD673661c8117f2855C384758C572 
    function Escapable(address _escapeHatchCaller, address _escapeHatchDestination) public {
        escapeHatchCaller = _escapeHatchCaller;
        escapeHatchDestination = _escapeHatchDestination;
    }

    
    ///  are the only addresses that can call a function with this modifier
    modifier onlyEscapeHatchCallerOrOwner {
        require ((msg.sender == escapeHatchCaller)||(msg.sender == owner));
        _;
    }

    
    ///  out of the contract; can only be done at the deployment, and the logic
    ///  to add to the blacklist will be in the constructor of a child contract
    
    function blacklistEscapeToken(address _token) internal {
        escapeBlacklist[_token] = true;
        EscapeHatchBlackistedToken(_token);
    }

    
    
    
    ///  the contract via the `escapeHatch()`
    function isTokenEscapable(address _token) view public returns (bool) {
        return !escapeBlacklist[_token];
    }

    
    /// security issue is uncovered or something unexpected happened
    
    function escapeHatch(address _token) public onlyEscapeHatchCallerOrOwner {   
        require(escapeBlacklist[_token]==false);

        uint256 balance;

        
        if (_token == 0x0) {
            balance = this.balance;
            escapeHatchDestination.transfer(balance);
            EscapeHatchCalled(_token, balance);
            return;
        }
        
        ERC20 token = ERC20(_token);
        balance = token.balanceOf(this);
        require(token.transfer(escapeHatchDestination, balance));
        EscapeHatchCalled(_token, balance);
    }

    
    
    ///  contract to call `escapeHatch()` to send the value in this contract to
    ///  the `escapeHatchDestination`; it would be ideal that `escapeHatchCaller`
    ///  cannot move funds out of `escapeHatchDestination`
    function changeHatchEscapeCaller(address _newEscapeHatchCaller) public onlyEscapeHatchCallerOrOwner {
        escapeHatchCaller = _newEscapeHatchCaller;
    }

    event EscapeHatchBlackistedToken(address token);
    event EscapeHatchCalled(address token, uint amount);
}
//File: contracts/DAppNodePackageDirectory.sol
pragma solidity ^0.4.19;

/*
    Copyright 2018, Eduardo Antu&#241;a

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/




///  to install in the DAppNode




contract DAppNodePackageDirectory is Owned,Escapable {

    enum DAppNodePackageStatus {Preparing, Develop, Active, Deprecated, Deleted}

    struct DAppNodePackage {
        string name;
        DAppNodePackageStatus status;
    }

    DAppNodePackage[] DAppNodePackages;

    event PackageAdded(uint indexed idPackage, string name);
    event PackageUpdated(uint indexed idPackage, string name);
    event StatusChanged(uint idPackage, DAppNodePackageStatus newStatus);

    
    ///  `escapeHatchCaller`
    
    ///  to call `escapeHatch()` to send the ether in this contract to the
    ///  `escapeHatchDestination` it would be ideal that `escapeHatchCaller`
    ///  cannot move funds out of `escapeHatchDestination`
    
    ///  Multisig) to send the ether held in this contract; if a neutral address
    ///  is required, the WHG Multisig is an option:
    ///  0x8Ff920020c8AD673661c8117f2855C384758C572 
    function DAppNodePackageDirectory(
        address _escapeHatchCaller,
        address _escapeHatchDestination
    ) 
        Escapable(_escapeHatchCaller, _escapeHatchDestination)
        public
    {
    }

    
    
    
    function addPackage (
        string name
    ) onlyOwner public returns(uint idPackage) {
        idPackage = DAppNodePackages.length++;
        DAppNodePackage storage c = DAppNodePackages[idPackage];
        c.name = name;
        // An event to notify that a new package has been added
        PackageAdded(idPackage,name);
    }

    
    
    
    function updatePackage (
        uint idPackage,
        string name
    ) onlyOwner public {
        require(idPackage < DAppNodePackages.length);
        DAppNodePackage storage c = DAppNodePackages[idPackage];
        c.name = name;
        // An event to notify that a package has been updated
        PackageUpdated(idPackage,name);
    }

    
    
    
    function changeStatus(
        uint idPackage,
        DAppNodePackageStatus newStatus
    ) onlyOwner public {
        require(idPackage < DAppNodePackages.length);
        DAppNodePackage storage c = DAppNodePackages[idPackage];
        c.status = newStatus;
        // An event to notify that the status of a packet has been updated
        StatusChanged(idPackage, newStatus);
    }

    
    
    
    
    function getPackage(uint idPackage) constant public returns (
        string name,
        DAppNodePackageStatus status
    ) {
        require(idPackage < DAppNodePackages.length);
        DAppNodePackage storage c = DAppNodePackages[idPackage];
        name = c.name;
        status = c.status;
    }

    
    
    function numberOfDAppNodePackages() view public returns (uint) {
        return DAppNodePackages.length;
    }
}