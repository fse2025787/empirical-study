// SPDX-License-Identifier: LGPL-3.0-only


// 
pragma solidity 0.8.15;



/**
 * @title ILaserFactory.
 * @notice Has all the external functions, events and errors for ProxyFactory.sol.
 */

interface ILaserFactory {
    event ProxyCreation(address proxy);

    
    error LaserFactory__constructor__invalidSingleton();

    
    error LaserFactory__create2Failed();

    /**
     * @dev Creates a new proxy with create 2, initializes the wallet and refunds the relayer.
     * @param maxFeePerGas Maximum amount that the user is willing to pay for a unit of gas.
     * @param maxPriorityFeePerGas Miner's tip.
     * @param gasLimit The transaction's gas limit. It needs to be the same as the actual transaction gas limit.
     * @param relayer Address that forwards the transaction so it abstracts away the gas costs.
     * @param ownerSignature The signatures of the transaction.
     * @notice If 'gasLimit' does not match the actual gas limit of the transaction, the relayer can incur losses.
     * It is the relayer's responsability to make sure that they are the same, the user does not get affected if a mistake is made.
     * We prefer to prioritize the user's safety (not overpay) over the relayer.
     */
    function deployProxyAndRefund(
        address owner,
        uint256 maxFeePerGas,
        uint256 maxPriorityFeePerGas,
        uint256 gasLimit,
        address relayer,
        address laserModule,
        bytes calldata laserModuleData,
        uint256 saltNumber,
        bytes calldata ownerSignature
    ) external returns (LaserProxy proxy);

    /**
     * @dev Precomputes the address of a proxy that is created through 'create2'.
     */
    function preComputeAddress(
        address owner,
        address laserModule,
        bytes calldata laserModuleData,
        uint256 saltNumber
    ) external view returns (address);

    /**
     * @dev Allows to retrieve the runtime code of a deployed Proxy. This can be used to check that the expected Proxy was deployed.
     */
    function proxyRuntimeCode() external pure returns (bytes memory);

    /**
     *  @dev Allows to retrieve the creation code used for the Proxy deployment. With this it is easily possible to calculate predicted address.
     */
    function proxyCreationCode() external pure returns (bytes memory);
}
// 
pragma solidity 0.8.15;




interface ILaser {
    function init(
        address _owner,
        uint256 maxFeePerGas,
        uint256 maxPriorityFeePerGas,
        uint256 gasLimit,
        address relayer,
        address laserModule,
        bytes calldata laserModuleData,
        bytes calldata ownerSignature
    ) external;
}


contract LaserFactory is ILaserFactory {
    address public immutable singleton;

    

    constructor(address _singleton) {
        // Laser Wallet contract: bytes4(keccak256("I_AM_LASER"))
        if (!IERC165(_singleton).supportsInterface(0xae029e0b)) revert LaserFactory__constructor__invalidSingleton();
        singleton = _singleton;
    }

    
    
    
    
    
    
    
    ///It is the relayer's responsability to make sure that they are the same, the user does not get affected if a mistake is made.
    ///We prefer to prioritize the user's safety (not overpay) over the relayer.
    function deployProxyAndRefund(
        address owner,
        uint256 maxFeePerGas,
        uint256 maxPriorityFeePerGas,
        uint256 gasLimit,
        address relayer,
        address laserModule,
        bytes calldata laserModuleData,
        uint256 saltNumber,
        bytes calldata ownerSignature
    ) external returns (LaserProxy proxy) {
        bytes32 salt = getSalt(owner, laserModule, laserModuleData, saltNumber);
        proxy = createProxyWithCreate2(salt);

        ILaser(address(proxy)).init(
            owner,
            maxFeePerGas,
            maxPriorityFeePerGas,
            gasLimit,
            relayer,
            laserModule,
            laserModuleData,
            ownerSignature
        );

        emit ProxyCreation(address(proxy));
    }

    
    function preComputeAddress(
        address owner,
        address laserModule,
        bytes calldata laserModuleData,
        uint256 saltNumber
    ) external view returns (address) {
        bytes memory creationCode = proxyCreationCode();
        bytes memory data = abi.encodePacked(creationCode, uint256(uint160(singleton)));

        bytes32 salt = getSalt(owner, laserModule, laserModuleData, saltNumber);
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(data)));

        return address(uint160(uint256(hash)));
    }

    
    function proxyRuntimeCode() external pure returns (bytes memory) {
        return type(LaserProxy).runtimeCode;
    }

    
    function proxyCreationCode() public pure returns (bytes memory) {
        return type(LaserProxy).creationCode;
    }

    
    ///This method is only meant as an utility to be called from other methods.
    function createProxyWithCreate2(bytes32 salt) internal returns (LaserProxy proxy) {
        bytes memory deploymentData = abi.encodePacked(type(LaserProxy).creationCode, uint256(uint160(singleton)));
        assembly {
            proxy := create2(0x0, add(0x20, deploymentData), mload(deploymentData), salt)
        }
        //@todo change the custom error name.
        if (address(proxy) == address(0)) revert LaserFactory__create2Failed();
    }

    
    function getSalt(
        address owner,
        address laserModule,
        bytes calldata laserModuleData,
        uint256 saltNumber
    ) internal pure returns (bytes32 salt) {
        salt = keccak256(abi.encodePacked(owner, laserModule, laserModuleData, saltNumber));
    }
}

// 
pragma solidity 0.8.15;

/**
 * @title IERC165
 * @notice Support of ERC165.
 */
interface IERC165 {
    /**
     * @notice Query if a contract implements an interface
     * @param interfaceID The interface identifier, as specified in ERC-165
     * @dev Interface identification is specified in ERC-165. This function
     * uses less than 30,000 gas.
     * @return `true` if the contract implements `interfaceID` and
     * interfaceID` is not 0xffffffff, `false` otherwise
     */
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

// 
pragma solidity 0.8.15;


contract LaserProxy {
    // The singleton always needs to be at storage slot 0.
    address internal singleton;

    
    constructor(address _singleton) {
        // The proxy creation is done through the LaserProxyFactory.
        // The singleton is created at the factory's creation, so there is no need to do checks here.
        singleton = _singleton;
    }

    
    fallback() external payable {
        address _singleton = singleton;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let success := delegatecall(gas(), _singleton, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            if eq(success, 0) {
                revert(0, returndatasize())
            }
            return(0, returndatasize())
        }
    }
}