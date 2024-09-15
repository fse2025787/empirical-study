// SPDX-License-Identifier: LGPL-3.0-only

// 
pragma solidity >=0.7.0 <0.9.0;






interface GnosisSafe {
    
    
    
    
    
    function execTransactionFromModule(address to, uint256 value, bytes calldata data, Enum.Operation operation)
        external
        returns (bool success);
    
     
    function getOwners() external view returns (address[] memory);

}


contract DaaModule {

    address payable public _whitelisted;
    GnosisSafe public _safe;

    event ExecuteTransfer(address indexed safe, address token, address from, address to, uint96 value);
    
    constructor(address payable whitelisted, GnosisSafe safe){
        _whitelisted = whitelisted;
        _safe = safe;
    }
    
    
    
    
    function executeTransfer(
        address token,
        uint96 amount
    ) 
        public 
    {
        isAuthorized(msg.sender);
        // Transfer token
        transfer(_safe, token, _whitelisted, amount);
        emit ExecuteTransfer(address(_safe), token, msg.sender, _whitelisted, amount);
    }

    function transfer(GnosisSafe safe, address token, address payable to, uint96 amount) private {
        if (token == address(0)) {
            // solium-disable-next-line security/no-send
            require(safe.execTransactionFromModule(to, amount, "", Enum.Operation.Call), "Could not execute ether transfer");
        } else {
            bytes memory data = abi.encodeWithSignature("transfer(address,uint256)", to, amount);
            require(safe.execTransactionFromModule(token, 0, data, Enum.Operation.Call), "Could not execute token transfer");
        }
    }

    function isAuthorized(address sender) internal view returns (bool isOwner){
        address[] memory _owners = _safe.getOwners();
        uint256 len = _owners.length;
        for (uint256 i = 0; i < len; i++) {
            if (_owners[i]==sender) { isOwner = true;}
        }
        require(isOwner, "Sender not authorized");
    }
}

// 
pragma solidity 0.8.10;




// Safe Add Single Backup ---* Client is ready to add and register backup *--- //

contract AddBackupSetup {

    event NewWithdrawModule(address moduleAddress);

    function addBackup(
        address _onBehalf, 
        uint _placeholder,
        uint __placeholder,
        bytes calldata _data
    ) 
        public 
        returns (bytes memory txData) 
    {
        (address comptroller, address backup, uint256 clientId) = abi.decode(_data,(address,address,uint256));

        bytes[] memory actions = new bytes[](3);
        // Add Primary as owner
        actions[0] = abi.encodePacked(uint8(0),_onBehalf,uint256(0),uint256(68),abi.encodeWithSignature(
                "addOwnerWithThreshold(address,uint256)", backup, 2));

        // Deploy withdraw module
        {
            address moduleAddress = address(new DaaModule(payable(backup),GnosisSafe(_onBehalf)));
            emit NewWithdrawModule(moduleAddress);
            actions[1] = abi.encodePacked(uint8(0),_onBehalf,uint256(0),uint256(36),abi.encodeWithSignature(
                "enableModule(address)",moduleAddress));
        }

        // Update Comptroller
        actions[2] = abi.encodePacked(uint8(0),comptroller,uint256(0),uint256(68),abi.encodeWithSignature(
                "changeClientBackupAddress(uint256,address)", clientId, backup));

        uint len = actions.length;
        for (uint i=0; i< len; ++i){
            txData = abi.encodePacked(txData,actions[i]);
        }

        return txData;
    }

}

// 
pragma solidity >=0.7.0 <0.9.0;



contract Enum {
    enum Operation {
        Call,
        DelegateCall
    }
}