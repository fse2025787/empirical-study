// SPDX-License-Identifier: GPL-3.0-only

/**
 *Submitted for verification at Etherscan.io on 2022-07-06
*/

// 

pragma solidity 0.8.12;

interface IPriceGate {

    
    function getCost(uint) external view returns (uint ethCost);

    
    function passThruGate(uint, address) external payable;
}





contract FixedPricePassThruGate is IPriceGate {

    // this represents a single gate
    struct Gate {
        uint ethCost;  // how much does it cost to pass thru it
        address beneficiary;  // who gets the eth that is paid
    }

    // count the gates
    uint public numGates;
    // array-like map of gate structs
    mapping (uint => Gate) public gates;

    error NotEnoughETH(address from, uint price, uint paid);
    error TransferETHFailed(address from, address to, uint amount);

    
    
    
    
    function addGate(uint _ethCost, address _beneficiary) external {
        // prefix operator increments then evaluates, first gate is at index 1
        Gate storage gate = gates[++numGates];
        gate.ethCost = _ethCost;
        gate.beneficiary = _beneficiary;
    }

    
    
    
    function getCost(uint index) override external view returns (uint) {
        return gates[index].ethCost;
    }

    
    
    
    function passThruGate(uint index, address sender) override external payable {
        Gate memory gate = gates[index];
        if (msg.value < gate.ethCost) {
            revert NotEnoughETH(sender, gate.ethCost, msg.value);
        }

        // pass thru ether
        if (msg.value > 0) {
            // use .call so we can send to contracts, for example gnosis safe, re-entrance is not a threat here
            (bool sent,) = gate.beneficiary.call{value: gate.ethCost}("");
            if (sent == false) {
                revert TransferETHFailed(address(this), gate.beneficiary, gate.ethCost);
            }

            uint leftover = msg.value - gate.ethCost;
            if (leftover > 0) {
                (bool sent2,) = sender.call{value: leftover}("");
                if (sent2 == false) {
                    revert TransferETHFailed(address(this), sender, leftover);
                }
            }
        }
    }
}