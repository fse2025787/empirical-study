pragma experimental ABIEncoderV2;

/**
 *Submitted for verification at Etherscan.io on 2021-02-24
*/

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