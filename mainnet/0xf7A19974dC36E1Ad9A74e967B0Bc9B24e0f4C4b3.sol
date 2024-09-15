// SPDX-License-Identifier: MIT

// 
// OpenZeppelin Contracts v4.4.0 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// 
// OpenZeppelin Contracts v4.4.0 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;



/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// 
pragma solidity 0.8.9;



interface IBaseValidator {
    
    
    struct ValidatorParams {
        IProtocolGovernance protocolGovernance;
    }

    
    function stagedValidatorParams() external view returns (ValidatorParams memory);

    
    function stagedValidatorParamsTimestamp() external view returns (uint256);

    
    function validatorParams() external view returns (ValidatorParams memory);

    
    
    function stageValidatorParams(ValidatorParams calldata newParams) external;

    
    function commitValidatorParams() external;
}

// 
// OpenZeppelin Contracts v4.4.0 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// 
pragma solidity 0.8.9;

interface IContractMeta {
    function contractName() external view returns (string memory);
    function contractNameBytes() external view returns (bytes32);

    function contractVersion() external view returns (string memory);
    function contractVersionBytes() external view returns (bytes32);
}

// 
pragma solidity 0.8.9;



interface IDefaultAccessControl is IAccessControlEnumerable {
    
    
    
    function isAdmin(address who) external view returns (bool);

    
    
    
    function isOperator(address who) external view returns (bool);
}

// 
// OpenZeppelin Contracts v4.4.0 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;



/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// 
pragma solidity 0.8.9;




interface IValidator is IBaseValidator, IERC165 {
    // @notice Validate if call can be made to external contract.
    // @dev Reverts if validation failed. Returns nothing if validation is ok
    // @param sender Sender of the externalCall method
    // @param addr Address of the called contract
    // @param value Ether value for the call
    // @param selector Selector of the called method
    // @param data Call data after selector
    function validate(
        address sender,
        address addr,
        uint256 value,
        bytes4 selector,
        bytes calldata data
    ) external view;
}

// 
pragma solidity 0.8.9;





contract BaseValidator is IBaseValidator {
    IBaseValidator.ValidatorParams internal _validatorParams;
    IBaseValidator.ValidatorParams internal _stagedValidatorParams;
    uint256 internal _stagedValidatorParamsTimestamp;

    constructor(IProtocolGovernance protocolGovernance) {
        _validatorParams = IBaseValidator.ValidatorParams({protocolGovernance: protocolGovernance});
    }

    // -------------------  EXTERNAL, VIEW  -------------------

    
    function stagedValidatorParams() external view returns (ValidatorParams memory) {
        return _stagedValidatorParams;
    }

    
    function stagedValidatorParamsTimestamp() external view returns (uint256) {
        return _stagedValidatorParamsTimestamp;
    }

    
    function validatorParams() external view returns (ValidatorParams memory) {
        return _validatorParams;
    }

    // -------------------  EXTERNAL, MUTATING  -------------------

    
    
    function stageValidatorParams(IBaseValidator.ValidatorParams calldata newParams) external {
        IProtocolGovernance governance = _validatorParams.protocolGovernance;
        require(governance.isAdmin(msg.sender), ExceptionsLibrary.FORBIDDEN);
        _stagedValidatorParams = newParams;
        _stagedValidatorParamsTimestamp = block.timestamp + governance.governanceDelay();
        emit StagedValidatorParams(tx.origin, msg.sender, newParams, _stagedValidatorParamsTimestamp);
    }

    
    function commitValidatorParams() external {
        require(_stagedValidatorParamsTimestamp != 0, ExceptionsLibrary.INVALID_STATE);
        IProtocolGovernance governance = _validatorParams.protocolGovernance;
        require(governance.isAdmin(msg.sender), ExceptionsLibrary.FORBIDDEN);
        require(block.timestamp >= _stagedValidatorParamsTimestamp, ExceptionsLibrary.TIMESTAMP);
        _validatorParams = _stagedValidatorParams;
        delete _stagedValidatorParams;
        delete _stagedValidatorParamsTimestamp;
        emit CommittedValidatorParams(tx.origin, msg.sender, _validatorParams);
    }

    
    
    
    
    
    event StagedValidatorParams(
        address indexed origin,
        address indexed sender,
        IBaseValidator.ValidatorParams newParams,
        uint256 when
    );

    
    
    
    
    event CommittedValidatorParams(
        address indexed origin,
        address indexed sender,
        IBaseValidator.ValidatorParams params
    );
}

// 
pragma solidity 0.8.9;




interface IUnitPricesGovernance is IDefaultAccessControl, IERC165 {
    // -------------------  EXTERNAL, VIEW  -------------------

    
    
    
    function stagedUnitPrices(address token) external view returns (uint256);

    
    
    
    function stagedUnitPricesTimestamps(address token) external view returns (uint256);

    
    
    
    function unitPrices(address token) external view returns (uint256);

    // -------------------  EXTERNAL, MUTATING  -------------------

    
    
    
    function stageUnitPrice(address token, uint256 value) external;

    
    
    function rollbackUnitPrice(address token) external;

    
    
    function commitUnitPrice(address token) external;
}

// 
pragma solidity 0.8.9;



abstract contract ContractMeta is IContractMeta {
    // -------------------  EXTERNAL, VIEW  -------------------

    function contractName() external pure returns (string memory) {
        return _bytes32ToString(_contractName());
    }

    function contractNameBytes() external pure returns (bytes32) {
        return _contractName();
    }

    function contractVersion() external pure returns (string memory) {
        return _bytes32ToString(_contractVersion());
    }

    function contractVersionBytes() external pure returns (bytes32) {
        return _contractVersion();
    }

    // -------------------  INTERNAL, VIEW  -------------------

    function _contractName() internal pure virtual returns (bytes32);

    function _contractVersion() internal pure virtual returns (bytes32);

    function _bytes32ToString(bytes32 b) internal pure returns (string memory s) {
        s = new string(32);
        uint256 len = 32;
        for (uint256 i = 0; i < 32; ++i) {
            if (uint8(b[i]) == 0) {
                len = i;
                break;
            }
        }
        assembly {
            mstore(s, len)
            mstore(add(s, 0x20), b)
        }
    }
}

// 
pragma solidity 0.8.9;





abstract contract Validator is IValidator, ERC165, BaseValidator {
    
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return (interfaceId == type(IValidator).interfaceId) || super.supportsInterface(interfaceId);
    }
}
// 
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// 
pragma solidity 0.8.9;




interface IProtocolGovernance is IDefaultAccessControl, IUnitPricesGovernance {
    
    
    
    
    
    
    struct Params {
        uint256 maxTokensPerVault;
        uint256 governanceDelay;
        address protocolTreasury;
        uint256 forceAllowMask;
        uint256 withdrawLimit;
    }

    // -------------------  EXTERNAL, VIEW  -------------------

    
    
    
    function stagedPermissionGrantsTimestamps(address target) external view returns (uint256);

    
    
    
    function stagedPermissionGrantsMasks(address target) external view returns (uint256);

    
    
    
    function permissionMasks(address target) external view returns (uint256);

    
    
    function stagedParamsTimestamp() external view returns (uint256);

    
    function stagedParams() external view returns (Params memory);

    
    function params() external view returns (Params memory);

    
    function permissionAddresses() external view returns (address[] memory);

    
    function stagedPermissionGrantsAddresses() external view returns (address[] memory);

    
    
    
    function addressesByPermission(uint8 permissionId) external view returns (address[] memory);

    
    
    
    function hasPermission(address addr, uint8 permissionId) external view returns (bool);

    
    
    
    function hasAllPermissions(address target, uint8[] calldata permissionIds) external view returns (bool);

    
    function maxTokensPerVault() external view returns (uint256);

    
    function governanceDelay() external view returns (uint256);

    
    function protocolTreasury() external view returns (address);

    
    /// This bitmask is xored with ordinary mask.
    function forceAllowMask() external view returns (uint256);

    
    
    
    function withdrawLimit(address token) external view returns (uint256);

    
    function stagedValidatorsAddresses() external view returns (address[] memory);

    
    
    
    function stagedValidatorsTimestamps(address target) external view returns (uint256);

    
    
    
    function stagedValidators(address target) external view returns (address);

    
    function validatorsAddresses() external view returns (address[] memory);

    
    
    
    function validatorsAddress(uint256 i) external view returns (address);

    
    
    
    function validators(address target) external view returns (address);

    // -------------------  EXTERNAL, MUTATING, GOVERNANCE, IMMEDIATE  -------------------

    
    function rollbackStagedValidators() external;

    
    
    function revokeValidator(address target) external;

    
    
    
    function stageValidator(address target, address validator) external;

    
    
    
    function commitValidator(address target) external;

    
    
    function commitAllValidatorsSurpassedDelay() external returns (address[] memory);

    
    function rollbackStagedPermissionGrants() external;

    
    
    
    function commitPermissionGrants(address target) external;

    
    
    function commitAllPermissionGrantsSurpassedDelay() external returns (address[] memory);

    
    
    
    function revokePermissions(address target, uint8[] memory permissionIds) external;

    
    /// Reverts if governance delay has not passed yet.
    function commitParams() external;

    // -------------------  EXTERNAL, MUTATING, GOVERNANCE, DELAY  -------------------

    
    
    function stageParams(Params memory newParams) external;

    
    /// Resets commit delay and permissions if there are already staged permissions for this address.
    
    
    function stagePermissionGrants(address target, uint8[] memory permissionIds) external;
}

// 
pragma solidity 0.8.9;


library ExceptionsLibrary {
    string constant ADDRESS_ZERO = "AZ";
    string constant VALUE_ZERO = "VZ";
    string constant EMPTY_LIST = "EMPL";
    string constant NOT_FOUND = "NF";
    string constant INIT = "INIT";
    string constant DUPLICATE = "DUP";
    string constant NULL = "NULL";
    string constant TIMESTAMP = "TS";
    string constant FORBIDDEN = "FRB";
    string constant ALLOWLIST = "ALL";
    string constant LIMIT_OVERFLOW = "LIMO";
    string constant LIMIT_UNDERFLOW = "LIMU";
    string constant INVALID_VALUE = "INV";
    string constant INVARIANT = "INVA";
    string constant INVALID_TARGET = "INVTR";
    string constant INVALID_TOKEN = "INVTO";
    string constant INVALID_INTERFACE = "INVI";
    string constant INVALID_SELECTOR = "INVS";
    string constant INVALID_STATE = "INVST";
    string constant INVALID_LENGTH = "INVL";
    string constant LOCK = "LCKD";
    string constant DISABLED = "DIS";
}

//
pragma solidity 0.8.9;


library PermissionIdsLibrary {
    // The msg.sender is allowed to register vault
    uint8 constant REGISTER_VAULT = 0;
    // The msg.sender is allowed to create vaults
    uint8 constant CREATE_VAULT = 1;
    // The token is allowed to be transfered by vault
    uint8 constant ERC20_TRANSFER = 2;
    // The token is allowed to be added to vault
    uint8 constant ERC20_VAULT_TOKEN = 3;
    // Trusted protocols that are allowed to be approved of vault ERC20 tokens by any strategy
    uint8 constant ERC20_APPROVE = 4;
    // Trusted protocols that are allowed to be approved of vault ERC20 tokens by trusted strategy
    uint8 constant ERC20_APPROVE_RESTRICTED = 5;
    // Strategy allowed using restricted API
    uint8 constant TRUSTED_STRATEGY = 6;
}

// 
pragma solidity 0.8.9;








contract ERC20Validator is ContractMeta, Validator {
    bytes4 public constant APPROVE_SELECTOR = IERC20.approve.selector;

    constructor(IProtocolGovernance protocolGovernance_) BaseValidator(protocolGovernance_) {}

    // -------------------  EXTERNAL, VIEW  -------------------

    // @inhericdoc IValidator
    function validate(
        address sender,
        address addr,
        uint256 value,
        bytes4 selector,
        bytes calldata data
    ) external view {
        require(value == 0, ExceptionsLibrary.INVALID_VALUE);
        if (selector == APPROVE_SELECTOR) {
            address spender;
            assembly {
                spender := calldataload(data.offset)
            }
            _verifyApprove(sender, addr, spender);
        } else {
            revert(ExceptionsLibrary.INVALID_SELECTOR);
        }
    }

    // -------------------  INTERNAL, VIEW  -------------------

    function _contractName() internal pure override returns (bytes32) {
        return bytes32("ERC20Validator");
    }

    function _contractVersion() internal pure override returns (bytes32) {
        return bytes32("1.0.0");
    }

    function _verifyApprove(
        address sender,
        address token,
        address spender
    ) private view {
        IProtocolGovernance protocolGovernance = _validatorParams.protocolGovernance;
        if (!protocolGovernance.hasPermission(token, PermissionIdsLibrary.ERC20_TRANSFER)) {
            revert(ExceptionsLibrary.FORBIDDEN);
        }
        if (protocolGovernance.hasPermission(spender, PermissionIdsLibrary.ERC20_APPROVE)) {
            return;
        }
        if (
            protocolGovernance.hasPermission(spender, PermissionIdsLibrary.ERC20_APPROVE_RESTRICTED) &&
            protocolGovernance.hasPermission(sender, PermissionIdsLibrary.TRUSTED_STRATEGY)
        ) {
            return;
        }
        revert(ExceptionsLibrary.FORBIDDEN);
    }
}
