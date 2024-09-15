// SPDX-License-Identifier: LBUSL-1.1-or-later

// 
// Taken from: https://github.com/gnosis/safe-contracts/blob/development/contracts/proxies/GnosisSafeProxy.sol
pragma solidity >=0.7.0;



interface IWalletProxyImplementation {
	function masterCopy() external view returns (address);

	function walletFactory() external view returns (address);

	function version() external view returns (uint256);

	function upgradeMasterCopy(address newMasterCopy) external;

	function initialize(
		address resolver_,
		string[2] calldata domain_,
		address owner_,
		address feeRecipient,
		uint256 feeAmount
	) external;
}




contract WalletProxy {
	// masterCopy and walletFactory always need to be the first declared variables, to ensure that they are at the same location in the contracts to which calls are delegated.
	// To reduce deployment costs this variable is internal and needs to be retrieved via `getStorageAt`
	address internal masterCopy;
	address internal walletFactory;

	
	constructor() {
		walletFactory = msg.sender;
	}

	
	function initializeFromWalletFactory(address _masterCopy) external {
		require(msg.sender == walletFactory, "WalletProxy: Forbidden");
		require(
			_masterCopy != address(0),
			"Invalid master copy address provided"
		);
		masterCopy = _masterCopy;
	}

	
	fallback() external payable {
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