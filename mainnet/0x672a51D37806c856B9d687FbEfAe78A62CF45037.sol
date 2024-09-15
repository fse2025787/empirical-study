// SPDX-License-Identifier: GPL-3.0-only

/**
 *Submitted for verification at Etherscan.io on 2022-07-06
*/

// 

pragma solidity 0.8.12;

contract PaymentSplitter {
    mapping(address => uint256) public sharesPerCapita;
    address[] public beneficiaries;

    event PaymentReceived(address from, uint amount);
    event PaymentDisbursed(address recipient, uint amount);
    event TransferETHFailed(address recipient, uint amount);

    error ReentrancePrevented(address attacker);
    error InvalidConfiguration();
    error InvalidShares();

    uint constant public PRECISION = 1000000;
    uint private unlocked = 1;
    modifier lock() {
        if (unlocked != 1) {
            revert ReentrancePrevented(msg.sender);
        }
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor(address[] memory bens, uint[] memory shares) {
        if (bens.length != shares.length) {
            revert InvalidConfiguration();
        }
        uint shareSum = 0;
        for (uint i; i < bens.length; ++i) {
            shareSum += shares[i];
            beneficiaries.push(bens[i]);
            sharesPerCapita[bens[i]] = shares[i];
        }
        if (shareSum != PRECISION) {
            revert InvalidShares();
        }
    }

    receive() external payable virtual {
        emit PaymentReceived(msg.sender, msg.value);
    }

    
    
    
    
    function release() external lock {
        uint balance = address(this).balance;
        for (uint i; i < beneficiaries.length; ++i) {
            address ben = beneficiaries[i];
            uint share = sharesPerCapita[ben] * balance / PRECISION;
            (bool sent,) = ben.call{value: share}("");
            if (sent == false) {
                // continuing so that one bad address doesn't lock all ETH
                emit TransferETHFailed(ben, share);
            } else {
                emit PaymentDisbursed(ben, share);
            }
        }
    }
}