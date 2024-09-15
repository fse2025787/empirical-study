// SPDX-License-Identifier: WTFPL


// 
pragma solidity >=0.8.4;




/// account (an owner) that can be granted exclusive access to specific functions.
///
/// By default, the owner account will be the one that deploys the contract. This can later be
/// changed with {transfer}.
///
/// This module is used through inheritance. It will make available the modifier `onlyOwner`,
/// which can be applied to your functions to restrict their use to the owner.
///

/// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/access/Ownable.sol
interface IOwnable {
    /// EVENTS ///

    
    
    
    event TransferOwnership(address indexed oldOwner, address indexed newOwner);

    /// NON-CONSTANT FUNCTIONS ///

    
    /// functions anymore.
    ///
    /// WARNING: Doing this will leave the contract without an owner, thereby removing any
    /// functionality that is only available to the owner.
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    function renounceOwnership() external;

    
    /// called by the current owner.
    
    function transferOwnership(address newOwner) external;

    /// CONSTANT FUNCTIONS ///

    
    
    function owner() external view returns (address);
}

// 
pragma solidity >=0.8.4;






interface IPRBProxy is IOwnable {
    /// EVENTS ///

    event Execute(address indexed target, bytes data, bytes response);

    /// PUBLIC CONSTANT FUNCTIONS ///

    
    function minGasReserve() external view returns (uint256);

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    /// the data it gets back, including when the contract call reverts with a reason or custom error.
    ///
    
    /// - The caller must be the owner.
    /// - `target` must be a contract.
    ///
    
    
    
    function execute(address target, bytes memory data) external payable returns (bytes memory response);

    
    ///
    
    ///
    /// Requirements:
    /// - Can only be called once.
    ///
    
    function initialize(address owner_) external;

    
    
    /// - The caller must be the owner.
    function setMinGasReserve(uint256 newMinGasReserve) external;
}

// 
pragma solidity >=0.8.4;




error Ownable__NotOwner(address owner, address caller);


error Ownable__OwnerZeroAddress();



contract Ownable is IOwnable {
    /// PUBLIC STORAGE ///

    
    address public override owner;

    /// MODIFIERS ///

    
    modifier onlyOwner() {
        if (owner != msg.sender) {
            revert Ownable__NotOwner(owner, msg.sender);
        }
        _;
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    function renounceOwnership() external virtual override onlyOwner {
        owner = address(0);
        emit TransferOwnership(owner, address(0));
    }

    
    function transferOwnership(address newOwner) external virtual override onlyOwner {
        setOwner(newOwner);
    }

    /// INTERNAL NON-CONSTANT FUNCTIONS ///
    function setOwner(address newOwner) internal virtual {
        if (newOwner == address(0)) {
            revert Ownable__OwnerZeroAddress();
        }
        owner = newOwner;
        emit TransferOwnership(owner, newOwner);
    }
}
// 
pragma solidity >=0.8.4;





error PRBProxy__AlreadyInitialized();


error PRBProxy__ExecutionReverted();


error PRBProxy__TargetInvalid(address target);


error PRBProxy__TargetZeroAddress();



contract PRBProxy is
    IPRBProxy, // One dependency
    Ownable // One dependency
{
    /// PUBLIC STORAGE ///

    
    uint256 public override minGasReserve;

    /// INTERNAL STORAGE ///

    
    bool internal initialized;

    /// CONSTRUCTOR ///

    
    /// can be called post deployment. This eliminates the risk of an accidental self destruct.
    constructor() {
        initialized = true;
        owner = address(0);
    }

    /// FALLBACK FUNCTION ///

    
    receive() external payable {
        // solhint-disable-previous-line no-empty-blocks
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    function initialize(address owner_) external override {
        // Checks
        if (initialized) {
            revert PRBProxy__AlreadyInitialized();
        }

        // Effects
        initialized = true;
        minGasReserve = 5000;
        setOwner(owner_);
    }

    
    function execute(address target, bytes memory data)
        external
        payable
        override
        onlyOwner
        returns (bytes memory response)
    {
        // Check that the target is not the zero address.
        if (target == address(0)) {
            revert PRBProxy__TargetZeroAddress();
        }

        // Check that the target is a valid contract.
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(target)
        }
        if (codeSize == 0) {
            revert PRBProxy__TargetInvalid(target);
        }

        // Ensure that there will remain enough gas after the DELEGATECALL.
        uint256 stipend = gasleft() - minGasReserve;

        // Delegate call to the target contract.
        bool success;
        (success, response) = target.delegatecall{ gas: stipend }(data);

        // Log the execution.
        emit Execute(target, data, response);

        // Check if the call was successful or not.
        if (!success) {
            // If there is return data, the call reverted with a reason or a custom error.
            if (response.length > 0) {
                assembly {
                    let returndata_size := mload(response)
                    revert(add(32, response), returndata_size)
                }
            } else {
                revert PRBProxy__ExecutionReverted();
            }
        }
    }

    
    function setMinGasReserve(uint256 newMinGasReserve) external override onlyOwner {
        minGasReserve = newMinGasReserve;
    }
}
