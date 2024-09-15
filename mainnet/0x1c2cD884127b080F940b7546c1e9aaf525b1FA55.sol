// SPDX-License-Identifier: MIT

// 
pragma solidity ^0.8.15;

// Gnosis Safe Proxy Factory interface extracted from the mainnet: https://etherscan.io/address/0xa6b71e26c5e0845f74c812102ca7114b6a896ab2#code#F2#L61
interface IGnosisSafeProxyFactory {
    
    
    
    
    function createProxyWithNonce(
        address _singleton,
        bytes memory initializer,
        uint256 saltNonce
    ) external returns (address proxy);
}



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
        multisig = IGnosisSafeProxyFactory(gnosisSafeProxyFactory).createProxyWithNonce(gnosisSafe, safeParams, nonce);
    }
}