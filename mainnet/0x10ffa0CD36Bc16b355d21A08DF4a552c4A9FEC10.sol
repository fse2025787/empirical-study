// SPDX-License-Identifier: GPL-3.0-or-later


// 
pragma solidity ^0.8.4;



interface IPermissionsRead {
    // ----------- Getters -----------

    function isBurner(address _address) external view returns (bool);

    function isMinter(address _address) external view returns (bool);

    function isGovernor(address _address) external view returns (bool);

    function isGuardian(address _address) external view returns (bool);

    function isPCVController(address _address) external view returns (bool);
}// 
pragma solidity ^0.8.4;



/** 
  @title Restricted Permissions module
  @author Fei Protocol
  @notice this contract is used to deprecate certain roles irrevocably on a contract.
  Particularly, the burner, pcv controller, and governor all revert when called.

  To use, call setCore on the target contract and set to RestrictedPermissions. By revoking the governor, a new Core cannot be set.
  This enforces that onlyGovernor, onlyBurner, and onlyPCVController actions are irrevocably disabled.

  The mint and guardian rolls pass through to the immutably referenced core contract.

  @dev IMPORTANT: fei() and tribe() calls normally present on Core are not used here, so this contract only works for contracts that don't rely on them.
*/
contract RestrictedPermissions is IPermissionsRead {

    
    IPermissionsRead public immutable core;

    constructor(IPermissionsRead _core) {
        core = _core;
    }

    
    
    
    function isMinter(address _address) external view override returns (bool) {
        return core.isMinter(_address);
    }

    
    
    
    function isGuardian(address _address) public view override returns (bool) {
        return core.isGuardian(_address);
    }

    // ---------- Deprecated roles for caller ---------

    
    function isGovernor(address) external pure override returns (bool) {
        return false;
    }

    function isPCVController(address) external pure override returns (bool) {
        revert("RestrictedPermissions: PCV Controller deprecated for contract");
    }

    function isBurner(address) external pure override returns (bool) {
        revert("RestrictedPermissions: Burner deprecated for contract");
    }
}
