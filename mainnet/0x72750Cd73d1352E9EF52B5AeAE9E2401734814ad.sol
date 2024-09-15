// SPDX-License-Identifier: MIT OR Apache-2.0


pragma solidity ^0.8.0;

// 



interface IAllowList {
    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/

    
    event UpdatePublicAccess(address indexed target, bool newStatus);

    
    event UpdateCallPermission(address indexed caller, address indexed target, bytes4 indexed functionSig, bool status);

    
    
    event NewPendingOwner(address indexed oldPendingOwner, address indexed newPendingOwner);

    
    event NewOwner(address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            GETTERS
    //////////////////////////////////////////////////////////////*/

    function pendingOwner() external view returns (address);

    function owner() external view returns (address);

    function isAccessPublic(address _target) external view returns (bool);

    function hasSpecialAccessToCall(
        address _caller,
        address _target,
        bytes4 _functionSig
    ) external view returns (bool);

    function canCall(
        address _caller,
        address _target,
        bytes4 _functionSig
    ) external view returns (bool);

    /*//////////////////////////////////////////////////////////////
                           ALLOW LIST LOGIC
    //////////////////////////////////////////////////////////////*/

    function setBatchPublicAccess(address[] calldata _targets, bool[] calldata _enables) external;

    function setPublicAccess(address _target, bool _enable) external;

    function setBatchPermissionToCall(
        address[] calldata _callers,
        address[] calldata _targets,
        bytes4[] calldata _functionSigs,
        bool[] calldata _enables
    ) external;

    function setPermissionToCall(
        address _caller,
        address _target,
        bytes4 _functionSig,
        bool _enable
    ) external;

    function setPendingOwner(address _newPendingOwner) external;

    function acceptOwner() external;
}
pragma solidity ^0.8.0;

// 










/// - Access list of (caller address, target address, function to call, boolean value of permission to call)
/// - Access list to call any function from the target contract by any caller
/// If the target contract is in the second list, then it is automatically available for calling any function.
/// Otherwise, it checks whether the caller has access to call the contract from the first list.
contract AllowList is IAllowList {
    using UncheckedMath for uint256;

    
    address public pendingOwner;

    
    address public owner;

    
    mapping(address => bool) public isAccessPublic;

    
    
    mapping(address => mapping(address => mapping(bytes4 => bool))) public hasSpecialAccessToCall;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "kx");
        _;
    }

    
    
    
    
    function canCall(
        address _caller,
        address _target,
        bytes4 _functionSig
    ) external view returns (bool) {
        return isAccessPublic[_target] || hasSpecialAccessToCall[_caller][_target][_functionSig];
    }

    
    
    
    function setPublicAccess(address _target, bool _enable) external onlyOwner {
        _setPublicAccess(_target, _enable);
    }

    
    
    
    
    function setBatchPublicAccess(address[] calldata _targets, bool[] calldata _enables) external onlyOwner {
        uint256 targetsLength = _targets.length;
        require(targetsLength == _enables.length, "yg"); // The size of arrays should be equal

        for (uint256 i = 0; i < targetsLength; i = i.uncheckedInc()) {
            _setPublicAccess(_targets[i], _enables[i]);
        }
    }

    
    function _setPublicAccess(address _target, bool _enable) internal {
        bool isEnabled = isAccessPublic[_target];

        if (isEnabled != _enable) {
            isAccessPublic[_target] = _enable;
            emit UpdatePublicAccess(_target, _enable);
        }
    }

    
    
    
    
    
    function setBatchPermissionToCall(
        address[] calldata _callers,
        address[] calldata _targets,
        bytes4[] calldata _functionSigs,
        bool[] calldata _enables
    ) external onlyOwner {
        uint256 callersLength = _callers.length;
        require(
            callersLength == _targets.length &&
                callersLength == _functionSigs.length &&
                callersLength == _enables.length,
            "yw"
        ); // The size of arrays should be equal

        for (uint256 i = 0; i < callersLength; i = i.uncheckedInc()) {
            _setPermissionToCall(_callers[i], _targets[i], _functionSigs[i], _enables[i]);
        }
    }

    
    
    
    
    
    function setPermissionToCall(
        address _caller,
        address _target,
        bytes4 _functionSig,
        bool _enable
    ) external onlyOwner {
        _setPermissionToCall(_caller, _target, _functionSig, _enable);
    }

    
    function _setPermissionToCall(
        address _caller,
        address _target,
        bytes4 _functionSig,
        bool _enable
    ) internal {
        bool currentPermission = hasSpecialAccessToCall[_caller][_target][_functionSig];

        if (currentPermission != _enable) {
            hasSpecialAccessToCall[_caller][_target][_functionSig] = _enable;
            emit UpdateCallPermission(_caller, _target, _functionSig, _enable);
        }
    }

    
    
    
    function setPendingOwner(address _newPendingOwner) external onlyOwner {
        // Save previous value into the stack to put it into the event later
        address oldPendingOwner = pendingOwner;

        if (oldPendingOwner != _newPendingOwner) {
            // Change pending owner
            pendingOwner = _newPendingOwner;

            emit NewPendingOwner(oldPendingOwner, _newPendingOwner);
        }
    }

    
    function acceptOwner() external {
        address newOwner = pendingOwner;
        require(msg.sender == newOwner, "n0"); // Only proposed by current owner address can claim the owner rights

        if (newOwner != owner) {
            owner = newOwner;
            delete pendingOwner;

            emit NewPendingOwner(newOwner, address(0));
            emit NewOwner(newOwner);
        }
    }
}

pragma solidity ^0.8.0;

// 



library UncheckedMath {
    function uncheckedInc(uint256 _number) internal pure returns (uint256) {
        unchecked {
            return _number + 1;
        }
    }

    function uncheckedAdd(uint256 _lhs, uint256 _rhs) internal pure returns (uint256) {
        unchecked {
            return _lhs + _rhs;
        }
    }
}