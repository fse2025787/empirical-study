// SPDX-License-Identifier: MIT
pragma abicoder v1;


// 

pragma solidity 0.8.17;



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
}// 

pragma solidity 0.8.17;





contract WethUnwrapper is InteractiveNotificationReceiver {
    error ETHTransferFailed();

    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}

    uint256 private constant _RAW_CALL_GAS_LIMIT = 5000;

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
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = makerAddress.call{value: takingAmount, gas: _RAW_CALL_GAS_LIMIT}("");
        if (!success) revert ETHTransferFailed();
    }
}

// 

pragma solidity 0.8.17;


interface IWithdrawable {
    function withdraw(uint wad) external;
}
