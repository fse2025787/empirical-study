// SPDX-License-Identifier: MIT

// 
pragma solidity >=0.8.17;



interface IAvoSafe {
    function _avoWalletImpl() external view returns (address);
}



///             Basic Proxy with fallback to delegate and address for implementation contract at storage 0x0

///             Relayers might want to pass in version as new param then to forward to the correct factory
contract AvoSafe {
    
    
    ///         when upgrading, the storage at memory address 0x0 is upgraded (first slot).
    ///         To reduce deployment costs this variable is internal but can still be retrieved with
    ///         _avoWalletImpl(), see code and comments in fallback below
    address internal _avoWalletImpl;

    
    
    constructor() {
        // "\x8e\x7d\xaf\x69" is hardcoded bytes of function selector for avoWalletImpl()
        (bool success_, bytes memory data_) = msg.sender.call(bytes("\x8e\x7d\xaf\x69"));

        address avoWalletImpl_;
        assembly {
            // cast last 20 bytes of hash to address
            avoWalletImpl_ := mload(add(data_, 32))
        }

        if (!success_ || avoWalletImpl_.code.length == 0) {
            revert();
        }

        _avoWalletImpl = avoWalletImpl_;
    }

    
    ///         if _avoWalletImpl() is called then the address for _avoWalletImpl is returned
    
    fallback() external payable {
        assembly {
            // load address avoWalletImpl_ from storage
            let avoWalletImpl_ := and(sload(0), 0xffffffffffffffffffffffffffffffffffffffff)

            // first 4 bytes of calldata specify which function to call.
            // if those first 4 bytes == 87e9052a (function selector for _avoWalletImpl()) then we return the _avoWalletImpl address
            // The value is right padded to 32-bytes with 0s
            if eq(calldataload(0), 0x87e9052a00000000000000000000000000000000000000000000000000000000) {
                mstore(0, avoWalletImpl_) // store address avoWalletImpl_ at memory address 0x0
                return(0, 0x20) // send first 20 bytes of address at memory address 0x0
            }

            // @dev code below is taken from OpenZeppelin Proxy.sol _delegate function

            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), avoWalletImpl_, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}