// SPDX-License-Identifier: MIT

// 
pragma solidity 0.8.13;




contract YieldsterVaultProxyFactory {
    address private mastercopy;
    address private APContract;
    address private owner;

    event ProxyCreation(YieldsterVaultProxy proxy);

    constructor(address _mastercopy, address _APContract)  {
        mastercopy = _mastercopy;
        APContract = _APContract;
        owner = msg.sender;
    }

    function setMasterCopy(address _mastercopy) public {
        require(msg.sender == owner, "Not Authorized");
        mastercopy = _mastercopy;
    }

    function setAPContract(address _APContract) public {
        require(msg.sender == owner, "Not Authorized");
        APContract = _APContract;
    }

    
    
    function createProxy(bytes memory data)
        public
        returns (address)
    {
       YieldsterVaultProxy proxy = new YieldsterVaultProxy(mastercopy);
        if (data.length > 0) 
            // solium-disable-next-line security/no-inline-assembly
            assembly {
                if eq(call(gas(), proxy, 0, add(data, 0x20), mload(data), 0, 0),0) {
                    revert(0, 0)
                }
            }
        
        IAPContract(APContract).setVaultStatus(address(proxy));
        emit ProxyCreation(proxy);
        return address(proxy);
    }

    
    function proxyRuntimeCode() public pure returns (bytes memory) {
        return type(YieldsterVaultProxy).runtimeCode;
    }

    
    function proxyCreationCode() public pure returns (bytes memory) {
        return type(YieldsterVaultProxy).creationCode;
    }
}

// 
pragma solidity ^0.8.1;



interface IProxy {
    function masterCopy() external view returns (address);
}




contract YieldsterVaultProxy {
    // masterCopy always needs to be first declared variable, to ensure that it is at the same location in the contracts to which calls are delegated.
    // To reduce deployment costs this variable is internal and needs to be retrieved via `getStorageAt`
    address internal masterCopy;

    
    
    constructor(address _masterCopy)  {
        require(
            _masterCopy != address(0),
            "Invalid master copy address provided"
        );
        masterCopy = _masterCopy;
    }

    
    fallback() external payable {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let _masterCopy := and(
                sload(0),
                0xffffffffffffffffffffffffffffffffffffffff
            )
            // 0xa619486e == keccak("masterCopy()"). The value is right padded to 32-bytes with 0s
            if eq(
                calldataload(0),
                0xa619486e00000000000000000000000000000000000000000000000000000000
            ) {
                mstore(0, _masterCopy)
                return(0, 0x20)
            }
            calldatacopy(0, 0, calldatasize())
            let success := delegatecall(
                gas(),
                _masterCopy,
                0,
                calldatasize(),
                0,
                0
            )
            returndatacopy(0, 0, returndatasize())
            if eq(success, 0) {
                revert(0, returndatasize())
            }
            return(0, returndatasize())
        }
    }
}

// 
pragma solidity ^0.8.1;


interface IProxyCreationCallback {
    function proxyCreated(
        YieldsterVaultProxy proxy,
        address _mastercopy,
        bytes calldata initializer,
        uint256 saltNonce
    ) external;
}

// 
pragma solidity 0.8.13;

interface IAPContract {
    

    function getUSDPrice(address) external view returns (uint256);
    function stringUtils() external view returns (address);
    function yieldsterGOD() external view returns (address);
    function emergencyVault() external view returns (address);
    function whitelistModule() external view returns (address);
    function addVault(address,uint256[] calldata) external;
    function setVaultSlippage(uint256) external;
    function setVaultAssets(address[] calldata,address[] calldata,address[] calldata,address[] calldata) external;
    function changeVaultAdmin(address _vaultAdmin) external;
    function yieldsterDAO() external view returns (address);
    function exchangeRegistry() external view returns (address);
    function getVaultSlippage() external view returns (uint256);
    function _isVaultAsset(address) external view returns (bool);
    function yieldsterTreasury() external view returns (address);
    function setVaultStatus(address) external;
    function setVaultSmartStrategy(address, uint256) external;
    function getWithdrawStrategy() external returns (address);
    function getDepositStrategy() external returns (address);
    function isDepositAsset(address) external view returns (bool);
    function isWithdrawalAsset(address) external view returns (bool);
    function getVaultManagementFee() external returns (address[] memory);
    function safeMinter() external returns (address);
    function safeUtils() external returns (address);
    function getStrategyFromMinter(address) external view returns (address);
    function sdkContract() external returns (address);
    function getWETH()external view returns(address);
    function calculateSlippage(address ,address, uint256, uint256)external view returns(uint256);
    function vaultsCount(address) external view returns(uint256);
    function getPlatformFeeStorage() external view returns(address);
    function checkWalletAddress(address _walletAddress) external view returns(bool);
}