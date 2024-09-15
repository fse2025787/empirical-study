// SPDX-License-Identifier: MIT

// 
pragma solidity ^0.8.10;

interface ITransferStrategy {
    function canTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) external view returns (bool);
}

// 
pragma solidity ^0.8.10;



contract TransferStrategy is ITransferStrategy {
    function canTransfer(
        address,
        address,
        uint256
    ) public pure returns (bool) {
        return false;
    }
}