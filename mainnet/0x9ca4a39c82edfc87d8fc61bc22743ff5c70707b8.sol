// SPDX-License-Identifier: UNLICENSED

// 
pragma solidity 0.8.10;



// Safe Quick Start Setup ---* Client does not have a backup address ready *--- //

contract QuickStart {


    function quickStart(
        address _onBehalf, 
        uint _placeholder,
        uint __placeholder,
        bytes calldata _data
    ) 
        public 
        returns (bytes memory txData) 
    {
        (address comptroller, address primary) = abi.decode(_data,(address,address));
        // Get branch address (for Guardian)
        uint advisorId = IComp(comptroller).advisorToId(IGnosisSafe(_onBehalf).getOwners()[0]);
        address branch = IComp(comptroller).getBranchAddress(IComp(comptroller).getAdvisorBranch(advisorId));

        bytes[] memory actions = new bytes[](3);
        // Add Primary as owner
        actions[0] = abi.encodePacked(uint8(0),_onBehalf,uint256(0),uint256(68),abi.encodeWithSignature(
                "addOwnerWithThreshold(address,uint256)", primary, 2));
        // Add Guardian branch as owner
        actions[1] = abi.encodePacked(uint8(0),_onBehalf,uint256(0),uint256(68),abi.encodeWithSignature(
                "addOwnerWithThreshold(address,uint256)", branch, 2));

        // Update Comptroller
        address[] memory _clientSafes = new address[](1);
        _clientSafes[0] = _onBehalf;

        actions[2] = abi.encodePacked(uint8(0),comptroller,uint256(0),uint256(196),abi.encodeWithSignature(
                "registerClient(address[],address,address,uint256)", _clientSafes, primary, address(0), advisorId));

        uint len = actions.length;
        for (uint i=0; i< len; ++i){
            txData = abi.encodePacked(txData,actions[i]);
        }

        return txData;
    }

}


interface IComp{
    function advisorToId(address _advisorAddress) external view returns (uint);
    function getBranchAddress(uint _branchId) 
        external
        view
        returns (address);
    function getAdvisorBranch(
        uint256 _advisorId
    )
        external
        view
        returns (uint256);
}

// 
pragma solidity >=0.7.0 <0.9.0;



contract Enum {
    enum Operation {
        Call,
        DelegateCall
    }
}

// 
pragma solidity >=0.6.0;



interface IGnosisSafe {
    
    
    
    
    
    function execTransactionFromModule(address to, uint256 value, bytes calldata data, Enum.Operation operation)
        external
        returns (bool success);
    
    function getOwners() external view returns (address[] memory);

    function isOwner(address owner) external view returns (bool);

    function enableModule(address module) external;

    function disableModule(address prevModule, address module) external;

    function checkSignatures(
        bytes32 dataHash,
        bytes memory data,
        bytes memory signatures
    ) external view;

    function getTransactionHash(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        uint256 _nonce
    ) external view returns (bytes32);

    function execTransaction(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures
    ) external payable returns (bool success);

    function signedMessages(bytes32) external view returns(uint256);

    function domainSeparator() external view returns (bytes32);

    function addOwnerWithThreshold(address owner, uint256 _threshold) external;

    function removeOwner(
        address prevOwner,
        address owner,
        uint256 _threshold
    ) external;

    function approveHash(bytes32 hashToApprove) external;

    function getModules() external view returns (address[] memory);

    function changeThreshold(uint256 _threshold) external;
    
    function nonce() external view returns (uint);
}