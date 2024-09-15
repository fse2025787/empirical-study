// SPDX-License-Identifier: MIT

/* ERC5050 Proxy Registry Contract
 *
 * ███████╗██████╗  ██████╗███████╗ ██████╗ ███████╗ ██████╗      
 * ██╔════╝██╔══██╗██╔════╝██╔════╝██╔═████╗██╔════╝██╔═████╗     
 * █████╗  ██████╔╝██║     ███████╗██║██╔██║███████╗██║██╔██║     
 * ██╔══╝  ██╔══██╗██║     ╚════██║████╔╝██║╚════██║████╔╝██║     
 * ███████╗██║  ██║╚██████╗███████║╚██████╔╝███████║╚██████╔╝     
 * ╚══════╝╚═╝  ╚═╝ ╚═════╝╚══════╝ ╚═════╝ ╚══════╝ ╚═════╝      
 *                                                                
 * ██████╗ ███████╗ ██████╗ ██╗███████╗████████╗██████╗ ██╗   ██╗ 
 * ██╔══██╗██╔════╝██╔════╝ ██║██╔════╝╚══██╔══╝██╔══██╗╚██╗ ██╔╝ 
 * ██████╔╝█████╗  ██║  ███╗██║███████╗   ██║   ██████╔╝ ╚████╔╝  
 * ██╔══██╗██╔══╝  ██║   ██║██║╚════██║   ██║   ██╔══██╗  ╚██╔╝   
 * ██║  ██║███████╗╚██████╔╝██║███████║   ██║   ██║  ██║   ██║    
 * ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝  
 *
 */
// 

pragma solidity ^0.8.6;


/// some (other) interface for any address other than itself.
interface ERC5050ProxyImplementerInterface {
    
    
    
    
    function canImplementInterfaceForAddress(bytes4 interfaceHash, address addr) external view returns(bytes32);
}




contract ERC5050ProxyRegistry {
    
    bytes32 constant internal ERC5050_ACCEPT_MAGIC = keccak256(abi.encodePacked("ERC5050_ACCEPT_MAGIC"));

    
    mapping(address => mapping(bytes4 => address)) internal interfaces;
    
    mapping(address => address) internal managers;
    
    mapping(address => bool) internal disallowedOwnerManagers;

    
    event InterfaceImplementerSet(address indexed addr, bytes32 indexed interfaceHash, address indexed implementer);
    
    event ManagerChanged(address indexed addr, address indexed newManager);

    
    
    /// (If '_addr' is the zero address then 'msg.sender' is assumed.)
    
    
    /// or '0' if '_addr' did not register an implementer for this interface.
    function getInterfaceImplementer(address _addr, bytes4 _interfaceId) external view returns (address) {
        address addr = _addr == address(0) ? msg.sender : _addr;
        if(interfaces[addr][_interfaceId] != address(0)) {
            return interfaces[addr][_interfaceId];
        }
        return _addr;
    }

    
    /// Only the manager defined for that address can set it.
    /// (Each address is the manager for itself until it sets a new manager.)
    
    /// (If '_addr' is the zero address then 'msg.sender' is assumed.)
    
    
    function setInterfaceImplementer(address _addr, bytes4 _interfaceId, address _implementer) external {
        address addr = _addr == address(0) ? msg.sender : _addr;
        require(getManager(addr) == msg.sender || getOwner(_addr) == msg.sender, "Not the manager");
        if (_implementer != address(0) && _implementer != msg.sender) {
            require(
                ERC5050ProxyImplementerInterface(_implementer)
                    .canImplementInterfaceForAddress(_interfaceId, addr) == ERC5050_ACCEPT_MAGIC,
                "Does not implement the interface"
            );
        }
        interfaces[addr][_interfaceId] = _implementer;
        emit InterfaceImplementerSet(addr, _interfaceId, _implementer);
    }

    
    /// The new manager will be able to call 'setInterfaceImplementer' for '_addr'.
    
    
    function setManager(address _addr, address _newManager) external {
        require(getManager(_addr) == msg.sender || getOwner(_addr) == msg.sender, "Not the manager");
        managers[_addr] = _newManager == _addr ? address(0) : _newManager;
        emit ManagerChanged(_addr, _newManager);
    }

    
    
    
    function getManager(address _addr) public view returns(address) {
        // By default the manager of an address is the same address
        if (managers[_addr] == address(0)) {
            return _addr;
        } else {
            return managers[_addr];
        }
    }
    
    
    
    
    function getOwner(address _addr) internal view returns (address) {
        if(disallowedOwnerManagers[_addr]) {
            return _addr;
        }
        (bool success, bytes memory returnData) = _addr.staticcall(
            abi.encodeWithSignature("owner()")
        );
        if(success){
            return abi.decode(returnData, (address));
        }
        return _addr;
    }
    
    
    /// by a contract that implements `owner()` and does not want to allow the owner to set
    /// the manager.
    function disallowOwner() external {
        disallowedOwnerManagers[msg.sender] = true;
    }
}
// IV is a value changed to generate the vanity address.
// IV: 69795