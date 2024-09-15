
/* ERC820: Pseudo-introspection Registry Contract
 * by Jordi Baylina and Jacques Dafflon
 *
 * To the extent possible under law, Jordi Baylina and Jacques Dafflon who
 * associated CC0 with the ERC820: Pseudo-introspection Registry Contract have
 * waived all copyright and related or neighboring rights to the
 * ERC820: Pseudo-introspection Registry Contract.
 *
 * You should have received a copy of the CC0 legalcode along with this work.
 * If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
 *
 *    ███████╗██████╗  ██████╗ █████╗ ██████╗  ██████╗
 *    ██╔════╝██╔══██╗██╔════╝██╔══██╗╚════██╗██╔═████╗
 *    █████╗  ██████╔╝██║     ╚█████╔╝ █████╔╝██║██╔██║
 *    ██╔══╝  ██╔══██╗██║     ██╔══██╗██╔═══╝ ████╔╝██║
 *    ███████╗██║  ██║╚██████╗╚█████╔╝███████╗╚██████╔╝
 *    ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚════╝ ╚══════╝ ╚═════╝
 *
 *    ██████╗ ███████╗ ██████╗ ██╗███████╗████████╗██████╗ ██╗   ██╗
 *    ██╔══██╗██╔════╝██╔════╝ ██║██╔════╝╚══██╔══╝██╔══██╗╚██╗ ██╔╝
 *    ██████╔╝█████╗  ██║  ███╗██║███████╗   ██║   ██████╔╝ ╚████╔╝
 *    ██╔══██╗██╔══╝  ██║   ██║██║╚════██║   ██║   ██╔══██╗  ╚██╔╝
 *    ██║  ██║███████╗╚██████╔╝██║███████║   ██║   ██║  ██║   ██║
 *    ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝
 *
 */
pragma solidity 0.4.24;
// IV is value needed to have a vanity address starting with `0x820`.
// IV: 2241


/// some (other) interface for any address other than itself.
interface ERC820ImplementerInterface {
    
    
    
    
    function canImplementInterfaceForAddress(address addr, bytes32 interfaceHash) public view returns(bytes32);
}






contract ERC820Registry {
    
    bytes4 constant INVALID_ID = 0xffffffff;
    
    bytes4 constant ERC165ID = 0x01ffc9a7;
    
    bytes32 constant ERC820_ACCEPT_MAGIC = keccak256(abi.encodePacked("ERC820_ACCEPT_MAGIC"));

    mapping (address => mapping(bytes32 => address)) interfaces;
    mapping (address => address) managers;
    mapping (address => mapping(bytes4 => bool)) erc165Cached;

    
    event InterfaceImplementerSet(address indexed addr, bytes32 indexed interfaceHash, address indexed implementer);
    
    event ManagerChanged(address indexed addr, address indexed newManager);

    
    
    /// (If `_addr == 0` then `msg.sender` is assumed.)
    
    /// E.g., `web3.utils.keccak256('ERC777Token')`.
    
    /// or `0x0` if `_addr` did not register an implementer for this interface.
    function getInterfaceImplementer(address _addr, bytes32 _interfaceHash) external view returns (address) {
        address addr = _addr == 0 ? msg.sender : _addr;
        if (isERC165Interface(_interfaceHash)) {
            bytes4 erc165InterfaceHash = bytes4(_interfaceHash);
            return implementsERC165Interface(addr, erc165InterfaceHash) ? addr : 0;
        }
        return interfaces[addr][_interfaceHash];
    }

    
    /// Only the manager defined for that address can set it.
    /// (Each address is the manager for itself until it sets a new manager.)
    
    
    /// For example, `web3.utils.keccak256('ERC777TokensRecipient')` for the `ERC777TokensRecipient` interface.
    function setInterfaceImplementer(address _addr, bytes32 _interfaceHash, address _implementer) external {
        address addr = _addr == 0 ? msg.sender : _addr;
        require(getManager(addr) == msg.sender, "Not the manager");

        require(!isERC165Interface(_interfaceHash), "Must not be a ERC165 hash");
        if (_implementer != 0 && _implementer != msg.sender) {
            require(
                ERC820ImplementerInterface(_implementer)
                    .canImplementInterfaceForAddress(addr, _interfaceHash) == ERC820_ACCEPT_MAGIC,
                "Does not implement the interface"
            );
        }
        interfaces[addr][_interfaceHash] = _implementer;
        emit InterfaceImplementerSet(addr, _interfaceHash, _implementer);
    }

    
    /// The new manager will be able to call `setInterfaceImplementer` for `_addr`.
    
    
    function setManager(address _addr, address _newManager) external {
        address addr = _addr == 0 ? msg.sender : _addr;
        require(getManager(addr) == msg.sender, "Not the manager");
        managers[addr] = _newManager == addr ? 0 : _newManager;
        emit ManagerChanged(addr, _newManager);
    }

    
    
    
    function getManager(address _addr) public view returns(address) {
        // By default the manager of an address is the same address
        if (managers[_addr] == 0) {
            return _addr;
        } else {
            return managers[_addr];
        }
    }

    
    
    
    function interfaceHash(string _interfaceName) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_interfaceName));
    }

    /* --- ERC165 Related Functions --- */

    
    /// The result is cached. If the cache is out of date, it must be updated by calling `updateERC165Cache`.
    
    
    
    
    /// modifier since `getInterfaceImplementer` also calls it. If called from within a transaction, the ERC165 cache
    /// is updated.
    function implementsERC165Interface(address _contract, bytes4 _interfaceId) public view returns (bool) {
        if (!erc165Cached[_contract][_interfaceId]) {
            updateERC165Cache(_contract, _interfaceId);
        }
        return interfaces[_contract][_interfaceId] != 0;
    }

    
    
    
    function updateERC165Cache(address _contract, bytes4 _interfaceId) public {
        interfaces[_contract][_interfaceId] = implementsERC165InterfaceNoCache(_contract, _interfaceId) ? _contract : 0;
        erc165Cached[_contract][_interfaceId] = true;
    }

    
    
    
    
    function implementsERC165InterfaceNoCache(address _contract, bytes4 _interfaceId) public view returns (bool) {
        uint256 success;
        uint256 result;

        (success, result) = noThrowCall(_contract, ERC165ID);
        if (success == 0 || result == 0) {
            return false;
        }

        (success, result) = noThrowCall(_contract, INVALID_ID);
        if (success == 0 || result != 0) {
            return false;
        }

        (success, result) = noThrowCall(_contract, _interfaceId);
        if (success == 1 && result == 1) {
            return true;
        }
        return false;
    }

    
    
    
    function isERC165Interface(bytes32 _interfaceHash) internal pure returns (bool) {
        return _interfaceHash & 0x00000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0;
    }

    function noThrowCall(address _contract, bytes4 _interfaceId)
        internal view returns (uint256 success, uint256 result)
    {
        bytes4 erc165ID = ERC165ID;

        assembly {
                let x := mload(0x40)               // Find empty storage location using "free memory pointer"
                mstore(x, erc165ID)                // Place signature at begining of empty storage
                mstore(add(x, 0x04), _interfaceId) // Place first argument directly next to signature

                success := staticcall(
                    30000,                         // 30k gas
                    _contract,                     // To addr
                    x,                             // Inputs are stored at location x
                    0x08,                          // Inputs are 8 bytes long
                    x,                             // Store output over input (saves space)
                    0x20                           // Outputs are 32 bytes long
                )

                result := mload(x)                 // Load the result
        }
    }
}