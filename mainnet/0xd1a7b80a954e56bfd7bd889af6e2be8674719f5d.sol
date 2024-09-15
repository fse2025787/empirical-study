// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;

/**
 *Submitted for verification at Etherscan.io on 2021-07-08
*/

//
pragma solidity ^0.8.0;


contract BundleUtils {

	constructor() {}

	function checkParentHash(bytes32 _parent_hash) public view returns (bool) {
		require(blockhash(block.number - 1) == _parent_hash, "stale bundle");
		return true;
	}

	function payFlashbotsMiner(uint256 _amount_wei) public payable returns (bool) {
		block.coinbase.transfer(_amount_wei);
		return true;
	}

}