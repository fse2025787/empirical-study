

pragma solidity ^0.5.0;




contract Ownable {

    
    bytes32 private constant masterPosition = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    
    
    
    constructor(address masterAddress) public {
        setMaster(masterAddress);
    }

    
    
    function requireMaster(address _address) internal view {
        require(_address == getMaster(), "oro11"); // oro11 - only by master
    }

    
    
    function getMaster() public view returns (address master) {
        bytes32 position = masterPosition;
        assembly {
            master := sload(position)
        }
    }

    
    
    function setMaster(address _newMaster) internal {
        bytes32 position = masterPosition;
        assembly {
            sstore(position, _newMaster)
        }
    }

    
    
    function transferMastership(address _newMaster) external {
        requireMaster(msg.sender);
        require(_newMaster != address(0), "otp11"); // otp11 - new masters address can't be zero address
        setMaster(_newMaster);
    }

}

pragma solidity ^0.5.0;





interface Upgradeable {

    
    
    
    function upgradeTarget(address newTarget, bytes calldata newTargetInitializationParameters) external;

}

pragma solidity ^0.5.0;





interface UpgradeableMaster {

    
    function getNoticePeriod() external returns (uint);

    
    function upgradeNoticePeriodStarted() external;

    
    function upgradePreparationStarted() external;

    
    function upgradeCanceled() external;

    
    function upgradeFinishes() external;

    
    
    function isReadyForUpgrade() external returns (bool);

}
pragma solidity ^0.5.0;










contract Proxy is Upgradeable, UpgradeableMaster, Ownable {

    
    bytes32 private constant targetPosition = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    
    
    
    
    constructor(address target, bytes memory targetInitializationParameters) Ownable(msg.sender) public {
        setTarget(target);
        (bool initializationSuccess, ) = getTarget().delegatecall(
            abi.encodeWithSignature("initialize(bytes)", targetInitializationParameters)
        );
        require(initializationSuccess, "uin11"); // uin11 - target initialization failed
    }

    
    function initialize(bytes calldata) external pure {
        revert("ini11"); // ini11 - interception of initialization call
    }

    
    function upgrade(bytes calldata) external pure {
        revert("upg11"); // upg11 - interception of upgrade call
    }

    
    
    function getTarget() public view returns (address target) {
        bytes32 position = targetPosition;
        assembly {
            target := sload(position)
        }
    }

    
    
    function setTarget(address _newTarget) internal {
        bytes32 position = targetPosition;
        assembly {
            sstore(position, _newTarget)
        }
    }

    
    
    
    function upgradeTarget(address newTarget, bytes calldata newTargetUpgradeParameters) external {
        requireMaster(msg.sender);

        setTarget(newTarget);
        (bool upgradeSuccess, ) = getTarget().delegatecall(
            abi.encodeWithSignature("upgrade(bytes)", newTargetUpgradeParameters)
        );
        require(upgradeSuccess, "ufu11"); // ufu11 - target upgrade failed
    }

    
    
    /// This function will return whatever the implementation call returns
    function() external payable {
        address _target = getTarget();
        assembly {
            // The pointer to the free memory slot
            let ptr := mload(0x40)
            // Copy function signature and arguments from calldata at zero position into memory at pointer position
            calldatacopy(ptr, 0x0, calldatasize)
            // Delegatecall method of the implementation contract, returns 0 on error
            let result := delegatecall(
                gas,
                _target,
                ptr,
                calldatasize,
                0x0,
                0
            )
            // Get the size of the last return data
            let size := returndatasize
            // Copy the size length of bytes from return data at zero position to pointer position
            returndatacopy(ptr, 0x0, size)
            // Depending on result value
            switch result
            case 0 {
                // End execution and revert state changes
                revert(ptr, size)
            }
            default {
                // Return data with length of size at pointers position
                return(ptr, size)
            }
        }
    }

    /// UpgradeableMaster functions

    
    function getNoticePeriod() external returns (uint) {
        (bool success, bytes memory result) = getTarget().delegatecall(abi.encodeWithSignature("getNoticePeriod()"));
        require(success, "unp11"); // unp11 - upgradeNoticePeriod delegatecall failed
        return abi.decode(result, (uint));
    }

    
    function upgradeNoticePeriodStarted() external {
        requireMaster(msg.sender);
        (bool success, ) = getTarget().delegatecall(abi.encodeWithSignature("upgradeNoticePeriodStarted()"));
        require(success, "nps11"); // nps11 - upgradeNoticePeriodStarted delegatecall failed
    }

    
    function upgradePreparationStarted() external {
        requireMaster(msg.sender);
        (bool success, ) = getTarget().delegatecall(abi.encodeWithSignature("upgradePreparationStarted()"));
        require(success, "ups11"); // ups11 - upgradePreparationStarted delegatecall failed
    }

    
    function upgradeCanceled() external {
        requireMaster(msg.sender);
        (bool success, ) = getTarget().delegatecall(abi.encodeWithSignature("upgradeCanceled()"));
        require(success, "puc11"); // puc11 - upgradeCanceled delegatecall failed
    }

    
    function upgradeFinishes() external {
        requireMaster(msg.sender);
        (bool success, ) = getTarget().delegatecall(abi.encodeWithSignature("upgradeFinishes()"));
        require(success, "puf11"); // puf11 - upgradeFinishes delegatecall failed
    }

    
    
    function isReadyForUpgrade() external returns (bool) {
        (bool success, bytes memory result) = getTarget().delegatecall(abi.encodeWithSignature("isReadyForUpgrade()"));
        require(success, "rfu11"); // rfu11 - readyForUpgrade delegatecall failed
        return abi.decode(result, (bool));
    }

}
