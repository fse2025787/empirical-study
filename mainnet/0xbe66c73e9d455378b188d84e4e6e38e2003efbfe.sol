// SPDX-License-Identifier: GPL-3.0-or-later

/**
 *Submitted for verification at Etherscan.io on 2022-06-21
*/

// 
pragma solidity 0.8.15;

interface IL1Helper {
    function wrapAndRelayTokens(address _receiver, bytes calldata _data) external payable;
}


contract TornadoTasker {
    IL1Helper private immutable L1Helper;

    constructor(IL1Helper _L1Helper) payable {
        L1Helper = _L1Helper;
    }

    function onTaskReceived(bytes calldata data) external payable {
        // decode data for task
        (address _receiver, bytes memory _data) = abi.decode(data, (address, bytes));
        // task ETH to Tornado relayer with data
        L1Helper.wrapAndRelayTokens{value: msg.value}(_receiver, _data);
    }
}