// SPDX-License-Identifier: Apache-2.0


// 
/*

  Modifications Copyright 2022 Element.Market
  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.8.13;






abstract contract FixinCommon {

    
    address internal immutable _implementation;

    
    modifier onlySelf() virtual {
        if (msg.sender != address(this)) {
            revert("ONLY_CALL_BY_SELF_ERROR");
        }
        _;
    }

    
    modifier onlyOwner() virtual {
        {
            address owner = IOwnableFeature(address(this)).owner();
            if (msg.sender != owner) {
                revert("ONLY_OWNER_ERROR");
            }
        }
        _;
    }

    constructor() {
        // Remember this feature's original address.
        _implementation = address(this);
    }

    
    ///      Can and should only be called within a `migrate()`.
    
    ///        is at `_implementation`.
    function _registerFeatureFunction(bytes4 selector) internal {
        ISimpleFunctionRegistryFeature(address(this)).extend(selector, _implementation);
    }

    
    
    
    
    
    function _encodeVersion(uint32 major, uint32 minor, uint32 revision)
        internal
        pure
        returns (uint256 encodedVersion)
    {
        return (uint256(major) << 64) | (uint256(minor) << 32) | uint256(revision);
    }
}

// 
/*

  Modifications Copyright 2022 Element.Market
  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.8.13;



interface IFeature {

    // solhint-disable func-name-mixedcase

    
    function FEATURE_NAME() external view returns (string memory name);

    
    function FEATURE_VERSION() external view returns (uint256 version);
}

// 
/*

  Modifications Copyright 2022 Element.Market
  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.8.13;



interface ISimpleFunctionRegistryFeature {

    
    
    
    
    event ProxyFunctionUpdated(bytes4 indexed selector, address oldImpl, address newImpl);

    function registerMethods(address impl, bytes4[] calldata methodIDs) external;

    
    
    
    function rollback(bytes4 selector, address targetImpl) external;

    
    
    
    function extend(bytes4 selector, address impl) external;

    
    
    
    ///         the function.
    function getRollbackLength(bytes4 selector) external view returns (uint256);

    
    
    
    
    ///         index `idx`.
    function getRollbackEntryAtIndex(bytes4 selector, uint256 idx)
        external
        view
        returns (address impl);
}
// 
/*

  Modifications Copyright 2022 Element.Market
  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.8.13;










contract SimpleFunctionRegistryFeature is
    IFeature,
    ISimpleFunctionRegistryFeature,
    FixinCommon
{
    
    string public constant override FEATURE_NAME = "SimpleFunctionRegistry";
    
    uint256 public immutable override FEATURE_VERSION = _encodeVersion(1, 0, 0);

    
    
    function bootstrap() external returns (bytes4 success) {
        _extend(this.registerMethods.selector, _implementation);
        // Register the registration functions (inception vibes).
        _extend(this.extend.selector, _implementation);
        _extend(this._extendSelf.selector, _implementation);
        // Register the rollback function.
        _extend(this.rollback.selector, _implementation);
        // Register getters.
        _extend(this.getRollbackLength.selector, _implementation);
        _extend(this.getRollbackEntryAtIndex.selector, _implementation);
        return LibBootstrap.BOOTSTRAP_SUCCESS;
    }

    function registerMethods(address impl, bytes4[] calldata methodIDs)
        external
        override
        onlyOwner
    {
        (
            LibSimpleFunctionRegistryStorage.Storage storage stor,
            LibProxyStorage.Storage storage proxyStor
        ) = _getStorages();

        for (uint256 i = 0; i < methodIDs.length; i++) {
            bytes4 selector = methodIDs[i];
            address oldImpl = proxyStor.impls[selector];
            address[] storage history = stor.implHistory[selector];
            history.push(oldImpl);
            proxyStor.impls[selector] = impl;
            emit ProxyFunctionUpdated(selector, oldImpl, impl);
        }
    }

    
    ///      Only directly callable by an authority.
    
    
    function rollback(bytes4 selector, address targetImpl) external override onlyOwner {
        (
            LibSimpleFunctionRegistryStorage.Storage storage stor,
            LibProxyStorage.Storage storage proxyStor
        ) = _getStorages();

        address currentImpl = proxyStor.impls[selector];
        if (currentImpl == targetImpl) {
            // Do nothing if already at targetImpl.
            return;
        }
        // Walk history backwards until we find the target implementation.
        address[] storage history = stor.implHistory[selector];
        uint256 i = history.length;
        for (; i > 0; --i) {
            address impl = history[i - 1];
            history.pop();
            if (impl == targetImpl) {
                break;
            }
        }
        if (i == 0) {
            revert("NOT_IN_ROLLBACK_HISTORY");
        }
        proxyStor.impls[selector] = targetImpl;
        emit ProxyFunctionUpdated(selector, currentImpl, targetImpl);
    }

    
    ///      Only directly callable by an authority.
    
    
    function extend(bytes4 selector, address impl) external override onlyOwner {
        _extend(selector, impl);
    }

    
    ///      Only callable from within.
    ///      This function is only used during the bootstrap process and
    ///      should be deregistered by the deployer after bootstrapping is
    ///      complete.
    
    
    function _extendSelf(bytes4 selector, address impl) external onlySelf {
        _extend(selector, impl);
    }

    
    
    
    ///         the function.
    function getRollbackLength(bytes4 selector) external override view returns (uint256) {
        return LibSimpleFunctionRegistryStorage.getStorage().implHistory[selector].length;
    }

    
    
    
    
    ///         index `idx`.
    function getRollbackEntryAtIndex(bytes4 selector, uint256 idx)
        external
        override
        view
        returns (address impl)
    {
        return LibSimpleFunctionRegistryStorage.getStorage().implHistory[selector][idx];
    }

    
    
    
    function _extend(bytes4 selector, address impl) private {
        (
            LibSimpleFunctionRegistryStorage.Storage storage stor,
            LibProxyStorage.Storage storage proxyStor
        ) = _getStorages();

        address oldImpl = proxyStor.impls[selector];
        address[] storage history = stor.implHistory[selector];
        history.push(oldImpl);
        proxyStor.impls[selector] = impl;
        emit ProxyFunctionUpdated(selector, oldImpl, impl);
    }

    
    
    
    function _getStorages()
        private
        pure
        returns (
            LibSimpleFunctionRegistryStorage.Storage storage stor,
            LibProxyStorage.Storage storage proxyStor
        )
    {
        return (
            LibSimpleFunctionRegistryStorage.getStorage(),
            LibProxyStorage.getStorage()
        );
    }
}

// 
/*

  Modifications Copyright 2022 Element.Market
  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.8.13;





library LibProxyStorage {

    
    struct Storage {
        // Mapping of function selector -> function implementation
        mapping(bytes4 => address) impls;
    }

    
    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.STORAGE_ID_PROXY;
        // Dip into assembly to change the slot pointed to by the local
        // variable `stor`.
        // See https://solidity.readthedocs.io/en/v0.6.8/assembly.html?highlight=slot#access-to-external-variables-functions-and-libraries
        assembly { stor.slot := storageSlot }
    }
}

// 
/*

  Modifications Copyright 2022 Element.Market
  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.8.13;





library LibSimpleFunctionRegistryStorage {

    
    struct Storage {
        // Mapping of function selector -> implementation history.
        mapping(bytes4 => address[]) implHistory;
    }

    
    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.STORAGE_ID_SIMPLE_FUNCTION_REGISTRY;
        // Dip into assembly to change the slot pointed to by the local
        // variable `stor`.
        // See https://solidity.readthedocs.io/en/v0.6.8/assembly.html?highlight=slot#access-to-external-variables-functions-and-libraries
        assembly { stor.slot := storageSlot }
    }
}

// 
/*

  Modifications Copyright 2022 Element.Market
  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.8.13;

library LibBootstrap {

    
    ///      This is `keccack('BOOTSTRAP_SUCCESS')`.
    bytes4 internal constant BOOTSTRAP_SUCCESS = 0xd150751b;

    
    
    
    function delegatecallBootstrapFunction(address target, bytes memory data) internal {
        (bool success, bytes memory resultData) = target.delegatecall(data);
        if (!success ||
            resultData.length != 32 ||
            abi.decode(resultData, (bytes4)) != BOOTSTRAP_SUCCESS)
        {
            revert("BOOTSTRAP_CALL_FAILED");
        }
    }
}

// 
/*

  Modifications Copyright 2022 Element.Market
  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.8.13;


// solhint-disable no-empty-blocks

interface IOwnableFeature {

    
    
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    
    
    
    event Migrated(address caller, address migrator, address newOwner);

    
    
    function transferOwnership(address newOwner) external;

    
    
    function owner() external view returns (address ownerAddress);

    
    ///      The result of the function being called should be the magic bytes
    ///      0x2c64c5ef (`keccack('MIGRATE_SUCCESS')`). Only callable by the owner.
    ///      The owner will be temporarily set to `address(this)` inside the call.
    ///      Before returning, the owner will be set to `newOwner`.
    
    
    
    function migrate(address target, bytes calldata data, address newOwner) external;
}

// 
/*

  Modifications Copyright 2022 Element.Market
  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.8.13;



library LibStorage {

    
    ///      This gives us a maximum of 2**128 inline fields in each bucket.
    uint256 constant STORAGE_ID_PROXY = 1 << 128;
    uint256 constant STORAGE_ID_SIMPLE_FUNCTION_REGISTRY = 2 << 128;
    uint256 constant STORAGE_ID_OWNABLE = 3 << 128;
    uint256 constant STORAGE_ID_COMMON_NFT_ORDERS = 4 << 128;
    uint256 constant STORAGE_ID_ERC721_ORDERS = 5 << 128;
    uint256 constant STORAGE_ID_ERC1155_ORDERS = 6 << 128;
}