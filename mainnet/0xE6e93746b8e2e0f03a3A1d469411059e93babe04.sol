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







/// while allowing an asset to continue to be in the asset universe
contract RevertingPriceFeed is IDerivativePriceFeed {
    
    function calcUnderlyingValues(address, uint256)
        external
        override
        returns (address[] memory, uint256[] memory)
    {
        revert("calcUnderlyingValues: RevertingPriceFeed");
    }

    
    
    function isSupportedAsset(address) public view override returns (bool isSupported_) {
        return true;
    }
}

