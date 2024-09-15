// SPDX-License-Identifier: MIT
pragma abicoder v1;


// 

pragma solidity 0.8.10;



interface InteractiveNotificationReceiver {
    
    /// the opposite transfer happened
    function notifyFillOrder(
        address taker,
        address makerAsset,
        address takerAsset,
        uint256 makingAmount,
        uint256 takingAmount,
        bytes memory interactiveData
    ) external;
}
// 

pragma solidity 0.8.10;





contract WethUnwrapper is InteractiveNotificationReceiver {
    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}

    function notifyFillOrder(
        address /* taker */,
        address /* makerAsset */,
        address takerAsset,
        uint256 /* makingAmount */,
        uint256 takingAmount,
        bytes calldata interactiveData
    ) external override {
        address payable makerAddress;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            makerAddress := shr(96, calldataload(interactiveData.offset))
        }
        IWithdrawable(takerAsset).withdraw(takingAmount);
        makerAddress.transfer(takingAmount);
    }
}

// 

pragma solidity 0.8.10;


interface IWithdrawable {
    function withdraw(uint wad) external;
}