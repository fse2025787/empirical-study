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







contract WstethPriceFeed is IDerivativePriceFeed {
    ILidoSteth private immutable STETH_CONTRACT;
    address private immutable WSTETH;

    constructor(address _wsteth, address _steth) public {
        STETH_CONTRACT = ILidoSteth(_steth);
        WSTETH = _wsteth;
    }

    
    
    
    
    function calcUnderlyingValues(address, uint256 _derivativeAmount)
        external
        override
        returns (address[] memory underlyings_, uint256[] memory underlyingAmounts_)
    {
        underlyings_ = new address[](1);
        underlyings_[0] = address(STETH_CONTRACT);

        underlyingAmounts_ = new uint256[](1);
        underlyingAmounts_[0] = STETH_CONTRACT.getPooledEthByShares(_derivativeAmount);

        return (underlyings_, underlyingAmounts_);
    }

    
    
    
    function isSupportedAsset(address _asset) public view override returns (bool isSupported_) {
        return _asset == WSTETH;
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



interface ILidoSteth {
    function getPooledEthByShares(uint256 _sharesAmount)
        external
        view
        returns (uint256 ethAmount_);
}