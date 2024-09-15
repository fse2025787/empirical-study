// SPDX-License-Identifier: UNLICENSED

/**
 *Submitted for verification at Etherscan.io on 2021-11-10
*/

// 
pragma solidity ^0.8.9;


contract P4CToken {
	string public constant name = "Parts of Four Coin";
	string public constant symbol = "P4C";
	uint8 public constant decimals = 18;

	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);

	
	
	uint256 public immutable creationBlock;

	
	bool public deductTaxes = true;

	
	uint256 public constant originalSupply = 4_000_000_000_000e18;

	
	
	uint256 public totalInternalSupply = originalSupply;

	
	uint256 public internalSupplyInNonExcludedAddresses;

	// @notice This 1e18 times a factor that adjusts internal balances to external balances. For example, if an account
	// @notice has an internal balance of 1e18 and this factor is 1.5e18, the external balance of that account will be
	// @notice 1.5e18.
	uint256 public adjustmentFactor = 1e18;

	// @notice The owner of the contract, set to the address that instantiated the contract. Only `contractOwner` may
	// @notice add or remove excluded addresses.
	address public immutable contractOwner;

	// @notice This is a list of excluded addresses. Transfers involving these addresses don't have the 3% tax taken out
	// @notice of them, and they don't receive token redistribution (ie. their balances are adjusted downwards every
	// @notice time `adjustmentFactor` is increased.
	address[] public excludedAddresses;
	// @notice A map where addresses in `excludedAddresses` map to `true`.
	mapping (address => bool) excludedAddressesMap;

	// @notice This is a mapping of addresses to the number of *internal* tokens they hold. This is *different* from the
	// @notice values that are used in contract calls, as those are adjusted by `adjustmentFactor`.
	mapping (address => uint256) public internalBalances;

	// @notice This event is emitted when tokens are transferred from `_from` to `_to`. `_internalSentValue` is the
	// @notice number of internal tokens transferred *before* any fees are deducted (ie. the recipient will actually get
	// @notice 3% less unless `_from` or `_to` is an excluded address).
	event InternalTransfer(address _from, address _to, uint256 _internalSentValue);
	// @notice This event is fired when an excluded address is added.
	event AddedExcludedAddress(address _addr);
	// @notice This event is fired when an address is removed from the excluded address list.
	event RemovedExcludedAddress(address _addr);
	// @notice Called when deduct taxes setting is changed.
	event SetDeductTaxes(bool _enabled);

	// Token authorisations. `_authorisee` can withdraw up to `allowed[_authoriser][_authroisee]` from `_authoriser`'s
	// account. Multiple transfers can be made so long as they do not cumulatively exceed the given amount. This is in
	// *EXTERNAL* tokens.
	mapping (address => mapping (address => uint256)) allowed;

	constructor() {
		creationBlock = block.number;
		contractOwner = msg.sender;
		addExcludedAddress(msg.sender);
		internalBalances[contractOwner] = originalSupply;
	}

	
	
	function internalToExternalAmount(uint256 _internalAmount) view internal returns (uint256) {
		return (_internalAmount * adjustmentFactor) / 1e18;
	}

	
	
	function externalToInternalAmount(uint256 _externalAmount) view internal returns (uint256) {
		return (_externalAmount * 1e18) / adjustmentFactor;
	}

	
	function totalSupply() public view returns (uint256) {
		return internalToExternalAmount(totalInternalSupply);
	}

	
	
	
	function addExcludedAddress(address _addr) public {
		require(msg.sender == contractOwner, "This function is callable only by the contract owner.");
		require(!excludedAddressesMap[_addr], "_addr is already an excluded address.");

		internalSupplyInNonExcludedAddresses -= internalBalances[_addr];
		excludedAddressesMap[_addr] = true;
		excludedAddresses.push(_addr);

		emit AddedExcludedAddress(_addr);
	}

	
	
	
	
	function removeExcludedAddress(address _addr) public {
		require(msg.sender == contractOwner, "This function is callable only by the contract owner.");
		require(_addr != contractOwner, "contractOwner must be an excluded address for correct contract behaviour.");
		require(!!excludedAddressesMap[_addr], "_addr is not an excluded address.");

		internalSupplyInNonExcludedAddresses += internalBalances[_addr];
		excludedAddressesMap[_addr] = false;
		for (uint i; i < excludedAddresses.length; i++) {
			if (excludedAddresses[i] == _addr) {
				if (i != excludedAddresses.length-1)
					excludedAddresses[i] = excludedAddresses[excludedAddresses.length-1];

				excludedAddresses.pop();
				break;
			}
		}

		emit RemovedExcludedAddress(_addr);
	}

	
	function setDeductTaxes(bool _deductTaxes) public {
		require(msg.sender == contractOwner, "This function is callable only by the contract owner.");
		require(_deductTaxes != deductTaxes, "deductTaxes is already that value");
		deductTaxes = _deductTaxes;
		emit SetDeductTaxes(_deductTaxes);
	}

	
	function balanceOf(address _owner) public view returns (uint256 balance) {
		return internalToExternalAmount(internalBalances[_owner]);
	}

	
	
	
	function approve(address _spender, uint256 _value) public returns (bool success) {
		allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	
	function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
		return allowed[_owner][_spender];
	}

	
	
	
	
	function transfer(address _to, uint256 _value) public returns (bool success) {
		return transferCommon(msg.sender, _to, _value);
	}

	
	
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		require(allowed[_from][msg.sender] >= _value, "Sender has insufficient authorisation.");
		allowed[_from][msg.sender] -= _value;

		return transferCommon(_from, _to, _value);
	}

	
	function transferCommon(address _from, address _to, uint256 _value) internal returns (bool success) {
		uint256 internalValue = externalToInternalAmount(_value);
		require(internalValue <= internalBalances[_from], "Transfer source has insufficient balance.");

		uint256 internalReceivedValue;
		if (!excludedAddressesMap[_from] && !excludedAddressesMap[_to] && deductTaxes) {
			uint256 onePercent = internalValue / 100;
			internalReceivedValue = internalValue - onePercent * 3;
			internalSupplyInNonExcludedAddresses -= onePercent * 3;

			// This is the adjustment resulting from just this transaction.
			uint256 readjustmentFactor =
				((internalSupplyInNonExcludedAddresses + onePercent) * 1e18) /
				internalSupplyInNonExcludedAddresses;
			adjustmentFactor = (adjustmentFactor * readjustmentFactor) / 1e18;

			internalBalances[contractOwner] += onePercent;

			uint256 removedFunds;
			for (uint i; i < excludedAddresses.length; i++) {
				// Because this is rounded down, excludedAddresses will slowly lose funds as more transactions are made.
				// However, due to the fact that transactions are expensive and we have such a high precision, this
				// doesn't make a difference in practice.
				uint256 oldBalance = internalBalances[excludedAddresses[i]];
				uint256 newBalance = ((oldBalance * 1e18) / readjustmentFactor);
				internalBalances[excludedAddresses[i]] = newBalance;
				removedFunds += oldBalance - newBalance;
			}

			// Decrement the total supply by 2% of the transfer amount plus the internal amount that's been taken from
			// excludedAddresses.
			totalInternalSupply -= removedFunds + onePercent*2;
		} else {
			if (excludedAddressesMap[_from] && !excludedAddressesMap[_to])
				internalSupplyInNonExcludedAddresses += internalValue;
			if (!excludedAddressesMap[_from] && excludedAddressesMap[_to])
				internalSupplyInNonExcludedAddresses -= internalValue;

			internalReceivedValue = internalValue;
		}

		internalBalances[_to] += internalReceivedValue;
		internalBalances[_from] -= internalValue;

		emit Transfer(_from, _to, _value);
		emit InternalTransfer(_from, _to, internalValue);

		return true;
	}
}