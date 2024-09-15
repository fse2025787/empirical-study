// SPDX-License-Identifier: MIT

// 

pragma solidity ^0.8.10;

interface ILenderVerifier {
    function isAllowed(address lender) external view returns (bool);
}

// 
pragma solidity ^0.8.10;



contract AllowAllLenderVerifier is ILenderVerifier {
    function isAllowed(address) external pure returns (bool) {
        return true;
    }
}