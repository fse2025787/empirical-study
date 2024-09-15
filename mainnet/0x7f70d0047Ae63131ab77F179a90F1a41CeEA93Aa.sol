pragma experimental ABIEncoderV2;

/**
 *Submitted for verification at Etherscan.io on 2021-11-30
*/

// File: contracts/components/Proxy.sol

/*

  Copyright 2019 Wanchain Foundation.

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

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.24;

/**
 * Math operations with safety checks
 */


contract Proxy {

    event Upgraded(address indexed implementation);

    address internal _implementation;

    function implementation() public view returns (address) {
        return _implementation;
    }

    function () external payable {
        address _impl = _implementation;
        require(_impl != address(0), "implementation contract not set");

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}

// File: contracts/components/Owned.sol

/*

  Copyright 2019 Wanchain Foundation.

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

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.24;


///  later changed
contract Owned {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    /// modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    address public owner;

    
    constructor() public {
        owner = msg.sender;
    }

    address public newOwner;

    function transferOwner(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    
    
    ///  an unowned neutral vault, however that cannot be undone
    function changeOwner(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        if (msg.sender == newOwner) {
            owner = newOwner;
        }
    }

    function renounceOwnership() public onlyOwner {
        owner = address(0);
    }
}

// File: contracts/components/Halt.sol

/*

  Copyright 2019 Wanchain Foundation.

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

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.24;


contract Halt is Owned {

    bool public halted = false;

    modifier notHalted() {
        require(!halted, "Smart contract is halted");
        _;
    }

    modifier isHalted() {
        require(halted, "Smart contract is not halted");
        _;
    }

    
    
    function setHalt(bool halt)
        public
        onlyOwner
    {
        halted = halt;
    }
}

// File: contracts/components/ReentrancyGuard.sol

pragma solidity 0.4.26;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}

// File: contracts/lib/BasicStorageLib.sol

pragma solidity ^0.4.24;

library BasicStorageLib {

    struct UintData {
        mapping(bytes => mapping(bytes => uint))           _storage;
    }

    struct BoolData {
        mapping(bytes => mapping(bytes => bool))           _storage;
    }

    struct AddressData {
        mapping(bytes => mapping(bytes => address))        _storage;
    }

    struct BytesData {
        mapping(bytes => mapping(bytes => bytes))          _storage;
    }

    struct StringData {
        mapping(bytes => mapping(bytes => string))         _storage;
    }

    /* uintStorage */

    function setStorage(UintData storage self, bytes memory key, bytes memory innerKey, uint value) internal {
        self._storage[key][innerKey] = value;
    }

    function getStorage(UintData storage self, bytes memory key, bytes memory innerKey) internal view returns (uint) {
        return self._storage[key][innerKey];
    }

    function delStorage(UintData storage self, bytes memory key, bytes memory innerKey) internal {
        delete self._storage[key][innerKey];
    }

    /* boolStorage */

    function setStorage(BoolData storage self, bytes memory key, bytes memory innerKey, bool value) internal {
        self._storage[key][innerKey] = value;
    }

    function getStorage(BoolData storage self, bytes memory key, bytes memory innerKey) internal view returns (bool) {
        return self._storage[key][innerKey];
    }

    function delStorage(BoolData storage self, bytes memory key, bytes memory innerKey) internal {
        delete self._storage[key][innerKey];
    }

    /* addressStorage */

    function setStorage(AddressData storage self, bytes memory key, bytes memory innerKey, address value) internal {
        self._storage[key][innerKey] = value;
    }

    function getStorage(AddressData storage self, bytes memory key, bytes memory innerKey) internal view returns (address) {
        return self._storage[key][innerKey];
    }

    function delStorage(AddressData storage self, bytes memory key, bytes memory innerKey) internal {
        delete self._storage[key][innerKey];
    }

    /* bytesStorage */

    function setStorage(BytesData storage self, bytes memory key, bytes memory innerKey, bytes memory value) internal {
        self._storage[key][innerKey] = value;
    }

    function getStorage(BytesData storage self, bytes memory key, bytes memory innerKey) internal view returns (bytes memory) {
        return self._storage[key][innerKey];
    }

    function delStorage(BytesData storage self, bytes memory key, bytes memory innerKey) internal {
        delete self._storage[key][innerKey];
    }

    /* stringStorage */

    function setStorage(StringData storage self, bytes memory key, bytes memory innerKey, string memory value) internal {
        self._storage[key][innerKey] = value;
    }

    function getStorage(StringData storage self, bytes memory key, bytes memory innerKey) internal view returns (string memory) {
        return self._storage[key][innerKey];
    }

    function delStorage(StringData storage self, bytes memory key, bytes memory innerKey) internal {
        delete self._storage[key][innerKey];
    }

}

// File: contracts/components/BasicStorage.sol

pragma solidity ^0.4.24;


contract BasicStorage {
    /************************************************************
     **
     ** VARIABLES
     **
     ************************************************************/

    //// basic variables
    using BasicStorageLib for BasicStorageLib.UintData;
    using BasicStorageLib for BasicStorageLib.BoolData;
    using BasicStorageLib for BasicStorageLib.AddressData;
    using BasicStorageLib for BasicStorageLib.BytesData;
    using BasicStorageLib for BasicStorageLib.StringData;

    BasicStorageLib.UintData    internal uintData;
    BasicStorageLib.BoolData    internal boolData;
    BasicStorageLib.AddressData internal addressData;
    BasicStorageLib.BytesData   internal bytesData;
    BasicStorageLib.StringData  internal stringData;
}

// File: contracts/interfaces/IRC20Protocol.sol

/*

  Copyright 2019 Wanchain Foundation.

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

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.26;

interface IRC20Protocol {
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
    function balanceOf(address _owner) external view returns (uint);
}

// File: contracts/interfaces/IQuota.sol

/*

  Copyright 2019 Wanchain Foundation.

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

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity 0.4.26;

interface IQuota {
  function userLock(uint tokenId, bytes32 storemanGroupId, uint value) external;
  function userBurn(uint tokenId, bytes32 storemanGroupId, uint value) external;

  function smgRelease(uint tokenId, bytes32 storemanGroupId, uint value) external;
  function smgMint(uint tokenId, bytes32 storemanGroupId, uint value) external;

  function upgrade(bytes32 storemanGroupId) external;

  function transferAsset(bytes32 srcStoremanGroupId, bytes32 dstStoremanGroupId) external;
  function receiveDebt(bytes32 srcStoremanGroupId, bytes32 dstStoremanGroupId) external;

  function getUserMintQuota(uint tokenId, bytes32 storemanGroupId) external view returns (uint);
  function getSmgMintQuota(uint tokenId, bytes32 storemanGroupId) external view returns (uint);

  function getUserBurnQuota(uint tokenId, bytes32 storemanGroupId) external view returns (uint);
  function getSmgBurnQuota(uint tokenId, bytes32 storemanGroupId) external view returns (uint);

  function getAsset(uint tokenId, bytes32 storemanGroupId) external view returns (uint asset, uint asset_receivable, uint asset_payable);
  function getDebt(uint tokenId, bytes32 storemanGroupId) external view returns (uint debt, uint debt_receivable, uint debt_payable);

  function isDebtClean(bytes32 storemanGroupId) external view returns (bool);
}

// File: contracts/interfaces/IStoremanGroup.sol

/*

  Copyright 2019 Wanchain Foundation.

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

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.24;

interface IStoremanGroup {
    function getSelectedSmNumber(bytes32 groupId) external view returns(uint number);
    function getStoremanGroupConfig(bytes32 id) external view returns(bytes32 groupId, uint8 status, uint deposit, uint chain1, uint chain2, uint curve1, uint curve2,  bytes gpk1, bytes gpk2, uint startTime, uint endTime);
    function getDeposit(bytes32 id) external view returns(uint);
    function getStoremanGroupStatus(bytes32 id) external view returns(uint8 status, uint startTime, uint endTime);
    function setGpk(bytes32 groupId, bytes gpk1, bytes gpk2) external;
    function setInvalidSm(bytes32 groupId, uint[] indexs, uint8[] slashTypes) external returns(bool isContinue);
    function getThresholdByGrpId(bytes32 groupId) external view returns (uint);
    function getSelectedSmInfo(bytes32 groupId, uint index) external view returns(address wkAddr, bytes PK, bytes enodeId);
    function recordSmSlash(address wk) public;
}

// File: contracts/interfaces/ITokenManager.sol

/*

  Copyright 2019 Wanchain Foundation.

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

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity 0.4.26;

interface ITokenManager {
    function getTokenPairInfo(uint id) external view
      returns (uint origChainID, bytes tokenOrigAccount, uint shadowChainID, bytes tokenShadowAccount);

    function getTokenPairInfoSlim(uint id) external view 
      returns (uint origChainID, bytes tokenOrigAccount, uint shadowChainID);

    function getAncestorInfo(uint id) external view
      returns (bytes account, string name, string symbol, uint8 decimals, uint chainId);

    function mintToken(address tokenAddress, address to, uint value) external;

    function burnToken(address tokenAddress, address from, uint value) external;
}

// File: contracts/interfaces/ISignatureVerifier.sol

/*

  Copyright 2019 Wanchain Foundation.

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

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity 0.4.26;

interface ISignatureVerifier {
  function verify(
        uint curveId,
        bytes32 signature,
        bytes32 groupKeyX,
        bytes32 groupKeyY,
        bytes32 randomPointX,
        bytes32 randomPointY,
        bytes32 message
    ) external returns (bool);
}

// File: contracts/lib/SafeMath.sol

pragma solidity ^0.4.24;

/**
 * Math operations with safety checks
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath mul overflow");

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath div 0"); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath sub b > a");
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath add overflow");

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath mod 0");
        return a % b;
    }
}

// File: contracts/crossApproach/lib/HTLCTxLib.sol

/*

  Copyright 2019 Wanchain Foundation.

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

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.26;



library HTLCTxLib {
    using SafeMath for uint;

    /**
     *
     * ENUMS
     *
     */

    
    
    enum TxStatus {None, Locked, Redeemed, Revoked, AssetLocked, DebtLocked}

    /**
     *
     * STRUCTURES
     *
     */

    
    struct HTLCUserParams {
        bytes32 xHash;                  /// hash of HTLC random number
        bytes32 smgID;                  /// ID of storeman group which user has selected
        uint tokenPairID;               /// token pair id on cross chain
        uint value;                     /// exchange token value
        uint lockFee;                   /// exchange token value
        uint lockedTime;                /// HTLC lock time
    }

    
    struct BaseTx {
        bytes32 smgID;                  /// HTLC transaction storeman ID
        uint lockedTime;                /// HTLC transaction locked time
        uint beginLockedTime;           /// HTLC transaction begin locked time
        TxStatus status;                /// HTLC transaction status
    }

    
    struct UserTx {
        BaseTx baseTx;
        uint tokenPairID;
        uint value;
        uint fee;
        address userAccount;            /// HTLC transaction sender address for the security check while user's revoke
    }
    
    struct SmgTx {
        BaseTx baseTx;
        uint tokenPairID;
        uint value;
        address  userAccount;          /// HTLC transaction user address for the security check while user's redeem
    }
    
    struct DebtTx {
        BaseTx baseTx;
        bytes32 srcSmgID;              /// HTLC transaction sender(source storeman) ID
    }

    struct Data {
        
        mapping(bytes32 => UserTx) mapHashXUserTxs;

        
        mapping(bytes32 => SmgTx) mapHashXSmgTxs;

        
        mapping(bytes32 => DebtTx) mapHashXDebtTxs;

    }

    /**
     *
     * MANIPULATIONS
     *
     */

    
    
    function addUserTx(Data storage self, HTLCUserParams memory params)
        public
    {
        UserTx memory userTx = self.mapHashXUserTxs[params.xHash];
        // UserTx storage userTx = self.mapHashXUserTxs[params.xHash];
        // require(params.value != 0, "Value is invalid");
        require(userTx.baseTx.status == TxStatus.None, "User tx exists");

        userTx.baseTx.smgID = params.smgID;
        userTx.baseTx.lockedTime = params.lockedTime;
        userTx.baseTx.beginLockedTime = now;
        userTx.baseTx.status = TxStatus.Locked;
        userTx.tokenPairID = params.tokenPairID;
        userTx.value = params.value;
        userTx.fee = params.lockFee;
        userTx.userAccount = msg.sender;

        self.mapHashXUserTxs[params.xHash] = userTx;
    }

    
    
    function redeemUserTx(Data storage self, bytes32 x)
        external
        returns(bytes32 xHash)
    {
        xHash = sha256(abi.encodePacked(x));

        UserTx storage userTx = self.mapHashXUserTxs[xHash];
        require(userTx.baseTx.status == TxStatus.Locked, "Status is not locked");
        require(now < userTx.baseTx.beginLockedTime.add(userTx.baseTx.lockedTime), "Redeem timeout");

        userTx.baseTx.status = TxStatus.Redeemed;

        return xHash;
    }

    
    
    function revokeUserTx(Data storage self, bytes32 xHash)
        external
    {
        UserTx storage userTx = self.mapHashXUserTxs[xHash];
        require(userTx.baseTx.status == TxStatus.Locked, "Status is not locked");
        require(now >= userTx.baseTx.beginLockedTime.add(userTx.baseTx.lockedTime), "Revoke is not permitted");

        userTx.baseTx.status = TxStatus.Revoked;
    }

    
    
    
    
    
    
    
    function getUserTx(Data storage self, bytes32 xHash)
        external
        view
        returns (bytes32, uint, uint, uint, address)
    {
        UserTx storage userTx = self.mapHashXUserTxs[xHash];
        return (userTx.baseTx.smgID, userTx.tokenPairID, userTx.value, userTx.fee, userTx.userAccount);
    }

    
    
    
    
    
    
    function addSmgTx(Data storage self, bytes32 xHash, bytes32 smgID, uint tokenPairID, uint value, address userAccount, uint lockedTime)
        external
    {
        SmgTx memory smgTx = self.mapHashXSmgTxs[xHash];
        // SmgTx storage smgTx = self.mapHashXSmgTxs[xHash];
        require(value != 0, "Value is invalid");
        require(smgTx.baseTx.status == TxStatus.None, "Smg tx exists");

        smgTx.baseTx.smgID = smgID;
        smgTx.baseTx.status = TxStatus.Locked;
        smgTx.baseTx.lockedTime = lockedTime;
        smgTx.baseTx.beginLockedTime = now;
        smgTx.tokenPairID = tokenPairID;
        smgTx.value = value;
        smgTx.userAccount = userAccount;

        self.mapHashXSmgTxs[xHash] = smgTx;
    }

    
    
    function redeemSmgTx(Data storage self, bytes32 x)
        external
        returns(bytes32 xHash)
    {
        xHash = sha256(abi.encodePacked(x));

        SmgTx storage smgTx = self.mapHashXSmgTxs[xHash];
        require(smgTx.baseTx.status == TxStatus.Locked, "Status is not locked");
        require(now < smgTx.baseTx.beginLockedTime.add(smgTx.baseTx.lockedTime), "Redeem timeout");

        smgTx.baseTx.status = TxStatus.Redeemed;

        return xHash;
    }

    
    
    function revokeSmgTx(Data storage self, bytes32 xHash)
        external
    {
        SmgTx storage smgTx = self.mapHashXSmgTxs[xHash];
        require(smgTx.baseTx.status == TxStatus.Locked, "Status is not locked");
        require(now >= smgTx.baseTx.beginLockedTime.add(smgTx.baseTx.lockedTime), "Revoke is not permitted");

        smgTx.baseTx.status = TxStatus.Revoked;
    }

    
    
    
    
    
    
    function getSmgTx(Data storage self, bytes32 xHash)
        external
        view
        returns (bytes32, uint, uint, address)
    {
        SmgTx storage smgTx = self.mapHashXSmgTxs[xHash];
        return (smgTx.baseTx.smgID, smgTx.tokenPairID, smgTx.value, smgTx.userAccount);
    }

    
    
    
    
    
    
    function addDebtTx(Data storage self, bytes32 xHash, bytes32 srcSmgID, bytes32 destSmgID, uint lockedTime, TxStatus status)
        external
    {
        DebtTx memory debtTx = self.mapHashXDebtTxs[xHash];
        // DebtTx storage debtTx = self.mapHashXDebtTxs[xHash];
        require(debtTx.baseTx.status == TxStatus.None, "Debt tx exists");

        debtTx.baseTx.smgID = destSmgID;
        debtTx.baseTx.status = status;//TxStatus.Locked;
        debtTx.baseTx.lockedTime = lockedTime;
        debtTx.baseTx.beginLockedTime = now;
        debtTx.srcSmgID = srcSmgID;

        self.mapHashXDebtTxs[xHash] = debtTx;
    }

    
    
    
    function redeemDebtTx(Data storage self, bytes32 x, TxStatus status)
        external
        returns(bytes32 xHash)
    {
        xHash = sha256(abi.encodePacked(x));

        DebtTx storage debtTx = self.mapHashXDebtTxs[xHash];
        // require(debtTx.baseTx.status == TxStatus.Locked, "Status is not locked");
        require(debtTx.baseTx.status == status, "Status is not locked");
        require(now < debtTx.baseTx.beginLockedTime.add(debtTx.baseTx.lockedTime), "Redeem timeout");

        debtTx.baseTx.status = TxStatus.Redeemed;

        return xHash;
    }

    
    
    
    function revokeDebtTx(Data storage self, bytes32 xHash, TxStatus status)
        external
    {
        DebtTx storage debtTx = self.mapHashXDebtTxs[xHash];
        // require(debtTx.baseTx.status == TxStatus.Locked, "Status is not locked");
        require(debtTx.baseTx.status == status, "Status is not locked");
        require(now >= debtTx.baseTx.beginLockedTime.add(debtTx.baseTx.lockedTime), "Revoke is not permitted");

        debtTx.baseTx.status = TxStatus.Revoked;
    }

    
    
    
    
    function getDebtTx(Data storage self, bytes32 xHash)
        external
        view
        returns (bytes32, bytes32)
    {
        DebtTx storage debtTx = self.mapHashXDebtTxs[xHash];
        return (debtTx.srcSmgID, debtTx.baseTx.smgID);
    }

    function getLeftTime(uint endTime) private view returns (uint) {
        if (now < endTime) {
            return endTime.sub(now);
        }
        return 0;
    }

    
    
    
    function getLeftLockedTime(Data storage self, bytes32 xHash)
        external
        view
        returns (uint)
    {
        UserTx storage userTx = self.mapHashXUserTxs[xHash];
        if (userTx.baseTx.status != TxStatus.None) {
            return getLeftTime(userTx.baseTx.beginLockedTime.add(userTx.baseTx.lockedTime));
        }
        SmgTx storage smgTx = self.mapHashXSmgTxs[xHash];
        if (smgTx.baseTx.status != TxStatus.None) {
            return getLeftTime(smgTx.baseTx.beginLockedTime.add(smgTx.baseTx.lockedTime));
        }
        DebtTx storage debtTx = self.mapHashXDebtTxs[xHash];
        if (debtTx.baseTx.status != TxStatus.None) {
            return getLeftTime(debtTx.baseTx.beginLockedTime.add(debtTx.baseTx.lockedTime));
        }
        require(false, 'invalid xHash');
    }
}

// File: contracts/crossApproach/lib/RapidityTxLib.sol

/*

  Copyright 2019 Wanchain Foundation.

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

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.26;

library RapidityTxLib {

    /**
     *
     * ENUMS
     *
     */

    
    
    enum TxStatus {None, Redeemed}

    /**
     *
     * STRUCTURES
     *
     */
    struct Data {
        
        mapping(bytes32 => TxStatus) mapTxStatus;

    }

    /**
     *
     * MANIPULATIONS
     *
     */

    
    
    function addRapidityTx(Data storage self, bytes32 uniqueID)
        internal
    {
        TxStatus status = self.mapTxStatus[uniqueID];
        require(status == TxStatus.None, "Rapidity tx exists");
        self.mapTxStatus[uniqueID] = TxStatus.Redeemed;
    }
}

// File: contracts/crossApproach/lib/CrossTypesV1.sol

/*

  Copyright 2019 Wanchain Foundation.

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

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.26;








library CrossTypesV1 {
    using SafeMath for uint;

    /**
     *
     * STRUCTURES
     *
     */

    struct Data {

        /// map of the htlc transaction info
        HTLCTxLib.Data htlcTxData;

        /// map of the rapidity transaction info
        RapidityTxLib.Data rapidityTxData;

        /// quota data of storeman group
        IQuota quota;

        /// token manager instance interface
        ITokenManager tokenManager;

        /// storemanGroup admin instance interface
        IStoremanGroup smgAdminProxy;

        /// storemanGroup fee admin instance address
        address smgFeeProxy;

        ISignatureVerifier sigVerifier;

        
        mapping(bytes32 => uint) mapStoremanFee;

        
        mapping(uint => mapping(uint =>uint)) mapContractFee;

        
        mapping(uint => mapping(uint =>uint)) mapAgentFee;

    }

    /**
     *
     * MANIPULATIONS
     *
     */

    // 
    // 
    // function bytes32ToAddress(bytes32 b) internal pure returns (address) {
    //     return address(uint160(bytes20(b))); // high
    //     // return address(uint160(uint256(b))); // low
    // }

    
    
    function bytesToAddress(bytes b) internal pure returns (address addr) {
        assembly {
            addr := mload(add(b,20))
        }
    }

    function transfer(address tokenScAddr, address to, uint value)
        internal
        returns(bool)
    {
        uint beforeBalance;
        uint afterBalance;
        beforeBalance = IRC20Protocol(tokenScAddr).balanceOf(to);
        // IRC20Protocol(tokenScAddr).transfer(to, value);
        tokenScAddr.call(bytes4(keccak256("transfer(address,uint256)")), to, value);
        afterBalance = IRC20Protocol(tokenScAddr).balanceOf(to);
        return afterBalance == beforeBalance.add(value);
    }

    function transferFrom(address tokenScAddr, address from, address to, uint value)
        internal
        returns(bool)
    {
        uint beforeBalance;
        uint afterBalance;
        beforeBalance = IRC20Protocol(tokenScAddr).balanceOf(to);
        // IRC20Protocol(tokenScAddr).transferFrom(from, to, value);
        tokenScAddr.call(bytes4(keccak256("transferFrom(address,address,uint256)")), from, to, value);
        afterBalance = IRC20Protocol(tokenScAddr).balanceOf(to);
        return afterBalance == beforeBalance.add(value);
    }
}

// File: contracts/crossApproach/CrossStorageV1.sol

/*

  Copyright 2019 Wanchain Foundation.

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

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.26;





contract CrossStorageV1 is BasicStorage {
    using HTLCTxLib for HTLCTxLib.Data;
    using RapidityTxLib for RapidityTxLib.Data;

    /************************************************************
     **
     ** VARIABLES
     **
     ************************************************************/

    CrossTypesV1.Data internal storageData;

    
    uint public lockedTime = uint(3600*36);

    
    
    
    uint public smgFeeReceiverTimeout = uint(10*60);

    enum GroupStatus { none, initial, curveSeted, failed, selected, ready, unregistered, dismissed }

}

// File: contracts/crossApproach/CrossStorageV2.sol

/*

  Copyright 2019 Wanchain Foundation.

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

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.26;





contract CrossStorageV2 is CrossStorageV1, ReentrancyGuard, Halt, Proxy {

    /************************************************************
     **
     ** VARIABLES
     **
     ************************************************************/

    /** STATE VARIABLES **/
    uint256 public currentChainID;
    address public admin;

    /** STRUCTURES **/
    struct SetFeesParam {
        uint256 srcChainID;
        uint256 destChainID;
        uint256 contractFee;
        uint256 agentFee;
    }

    struct GetFeesParam {
        uint256 srcChainID;
        uint256 destChainID;
    }

    struct GetFeesReturn {
        uint256 contractFee;
        uint256 agentFee;
    }
}

// File: contracts/crossApproach/lib/HTLCDebtLibV2.sol

/*

  Copyright 2019 Wanchain Foundation.

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

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.26;



library HTLCDebtLibV2 {

    /**
     *
     * STRUCTURES
     *
     */

    
    struct DebtAssetParams {
        bytes32 uniqueID;               /// hash of HTLC random number
        bytes32 srcSmgID;               /// ID of source storeman group
        bytes32 destSmgID;              /// ID of destination storeman group
    }

    /**
     *
     * EVENTS
     *
     **/

    
    
    
    
    event TransferAssetLogger(bytes32 indexed uniqueID, bytes32 indexed srcSmgID, bytes32 indexed destSmgID);

    
    
    
    
    event ReceiveDebtLogger(bytes32 indexed uniqueID, bytes32 indexed srcSmgID, bytes32 indexed destSmgID);

    /**
     *
     * MANIPULATIONS
     *
     */

    
    
    
    function transferAsset(CrossTypesV1.Data storage storageData, DebtAssetParams memory params)
        public
    {
        if (address(storageData.quota) != address(0)) {
            storageData.quota.transferAsset(params.srcSmgID, params.destSmgID);
        }
        emit TransferAssetLogger(params.uniqueID, params.srcSmgID, params.destSmgID);
    }

    
    
    
    function receiveDebt(CrossTypesV1.Data storage storageData, DebtAssetParams memory params)
        public
    {
        if (address(storageData.quota) != address(0)) {
            storageData.quota.receiveDebt(params.srcSmgID, params.destSmgID);
        }
        emit ReceiveDebtLogger(params.uniqueID, params.srcSmgID, params.destSmgID);
    }
}

// File: contracts/interfaces/ISmgFeeProxy.sol

/*

  Copyright 2019 Wanchain Foundation.

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

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity 0.4.26;

interface ISmgFeeProxy {
  function smgTransfer(bytes32 smgID) external payable;
}

// File: contracts/crossApproach/lib/RapidityLibV2.sol

/*

  Copyright 2019 Wanchain Foundation.

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

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.26;







library RapidityLibV2 {
    using SafeMath for uint;
    using RapidityTxLib for RapidityTxLib.Data;

    /**
    *
    * STRUCTURES
    *
    */

    
    struct CrossFeeParams {
        uint contractFee;                 /// token pair id on cross chain
        uint agentFee;                    /// exchange token value
    }

    
    struct RapidityUserLockParams {
        bytes32 smgID;                    /// ID of storeman group which user has selected
        uint tokenPairID;                 /// token pair id on cross chain
        uint value;                       /// exchange token value
        uint currentChainID;              /// current chain ID
        bytes destUserAccount;            /// account of shadow chain, used to receive token
    }

    
    struct RapiditySmgMintParams {
        bytes32 uniqueID;                 /// Rapidity random number
        bytes32 smgID;                    /// ID of storeman group which user has selected
        uint tokenPairID;                 /// token pair id on cross chain
        uint value;                       /// exchange token value
        address destTokenAccount;         /// shadow token account
        address destUserAccount;          /// account of shadow chain, used to receive token
    }

    
    struct RapidityUserBurnParams {
        bytes32 smgID;                  /// ID of storeman group which user has selected
        uint tokenPairID;               /// token pair id on cross chain
        uint value;                     /// exchange token value
        uint currentChainID;            /// current chain ID
        uint fee;                       /// exchange token fee
        address srcTokenAccount;        /// shadow token account
        bytes destUserAccount;          /// account of token destination chain, used to receive token
    }

    
    struct RapiditySmgReleaseParams {
        bytes32 uniqueID;               /// Rapidity random number
        bytes32 smgID;                  /// ID of storeman group which user has selected
        uint tokenPairID;               /// token pair id on cross chain
        uint value;                     /// exchange token value
        address destTokenAccount;       /// original token/coin account
        address destUserAccount;        /// account of token original chain, used to receive token
    }

    /**
     *
     * EVENTS
     *
     **/


    
    
    
    
    
    
    
    event UserLockLogger(bytes32 indexed smgID, uint indexed tokenPairID, address indexed tokenAccount, uint value, uint contractFee, bytes userAccount);

    
    
    
    
    
    
    
    event UserBurnLogger(bytes32 indexed smgID, uint indexed tokenPairID, address indexed tokenAccount, uint value, uint contractFee, uint fee, bytes userAccount);

    
    
    
    
    
    
    
    
    event SmgMintLogger(bytes32 indexed uniqueID, bytes32 indexed smgID, uint indexed tokenPairID, uint value, address tokenAccount, address userAccount);

    
    
    
    
    
    
    
    
    event SmgReleaseLogger(bytes32 indexed uniqueID, bytes32 indexed smgID, uint indexed tokenPairID, uint value, address tokenAccount, address userAccount);

    /**
    *
    * MANIPULATIONS
    *
    */

    
    
    
    
    function userLock(CrossTypesV1.Data storage storageData, RapidityUserLockParams memory params)
        public
    {
        uint fromChainID;
        uint toChainID;
        bytes memory fromTokenAccount;
        (fromChainID,fromTokenAccount,toChainID) = storageData.tokenManager.getTokenPairInfoSlim(params.tokenPairID);
        require(fromChainID != 0, "Token does not exist");

        if (address(storageData.quota) != address(0)) {
            storageData.quota.userLock(params.tokenPairID, params.smgID, params.value);
        }

        uint contractFee = storageData.mapContractFee[fromChainID][toChainID];
        if (contractFee > 0) {
            if (storageData.smgFeeProxy == address(0)) {
                storageData.mapStoremanFee[bytes32(0)] = storageData.mapStoremanFee[bytes32(0)].add(contractFee);
            } else {
                (storageData.smgFeeProxy).transfer(contractFee);
            }
        }

        address tokenScAddr = CrossTypesV1.bytesToAddress(fromTokenAccount);

        uint left;
        if (tokenScAddr == address(0)) {
            left = (msg.value).sub(params.value).sub(contractFee);
        } else {
            left = (msg.value).sub(contractFee);

            require(CrossTypesV1.transferFrom(tokenScAddr, msg.sender, this, params.value), "Lock token failed");
        }
        if (left != 0) {
            (msg.sender).transfer(left);
        }
        emit UserLockLogger(params.smgID, params.tokenPairID, tokenScAddr, params.value, contractFee, params.destUserAccount);
    }

    
    
    
    
    function userBurn(CrossTypesV1.Data storage storageData, RapidityUserBurnParams memory params)
        public
    {
        ITokenManager tokenManager = storageData.tokenManager;
        uint fromChainID;
        uint toChainID;
        bytes memory fromTokenAccount;
        bytes memory toTokenAccount;
        (fromChainID,fromTokenAccount,toChainID,toTokenAccount) = tokenManager.getTokenPairInfo(params.tokenPairID);
        require(fromChainID != 0, "Token does not exist");

        uint256 contractFee;
        address tokenScAddr;
        if (params.currentChainID == toChainID) {
            contractFee = storageData.mapContractFee[toChainID][fromChainID];
            tokenScAddr = CrossTypesV1.bytesToAddress(toTokenAccount);
        } else if (params.currentChainID == fromChainID) {
            contractFee = storageData.mapContractFee[fromChainID][toChainID];
            tokenScAddr = CrossTypesV1.bytesToAddress(fromTokenAccount);
        } else {
            require(false, "Invalid token pair");
        }
        require(params.srcTokenAccount == tokenScAddr, "invalid token account");

        if (address(storageData.quota) != address(0)) {
            storageData.quota.userBurn(params.tokenPairID, params.smgID, params.value);
        }

        require(burnShadowToken(tokenManager, tokenScAddr, msg.sender, params.value), "burn failed");

        if (contractFee > 0) {
            if (storageData.smgFeeProxy == address(0)) {
                storageData.mapStoremanFee[bytes32(0)] = storageData.mapStoremanFee[bytes32(0)].add(contractFee);
            } else {
                (storageData.smgFeeProxy).transfer(contractFee);
            }
        }

        uint left = (msg.value).sub(contractFee);
        // uint left = (msg.value).sub(contractFee);
        if (left != 0) {
            (msg.sender).transfer(left);
        }

        emit UserBurnLogger(params.smgID, params.tokenPairID, tokenScAddr, params.value, contractFee, params.fee, params.destUserAccount);
    }

    
    
    
    
    function smgMint(CrossTypesV1.Data storage storageData, RapiditySmgMintParams memory params)
        public
    {
        storageData.rapidityTxData.addRapidityTx(params.uniqueID);

        if (address(storageData.quota) != address(0)) {
            storageData.quota.smgMint(params.tokenPairID, params.smgID, params.value);
        }

        require(mintShadowToken(storageData.tokenManager, params.destTokenAccount, params.destUserAccount, params.value), "mint failed");

        emit SmgMintLogger(params.uniqueID, params.smgID, params.tokenPairID, params.value, params.destTokenAccount, params.destUserAccount);
    }

    
    
    
    
    function smgRelease(CrossTypesV1.Data storage storageData, RapiditySmgReleaseParams memory params)
        public
    {
        storageData.rapidityTxData.addRapidityTx(params.uniqueID);

        if (address(storageData.quota) != address(0)) {
            storageData.quota.smgRelease(params.tokenPairID, params.smgID, params.value);
        }

        if (params.destTokenAccount == address(0)) {
            (params.destUserAccount).transfer(params.value);
        } else {
            require(CrossTypesV1.transfer(params.destTokenAccount, params.destUserAccount, params.value), "Transfer token failed");
        }

        emit SmgReleaseLogger(params.uniqueID, params.smgID, params.tokenPairID, params.value, params.destTokenAccount, params.destUserAccount);
    }

    function burnShadowToken(address tokenManager, address tokenAddress, address userAccount, uint value) private returns (bool) {
        uint beforeBalance;
        uint afterBalance;
        beforeBalance = IRC20Protocol(tokenAddress).balanceOf(userAccount);

        ITokenManager(tokenManager).burnToken(tokenAddress, userAccount, value);

        afterBalance = IRC20Protocol(tokenAddress).balanceOf(userAccount);
        return afterBalance == beforeBalance.sub(value);
    }

    function mintShadowToken(address tokenManager, address tokenAddress, address userAccount, uint value) private returns (bool) {
        uint beforeBalance;
        uint afterBalance;
        beforeBalance = IRC20Protocol(tokenAddress).balanceOf(userAccount);

        ITokenManager(tokenManager).mintToken(tokenAddress, userAccount, value);

        afterBalance = IRC20Protocol(tokenAddress).balanceOf(userAccount);
        return afterBalance == beforeBalance.add(value);
    }

}

// File: contracts/crossApproach/CrossDelegateV2.sol

/*

  Copyright 2019 Wanchain Foundation.

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

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.26;






contract CrossDelegateV2 is CrossStorageV2 {
    using SafeMath for uint;

    /**
     *
     * EVENTS
     *
     **/

    
    
    event SetAdmin(address adminAccount);

    
    
    
    
    
    event SetFee(uint srcChainID, uint destChainID, uint contractFee, uint agentFee);

    
    
    
    
    
    event SmgWithdrawFeeLogger(bytes32 indexed smgID, uint indexed timeStamp, address indexed receiver, uint fee);
    event WithdrawContractFeeLogger(uint indexed block, uint indexed timeStamp, address indexed receiver, uint fee);

    /**
     *
     * MODIFIERS
     *
     */
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "not admin");
        _;
    }

    
    
    modifier onlyReadySmg(bytes32 smgID) {
        uint8 status;
        uint startTime;
        uint endTime;
        (status,startTime,endTime) = storageData.smgAdminProxy.getStoremanGroupStatus(smgID);

        require(status == uint8(GroupStatus.ready) && now >= startTime && now <= endTime, "PK is not ready");
        _;
    }


    /**
     *
     * MANIPULATIONS
     *
     */
    
    
    
    
    
    function userLock(bytes32 smgID, uint tokenPairID, uint value, bytes userAccount)
        external
        payable
        notHalted
        onlyReadySmg(smgID)
    {
        RapidityLibV2.RapidityUserLockParams memory params = RapidityLibV2.RapidityUserLockParams({
            smgID: smgID,
            tokenPairID: tokenPairID,
            value: value,
            currentChainID: currentChainID,
            destUserAccount: userAccount
        });
        RapidityLibV2.userLock(storageData, params);
    }

    
    
    
    
    
    function userBurn(bytes32 smgID, uint tokenPairID, uint value, uint fee, address tokenAccount, bytes userAccount)
        external
        payable
        notHalted
        onlyReadySmg(smgID)
    {
        RapidityLibV2.RapidityUserBurnParams memory params = RapidityLibV2.RapidityUserBurnParams({
            smgID: smgID,
            tokenPairID: tokenPairID,
            value: value,
            fee: fee,
            currentChainID: currentChainID,
            srcTokenAccount: tokenAccount,
            destUserAccount: userAccount
        });
        RapidityLibV2.userBurn(storageData, params);
    }

    
    
    
    
    
    
    
    
    function smgMint(bytes32 uniqueID, bytes32 smgID, uint tokenPairID, uint value, address tokenAccount, address userAccount, bytes r, bytes32 s)
        external
        notHalted
    {
        uint curveID;
        bytes memory PK;
        (curveID, PK) = acquireReadySmgInfo(smgID);

        RapidityLibV2.RapiditySmgMintParams memory params = RapidityLibV2.RapiditySmgMintParams({
            uniqueID: uniqueID,
            smgID: smgID,
            tokenPairID: tokenPairID,
            value: value,
            destTokenAccount: tokenAccount,
            destUserAccount: userAccount
        });
        RapidityLibV2.smgMint(storageData, params);

        bytes32 mHash = sha256(abi.encode(currentChainID, uniqueID, tokenPairID, value, tokenAccount, userAccount));
        verifySignature(curveID, mHash, PK, r, s);
    }

    
    
    
    
    
    
    
    
    function smgRelease(bytes32 uniqueID, bytes32 smgID, uint tokenPairID, uint value, address tokenAccount, address userAccount, bytes r, bytes32 s)
        external
        notHalted
    {
        uint curveID;
        bytes memory PK;
        (curveID, PK) = acquireReadySmgInfo(smgID);

        RapidityLibV2.RapiditySmgReleaseParams memory params = RapidityLibV2.RapiditySmgReleaseParams({
            uniqueID: uniqueID,
            smgID: smgID,
            tokenPairID: tokenPairID,
            value: value,
            destTokenAccount: tokenAccount,
            destUserAccount: userAccount
        });
        RapidityLibV2.smgRelease(storageData, params);

        bytes32 mHash = sha256(abi.encode(currentChainID, uniqueID, tokenPairID, value, tokenAccount, userAccount));
        verifySignature(curveID, mHash, PK, r, s);
    }

    
    
    
    
    
    
    function transferAsset(bytes32 uniqueID, bytes32 srcSmgID, bytes32 destSmgID, bytes r, bytes32 s)
        external
        notHalted
        onlyReadySmg(destSmgID)
    {
        uint curveID;
        bytes memory PK;
        (curveID, PK) = acquireUnregisteredSmgInfo(srcSmgID);

        HTLCDebtLibV2.DebtAssetParams memory params = HTLCDebtLibV2.DebtAssetParams({
            uniqueID: uniqueID,
            srcSmgID: srcSmgID,
            destSmgID: destSmgID
        });
        HTLCDebtLibV2.transferAsset(storageData, params);

        bytes32 mHash = sha256(abi.encode(currentChainID, uniqueID, destSmgID));
        verifySignature(curveID, mHash, PK, r, s);
    }

    
    
    
    
    
    
    function receiveDebt(bytes32 uniqueID, bytes32 srcSmgID, bytes32 destSmgID, bytes r, bytes32 s)
        external
        notHalted 
    {
        uint curveID;
        bytes memory PK;
        (curveID, PK) = acquireReadySmgInfo(destSmgID);

        HTLCDebtLibV2.DebtAssetParams memory params = HTLCDebtLibV2.DebtAssetParams({
            uniqueID: uniqueID,
            srcSmgID: srcSmgID,
            destSmgID: destSmgID
        });
        HTLCDebtLibV2.receiveDebt(storageData, params);

        bytes32 mHash = sha256(abi.encode(currentChainID, uniqueID, srcSmgID));
        verifySignature(curveID, mHash, PK, r, s);
    }

    
    
    function setFee(SetFeesParam param)
        public
        onlyAdmin
    {
        storageData.mapContractFee[param.srcChainID][param.destChainID] = param.contractFee;
        storageData.mapAgentFee[param.srcChainID][param.destChainID] = param.agentFee;
        emit SetFee(param.srcChainID, param.destChainID, param.contractFee, param.agentFee);
    }

    
    
    function setFees(SetFeesParam [] params) public onlyAdmin {
        for (uint i = 0; i < params.length; ++i) {
            storageData.mapContractFee[params[i].srcChainID][params[i].destChainID] = params[i].contractFee;
            storageData.mapAgentFee[params[i].srcChainID][params[i].destChainID] = params[i].agentFee;
            emit SetFee(params[i].srcChainID, params[i].destChainID, params[i].contractFee, params[i].agentFee);
        }
    }

    function setChainID(uint256 chainID) external onlyAdmin {
        if (currentChainID == 0) {
            currentChainID = chainID;
        }
    }

    function setAdmin(address adminAccount) external onlyOwner {
        admin = adminAccount;
        emit SetAdmin(adminAccount);
    }

    function setUintValue(bytes key, bytes innerKey, uint value) external onlyAdmin {
        return uintData.setStorage(key, innerKey, value);
    }

    function delUintValue(bytes key, bytes innerKey) external onlyAdmin {
        return uintData.delStorage(key, innerKey);
    }

    
    
    
    
    
    
    function setPartners(address tokenManager, address smgAdminProxy, address smgFeeProxy, address quota, address sigVerifier)
        external
        onlyOwner
    {
        // require(tokenManager != address(0) && smgAdminProxy != address(0) && quota != address(0) && sigVerifier != address(0),
        //     "Parameter is invalid");
        require(tokenManager != address(0) && smgAdminProxy != address(0) && sigVerifier != address(0),
            "Parameter is invalid");

        storageData.smgAdminProxy = IStoremanGroup(smgAdminProxy);
        storageData.tokenManager = ITokenManager(tokenManager);
        storageData.quota = IQuota(quota);
        storageData.smgFeeProxy = smgFeeProxy;
        storageData.sigVerifier = ISignatureVerifier(sigVerifier);
    }

    
    
    function smgWithdrawFee(bytes32 [] smgIDs) external {
        uint fee;
        uint currentFee;
        address smgFeeProxy = storageData.smgFeeProxy;
        if (smgFeeProxy == address(0)) {
            smgFeeProxy = owner;
        }
        require(smgFeeProxy != address(0), "invalid smgFeeProxy");

        for (uint i = 0; i < smgIDs.length; ++i) {
            currentFee = storageData.mapStoremanFee[smgIDs[i]];
            delete storageData.mapStoremanFee[smgIDs[i]];
            fee = fee.add(currentFee);
            emit SmgWithdrawFeeLogger(smgIDs[i], block.timestamp, smgFeeProxy, currentFee);
        }
        currentFee = storageData.mapStoremanFee[bytes32(0)];
        if (currentFee > 0) {
            delete storageData.mapStoremanFee[bytes32(0)];
            fee = fee.add(currentFee);
        }
        require(fee > 0, "Fee is null");

        smgFeeProxy.transfer(fee);
        emit WithdrawContractFeeLogger(block.number, block.timestamp, smgFeeProxy, fee);
    }


    /** Get Functions */

    function getUintValue(bytes key, bytes innerKey) public view returns (uint) {
        return uintData.getStorage(key, innerKey);
    }

    
    
    
    function getStoremanFee(bytes32 smgID) external view returns(uint fee) {
        fee = storageData.mapStoremanFee[smgID];
    }

    
    
    
    function getFee(GetFeesParam param) public view returns(GetFeesReturn fee) {
        fee.contractFee = storageData.mapContractFee[param.srcChainID][param.destChainID];
        fee.agentFee = storageData.mapAgentFee[param.srcChainID][param.destChainID];
    }

    
    
    
    function getFees(GetFeesParam [] params) public view returns(GetFeesReturn [] fees) {
        fees = new GetFeesReturn[](params.length);
        for (uint i = 0; i < params.length; ++i) {
            fees[i].contractFee = storageData.mapContractFee[params[i].srcChainID][params[i].destChainID];
            fees[i].agentFee = storageData.mapAgentFee[params[i].srcChainID][params[i].destChainID];
        }
    }

    
    
    
    
    
    
    function getPartners()
        external
        view
        returns(address tokenManager, address smgAdminProxy, address smgFeeProxy, address quota, address sigVerifier)
    {
        tokenManager = address(storageData.tokenManager);
        smgAdminProxy = address(storageData.smgAdminProxy);
        smgFeeProxy = storageData.smgFeeProxy;
        quota = address(storageData.quota);
        sigVerifier = address(storageData.sigVerifier);
    }


    /** Private and Internal Functions */

    
    
    
    
    function acquireReadySmgInfo(bytes32 smgID)
        internal
        view
        returns (uint curveID, bytes memory PK)
    {
        uint8 status;
        uint startTime;
        uint endTime;
        (,status,,,,curveID,,PK,,startTime,endTime) = storageData.smgAdminProxy.getStoremanGroupConfig(smgID);

        require(status == uint8(GroupStatus.ready) && now >= startTime && now <= endTime, "PK is not ready");

        return (curveID, PK);
    }

    
    
    
    
    function acquireUnregisteredSmgInfo(bytes32 smgID)
        internal
        view
        returns (uint curveID, bytes memory PK)
    {
        uint8 status;
        (,status,,,,curveID,,PK,,,) = storageData.smgAdminProxy.getStoremanGroupConfig(smgID);

        require(status == uint8(GroupStatus.unregistered), "PK is not unregistered");
    }

    
    
    
    function bytesToBytes32(bytes memory b, uint offset) internal pure returns (bytes32 result) {
        assembly {
            result := mload(add(add(b, offset), 32))
        }
    }

    
    
    
    
    
    function verifySignature(uint curveID, bytes32 message, bytes PK, bytes r, bytes32 s) internal {
        bytes32 PKx = bytesToBytes32(PK, 0);
        bytes32 PKy = bytesToBytes32(PK, 32);

        bytes32 Rx = bytesToBytes32(r, 0);
        bytes32 Ry = bytesToBytes32(r, 32);

        require(storageData.sigVerifier.verify(curveID, s, PKx, PKy, Rx, Ry, message), "Signature verification failed");
    }
}