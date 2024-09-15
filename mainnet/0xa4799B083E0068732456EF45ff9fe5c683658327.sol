// SPDX-License-Identifier: MIT

// 
pragma solidity ^0.8.15;






contract GnosisSafeMultisig {
    // Selector of the Gnosis Safe setup function
    bytes4 internal constant _GNOSIS_SAFE_SETUP_SELECTOR = 0xb63e800d;
    // Gnosis Safe
    address payable public immutable gnosisSafe;
    // Gnosis Safe Factory
    address public immutable gnosisSafeProxyFactory;

    
    
    
    constructor (address payable _gnosisSafe, address _gnosisSafeProxyFactory) {
        gnosisSafe = _gnosisSafe;
        gnosisSafeProxyFactory = _gnosisSafeProxyFactory;
    }

    
    
    function _parseData(bytes memory data) internal pure
        returns (address to, address fallbackHandler, address paymentToken, address payable paymentReceiver,
            uint256 payment, uint256 nonce, bytes memory payload)
    {
        if (data.length > 0) {
            uint256 dataSize = data.length;
            assembly {
                // Read all the addresses first
                let offset := 20
                to := mload(add(data, offset))
                offset := add(offset, 20)
                fallbackHandler := mload(add(data, offset))
                offset := add(offset, 20)
                paymentToken := mload(add(data, offset))
                offset := add(offset, 20)
                paymentReceiver := mload(add(data, offset))

                // Read all the uints
                offset := add(offset, 32)
                payment := mload(add(data, offset))
                offset := add(offset, 32)
                nonce := mload(add(data, offset))

                // Read the payload data
                payload := mload(add(data, dataSize))
            }
        }
    }

    
    
    
    
    
    function create(
        address[] memory owners,
        uint256 threshold,
        bytes memory data
    ) external returns (address multisig)
    {
        // Parse the data into gnosis-specific set of variables
        (address to, address fallbackHandler, address paymentToken, address payable paymentReceiver, uint256 payment,
            uint256 nonce, bytes memory payload) = _parseData(data);

        // Encode the gmosis setup function parameters
        bytes memory safeParams = abi.encodeWithSelector(_GNOSIS_SAFE_SETUP_SELECTOR, owners, threshold,
            to, payload, fallbackHandler, paymentToken, payment, paymentReceiver);

        // Create a gnosis safe multisig via the proxy factory
        GnosisSafeProxyFactory gFactory = GnosisSafeProxyFactory(gnosisSafeProxyFactory);
        GnosisSafeProxy gProxy = gFactory.createProxyWithNonce(gnosisSafe, safeParams, nonce);
        multisig = address(gProxy);
    }
}

// 
pragma solidity >=0.7.0 <0.9.0;



interface IProxy {
    function masterCopy() external view returns (address);
}




contract GnosisSafeProxy {
    // singleton always needs to be first declared variable, to ensure that it is at the same location in the contracts to which calls are delegated.
    // To reduce deployment costs this variable is internal and needs to be retrieved via `getStorageAt`
    address internal singleton;

    
    
    constructor(address _singleton) {
        require(_singleton != address(0), "Invalid singleton address provided");
        singleton = _singleton;
    }

    
    fallback() external payable {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let _singleton := and(sload(0), 0xffffffffffffffffffffffffffffffffffffffff)
            // 0xa619486e == keccak("masterCopy()"). The value is right padded to 32-bytes with 0s
            if eq(calldataload(0), 0xa619486e00000000000000000000000000000000000000000000000000000000) {
                mstore(0, _singleton)
                return(0, 0x20)
            }
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

// 
pragma solidity >=0.7.0 <0.9.0;






contract GnosisSafeProxyFactory {
    event ProxyCreation(GnosisSafeProxy proxy, address singleton);

    
    
    
    function createProxy(address singleton, bytes memory data) public returns (GnosisSafeProxy proxy) {
        proxy = new GnosisSafeProxy(singleton);
        if (data.length > 0)
            // solhint-disable-next-line no-inline-assembly
            assembly {
                if eq(call(gas(), proxy, 0, add(data, 0x20), mload(data), 0, 0), 0) {
                    revert(0, 0)
                }
            }
        emit ProxyCreation(proxy, singleton);
    }

    
    function proxyRuntimeCode() public pure returns (bytes memory) {
        return type(GnosisSafeProxy).runtimeCode;
    }

    
    function proxyCreationCode() public pure returns (bytes memory) {
        return type(GnosisSafeProxy).creationCode;
    }

    
    ///      This method is only meant as an utility to be called from other methods
    
    
    
    function deployProxyWithNonce(
        address _singleton,
        bytes memory initializer,
        uint256 saltNonce
    ) internal returns (GnosisSafeProxy proxy) {
        // If the initializer changes the proxy address should change too. Hashing the initializer data is cheaper than just concatinating it
        bytes32 salt = keccak256(abi.encodePacked(keccak256(initializer), saltNonce));
        bytes memory deploymentData = abi.encodePacked(type(GnosisSafeProxy).creationCode, uint256(uint160(_singleton)));
        // solhint-disable-next-line no-inline-assembly
        assembly {
            proxy := create2(0x0, add(0x20, deploymentData), mload(deploymentData), salt)
        }
        require(address(proxy) != address(0), "Create2 call failed");
    }

    
    
    
    
    function createProxyWithNonce(
        address _singleton,
        bytes memory initializer,
        uint256 saltNonce
    ) public returns (GnosisSafeProxy proxy) {
        proxy = deployProxyWithNonce(_singleton, initializer, saltNonce);
        if (initializer.length > 0)
            // solhint-disable-next-line no-inline-assembly
            assembly {
                if eq(call(gas(), proxy, 0, add(initializer, 0x20), mload(initializer), 0, 0), 0) {
                    revert(0, 0)
                }
            }
        emit ProxyCreation(proxy, _singleton);
    }

    
    
    
    
    
    function createProxyWithCallback(
        address _singleton,
        bytes memory initializer,
        uint256 saltNonce,
        IProxyCreationCallback callback
    ) public returns (GnosisSafeProxy proxy) {
        uint256 saltNonceWithCallback = uint256(keccak256(abi.encodePacked(saltNonce, callback)));
        proxy = createProxyWithNonce(_singleton, initializer, saltNonceWithCallback);
        if (address(callback) != address(0)) callback.proxyCreated(proxy, _singleton, initializer, saltNonce);
    }

    
    ///      This method is only meant for address calculation purpose when you use an initializer that would revert,
    ///      therefore the response is returned with a revert. When calling this method set `from` to the address of the proxy factory.
    
    
    
    function calculateCreateProxyWithNonceAddress(
        address _singleton,
        bytes calldata initializer,
        uint256 saltNonce
    ) external returns (GnosisSafeProxy proxy) {
        proxy = deployProxyWithNonce(_singleton, initializer, saltNonce);
        revert(string(abi.encodePacked(proxy)));
    }
}

// 
pragma solidity >=0.7.0 <0.9.0;


interface IProxyCreationCallback {
    function proxyCreated(
        GnosisSafeProxy proxy,
        address _singleton,
        bytes calldata initializer,
        uint256 saltNonce
    ) external;
}