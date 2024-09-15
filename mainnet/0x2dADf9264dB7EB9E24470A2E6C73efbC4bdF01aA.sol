// SPDX-License-Identifier: MIT
pragma abicoder v1;

// 

pragma solidity 0.8.11;



contract SeriesNonceManager {
    event NonceIncreased(address indexed maker, uint8 series, uint256 newNonce);

    // {
    //    1: {
    //        '0x762f73Ad...842Ffa8': 0,
    //        '0xd20c41ee...32aaDe2': 1
    //    },
    //    2: {
    //        '0x762f73Ad...842Ffa8': 3,
    //        '0xd20c41ee...32aaDe2': 15
    //    },
    //    ...
    // }
    mapping(uint8 => mapping(address => uint256)) public nonce;

    
    function increaseNonce(uint8 series) external {
        advanceNonce(series, 1);
    }

    
    function advanceNonce(uint8 series, uint8 amount) public {
        uint256 newNonce = nonce[series][msg.sender] + amount;
        nonce[series][msg.sender] = newNonce;
        emit NonceIncreased(msg.sender, series, newNonce);
    }

    
    
    function nonceEquals(uint8 series, address makerAddress, uint256 makerNonce) external view returns(bool) {
        return nonce[series][makerAddress] == makerNonce;
    }
}