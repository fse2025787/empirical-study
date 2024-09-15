// SPDX-License-Identifier: GPL-3.0


// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;




abstract contract GlobalConfigProxyConstants {
    // `bytes32(keccak256('mln.proxiable.globalConfigLib'))`
    bytes32
        internal constant EIP_1822_PROXIABLE_UUID = 0xf25d88d51901d7fabc9924b03f4c2fe4300e6fe1aae4b5134c0a90b68cd8e81c;
    // `bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)`
    bytes32
        internal constant EIP_1967_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
}
// 

/*
    This file is part of the Enzyme Protocol.
    (c) Enzyme Council <[email protected]>
    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;








/// and using the EIP-1967 storage slot for the proxiable implementation.
/// See: https://eips.ethereum.org/EIPS/eip-1822
/// See: https://eips.ethereum.org/EIPS/eip-1967
contract GlobalConfigProxy is GlobalConfigProxyConstants {
    constructor(bytes memory _constructData, address _globalConfigLib) public {
        // Validate constants
        require(
            EIP_1822_PROXIABLE_UUID == bytes32(keccak256("mln.proxiable.globalConfigLib")),
            "constructor: Invalid EIP_1822_PROXIABLE_UUID"
        );
        require(
            EIP_1967_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1),
            "constructor: Invalid EIP_1967_SLOT"
        );

        require(
            ProxiableGlobalConfigLib(_globalConfigLib).proxiableUUID() == EIP_1822_PROXIABLE_UUID,
            "constructor: _globalConfigLib not compatible"
        );

        assembly {
            sstore(EIP_1967_SLOT, _globalConfigLib)
        }

        (bool success, bytes memory returnData) = _globalConfigLib.delegatecall(_constructData);
        require(success, string(returnData));
    }

    fallback() external payable {
        assembly {
            let contractLogic := sload(EIP_1967_SLOT)
            calldatacopy(0x0, 0x0, calldatasize())
            let success := delegatecall(
                sub(gas(), 10000),
                contractLogic,
                0x0,
                calldatasize(),
                0,
                0
            )
            let retSz := returndatasize()
            returndatacopy(0, 0, retSz)
            switch success
                case 0 {
                    revert(0, retSz)
                }
                default {
                    return(0, retSz)
                }
        }
    }
}

// 

/*
    This file is part of the Enzyme Protocol.
    (c) Enzyme Council <[email protected]>
    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;







/// See: https://eips.ethereum.org/EIPS/eip-1822
/// See: https://eips.ethereum.org/EIPS/eip-1967
abstract contract ProxiableGlobalConfigLib is GlobalConfigProxyConstants {
    
    function __updateCodeAddress(address _nextGlobalConfigLib) internal {
        require(
            ProxiableGlobalConfigLib(_nextGlobalConfigLib).proxiableUUID() ==
                bytes32(EIP_1822_PROXIABLE_UUID),
            "__updateCodeAddress: _nextGlobalConfigLib not compatible"
        );
        assembly {
            sstore(EIP_1967_SLOT, _nextGlobalConfigLib)
        }
    }

    
    
    function proxiableUUID() public pure returns (bytes32 uuid_) {
        return EIP_1822_PROXIABLE_UUID;
    }
}