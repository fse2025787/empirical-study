pragma experimental ABIEncoderV2;


contract TokenEvents {
    
    
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    
    event MinterChanged(address indexed oldMinter, address indexed newMinter);

    
    event Transfer(address indexed from, address indexed to, uint256 amount);

    
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    
    event NewImplementation(address oldImplementation, address newImplementation);

    
    event TransferPaused(address indexed minter);

    
    event TransferUnpaused(address indexed minter);

    
    event ChangedSymbol(string oldSybmol, string newSybmol);

    
    event ChangedName(string oldName, string newName);
}

contract TokenDelegatorStorage {
    
    IndexInterface constant public instaIndex = IndexInterface(0x2971AdFa57b20E5a416aE5a708A8655A9c74f723);

    
    address public implementation;

    
    string public name = "Instadapp";

    
    string public symbol = "INST";

    
    uint public totalSupply;

    
    uint8 public constant decimals = 18;

    modifier isMaster() {
        require(instaIndex.master() == msg.sender, "Tkn::isMaster: msg.sender not master");
        _;
    }
}
pragma solidity ^0.7.0;




contract InstaToken is TokenDelegatorStorage, TokenEvents {
    constructor(
        address account,
        address implementation_,
        uint initialSupply_,
        uint mintingAllowedAfter_,
        bool transferPaused_
    ) {
        require(implementation_ != address(0), "TokenDelegator::constructor invalid address");
        delegateTo(
            implementation_,
            abi.encodeWithSignature(
                "initialize(address,uint256,uint256,bool)",
                account,
                initialSupply_,
                mintingAllowedAfter_,
                transferPaused_
            )
        );

        implementation = implementation_;

        emit NewImplementation(address(0), implementation);
    }

    /**
     * @notice Called by the admin to update the implementation of the delegator
     * @param implementation_ The address of the new implementation for delegation
     */
    function _setImplementation(address implementation_) external isMaster {
        require(implementation_ != address(0), "TokenDelegator::_setImplementation: invalid implementation address");

        address oldImplementation = implementation;
        implementation = implementation_;

        emit NewImplementation(oldImplementation, implementation);
    }

    /**
     * @notice Internal method to delegate execution to another contract
     * @dev It returns to the external caller whatever the implementation returns or forwards reverts
     * @param callee The contract to delegatecall
     * @param data The raw data to delegatecall
     */
    function delegateTo(address callee, bytes memory data) internal {
        (bool success, bytes memory returnData) = callee.delegatecall(data);
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize())
            }
        }
    }

    /**
     * @dev Delegates execution to an implementation contract.
     * It returns to the external caller whatever the implementation returns
     * or forwards reverts.
     */
    fallback () external payable {
        // delegate all other functions to current implementation
        (bool success, ) = implementation.delegatecall(msg.data);

        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize())

            switch success
            case 0 { revert(free_mem_ptr, returndatasize()) }
            default { return(free_mem_ptr, returndatasize()) }
        }
    }
}

pragma solidity ^0.7.0;


interface IndexInterface {
    function master() external view returns (address);
}

/**
 * @title Storage for Token Delegate
 * @notice For future upgrades, do not change TokenDelegateStorageV1. Create a new
 * contract which implements TokenDelegateStorageV1 and following the naming convention
 * TokenDelegateStorageVX.
 */
contract TokenDelegateStorageV1 is TokenDelegatorStorage {
    
    uint public mintingAllowedAfter;

    
    bool public transferPaused;

    // Allowance amounts on behalf of others
    mapping (address => mapping (address => uint96)) internal allowances;

    // Official record of token balances for each account
    mapping (address => uint96) internal balances;

    
    mapping (address => address) public delegates;

    
    struct Checkpoint {
        uint32 fromBlock;
        uint96 votes;
    }

    
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    
    mapping (address => uint32) public numCheckpoints;

    
    mapping (address => uint) public nonces;
}
