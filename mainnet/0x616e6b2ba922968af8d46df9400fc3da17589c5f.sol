// SPDX-License-Identifier: MIT


// 
pragma solidity 0.8.14;



interface ILockManager {
    function isLocked(address collection, address operator, address from, address to, uint256 id) external returns (bool);
    function isLocked(address collection, address operator, address from, address to, uint256[] calldata ids) external returns (bool);
}// 
pragma solidity 0.8.14;





contract LockManagerUnlocked is ILockManager {
    function isLocked(address /*collection*/, address /*operator*/, address /*from*/, address /*to*/, uint256 /*id*/) external pure returns (bool) {
        return false;
    }

    function isLocked(address /*collection*/, address /*operator*/, address /*from*/, address /*to*/, uint256[] calldata /*ids*/) external pure returns (bool) {
        return false;
    }
}
