// SPDX-License-Identifier: MIT
pragma abicoder v1;

/**
 *Submitted for verification at Etherscan.io on 2022-02-17
*/

// 

pragma solidity 0.8.10;


contract NonceManager {
    event NonceIncreased(address indexed maker, uint8 series, uint256 newNonce);

    // {1: {'0xaddress1': 0, '0xaddress1': 1}, 2: {'0xaddress1': 3, '0xaddress1': 15} ...}
    mapping(uint8 => mapping(address => uint256)) public nonces;

    
    function increaseNonce(uint8 series) external {
        advanceNonce(series, 1);
    }

    
    function advanceNonce(uint8 series, uint8 amount) public {
        uint256 newNonce = nonces[series][msg.sender] + amount;
        nonces[series][msg.sender] = newNonce;
        emit NonceIncreased(msg.sender, series, newNonce);
    }

    
    
    function nonceEquals(uint8 series, address makerAddress, uint256 makerNonce) external view returns(bool) {
        return nonces[series][makerAddress] == makerNonce;
    }
}