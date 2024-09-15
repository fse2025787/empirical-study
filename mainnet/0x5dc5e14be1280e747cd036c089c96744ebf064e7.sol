// SPDX-License-Identifier:  AGPL-3.0-or-later // hevm: flattened sources of contracts/oracles/UsdOracle.sol

/**
 *Submitted for verification at Etherscan.io on 2021-05-14
*/

// 
pragma solidity =0.6.11;

////// contracts/oracles/UsdOracle.sol
/* pragma solidity 0.6.11; */


contract UsdOracle {

    int256 constant USD_PRICE = 1 * 10 ** 8;

    /**
        @dev Returns the constant USD price.
    */
    function getLatestPrice() public pure returns (int256) {
        return USD_PRICE;
    }
}