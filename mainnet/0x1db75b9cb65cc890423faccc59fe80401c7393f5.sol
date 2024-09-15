// SPDX-License-Identifier: MIT

// 
pragma solidity 0.8.13;

contract PlatformManagementFeeStorage {
    address public manager;
    uint256 platformFee;
    mapping(address => uint256) accruedFeesForVault;

    struct UserDepositStruct {
        uint256 amount;
        uint256 depositTime;
    }

    mapping(address => UserDepositStruct) userDepositMapping;

    address sender;

    constructor(uint256 _platformFee) {
        manager = msg.sender;
        platformFee = _platformFee;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Not Authorized");
        _;
    }

    
    
    function setManager(address _manager) external onlyManager {
        manager = _manager;
    }

    
    function getPlatformFee() external view returns (uint256) {
        return platformFee;
    }

    
    
    function setPlatformFee(uint256 _platformFee) external onlyManager {
        platformFee = _platformFee;
    }

    ///TODO ADD PERMISSION
    function setAccruedFees(uint256 fees, address vault) external {
        sender = msg.sender;
        accruedFeesForVault[vault] = fees;
    }

    function getAccruedFees(address vault) external view returns (uint256) {
        return accruedFeesForVault[vault];
    }
}