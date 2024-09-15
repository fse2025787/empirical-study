// SPDX-License-Identifier: GPL-3.0

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;




interface IDerivativePriceFeed {
    function calcUnderlyingValues(address, uint256)
        external
        returns (address[] memory, uint256[] memory);

    function isSupportedAsset(address) external view returns (bool);
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;







contract BalancerV2GaugeTokenPriceFeed is IDerivativePriceFeed {
    
    
    
    
    
    function calcUnderlyingValues(address _derivative, uint256 _derivativeAmount)
        external
        override
        returns (address[] memory underlyings_, uint256[] memory underlyingAmounts_)
    {
        underlyings_ = new address[](1);
        underlyings_[0] = IBalancerV2LiquidityGauge(_derivative).lp_token();

        underlyingAmounts_ = new uint256[](1);
        underlyingAmounts_[0] = _derivativeAmount;

        return (underlyings_, underlyingAmounts_);
    }

    
    
    
    function isSupportedAsset(address _asset) public view override returns (bool isSupported_) {
        // There isn't a great way to validate that `_asset` is really a Balancer gauge
        // without making assumptions about the gauge's factory's interface (which Balancer has changed previously)
        // and a list of all factories.
        // Since this function only serves to validate the Council's own user inputs,
        // it is sufficient to do a simple, convenient check that the required interface is present.

        return IBalancerV2LiquidityGauge(_asset).lp_token() != address(0);
    }
}

// 

/*
    This file is part of the Enzyme Protocol.
    (c) Enzyme Council <[email protected]>
    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;




interface IBalancerV2LiquidityGauge {
    function lp_token() external view returns (address lpToken_);
}