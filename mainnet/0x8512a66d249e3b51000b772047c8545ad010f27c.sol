// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2021-05-04
*/

//

pragma solidity 0.6.12;

contract TransferValueToMinerCoinbase {
    
    receive() external payable {
        block.coinbase.transfer(msg.value);
    }
    
}