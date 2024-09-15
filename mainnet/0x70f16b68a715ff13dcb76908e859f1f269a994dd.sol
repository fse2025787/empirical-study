// SPDX-License-Identifier: MIT


// 
pragma solidity ^0.8.10;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This ownership interface matches OZ's ownable interface.
 *
 */
interface IOwnable {
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() external view returns (address);
}
// 
pragma solidity ^0.8.10;

interface IFactoryUpgradeGate {
  function isValidUpgradePath(address _newImpl, address _currentImpl) external returns (bool);

  function registerNewUpgradePath(address _newImpl, address[] calldata _supportedPrevImpls) external;

  function unregisterUpgradePath(address _newImpl, address _prevImpl) external;
}

// 
pragma solidity ^0.8.10;



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This ownership interface matches OZ's ownable interface.
 */
contract OwnableSkeleton is IOwnable {
    address private _owner;

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _setOwner(address newAddress) internal {
        emit OwnershipTransferred(_owner, newAddress);
        _owner = newAddress;
    }
}
// 
pragma solidity ^0.8.10;




/**

 ________   _____   ____    ______      ____
/\_____  \ /\  __`\/\  _`\ /\  _  \    /\  _`\
\/____//'/'\ \ \/\ \ \ \L\ \ \ \L\ \   \ \ \/\ \  _ __   ___   _____     ____
     //'/'  \ \ \ \ \ \ ,  /\ \  __ \   \ \ \ \ \/\`'__\/ __`\/\ '__`\  /',__\
    //'/'___ \ \ \_\ \ \ \\ \\ \ \/\ \   \ \ \_\ \ \ \//\ \L\ \ \ \L\ \/\__, `\
    /\_______\\ \_____\ \_\ \_\ \_\ \_\   \ \____/\ \_\\ \____/\ \ ,__/\/\____/
    \/_______/ \/_____/\/_/\/ /\/_/\/_/    \/___/  \/_/ \/___/  \ \ \/  \/___/
                                                                 \ \_\
                                                                  \/_/

 */


contract FactoryUpgradeGate is IFactoryUpgradeGate, OwnableSkeleton {
    
    mapping(address => mapping(address => bool)) private _validUpgradePaths;

    
    event UpgradePathRegistered(address newImpl, address oldImpl);

    
    event UpgradePathRemoved(address newImpl, address oldImpl);

    
    error Access_OnlyOwner();

    
    modifier onlyOwner() {
        if (msg.sender != owner()) {
            revert Access_OnlyOwner();
        }

        _;
    }

    
    
    constructor(address _owner) {
        _setOwner(_owner);
    }

    
    
    
    function isValidUpgradePath(address _newImpl, address _currentImpl)
        external
        view
        returns (bool)
    {
        return _validUpgradePaths[_newImpl][_currentImpl];
    }

    
    
    
    function registerNewUpgradePath(
        address _newImpl,
        address[] calldata _supportedPrevImpls
    ) external onlyOwner {
        for (uint256 i = 0; i < _supportedPrevImpls.length; i++) {
            _validUpgradePaths[_newImpl][_supportedPrevImpls[i]] = true;
            emit UpgradePathRegistered(_newImpl, _supportedPrevImpls[i]);
        }
    }

    
    
    
    function unregisterUpgradePath(address _newImpl, address _prevImpl)
        external
        onlyOwner
    {
        _validUpgradePaths[_newImpl][_prevImpl] = false;
        emit UpgradePathRemoved(_newImpl, _prevImpl);
    }
}
