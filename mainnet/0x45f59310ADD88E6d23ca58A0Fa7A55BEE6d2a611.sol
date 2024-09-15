// SPDX-License-Identifier: GPL-3.0

/**
 *Submitted for verification at Etherscan.io on 2021-04-18
*/

// 
pragma solidity ^0.8.3;




/// The Ethereum address of the caller, as well as the timestamp is persisted in the Ethereum transaction log
contract EventWriter {

  event Written(bytes32[2] storedData);

  
  
  /// The result can be read by observing the event log, taking note of the caller and the timestamp.
  
  function write(bytes32[2] calldata data) public {
    emit Written(data);
  }
}