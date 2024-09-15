// SPDX-License-Identifier: GPL-2.0-or-later


// 
// Copyright 2017 Loopring Technology Limited.
pragma solidity ^0.7.0;



interface PriceOracle
{
    // @dev Return's the token's value in ETH
    function tokenValue(address token, uint amount)
        external
        view
        returns (uint value);
}
// 
// Copyright 2017 Loopring Technology Limited.
pragma solidity ^0.7.0;




contract PriceOracleDelegate is PriceOracle
{
    PriceOracle public immutable priceOracle;

    constructor(
        PriceOracle _priceOracle
        )
    {
        priceOracle = _priceOracle;
    }

    function tokenValue(address token, uint amount)
        public
        view
        override
        returns (uint value)
    {
        return priceOracle.tokenValue(token, amount);
    }
}
