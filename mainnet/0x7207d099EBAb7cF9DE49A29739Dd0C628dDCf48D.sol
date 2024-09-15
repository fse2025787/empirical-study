// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2021-04-09
*/

// 

pragma solidity 0.8.0;



// Part: ICryptoKitties

interface ICryptoKitties {
    
    ///  contract be VERY CAREFUL to ensure that it is aware of ERC-721 (or
    ///  CryptoKitties specifically) or your Kitty may be lost forever. Seriously.
    
    
    
    function transfer(
        address _to,
        uint256 _tokenId
    ) external;
}

// Part: ISaleClockAuction

interface ISaleClockAuction {

    
    /// Otherwise, works the same as default bid method.
    function bid(uint256 _tokenId)
    external
    payable;
    
    
    
    function getCurrentPrice(uint256 _tokenId)
    external
    view
    returns (uint256);
}

// File: CryptoKittiesMarket.sol

library CryptoKittiesMarket {

    address public constant SALE_CLOCK_AUCTION = 0xb1690C08E213a35Ed9bAb7B318DE14420FB57d8C;
    address public constant CRYPTOKITTIES = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;

    function buyAssetsForEth(bytes memory data, address recipient) public {
        uint256[] memory tokenIds;
        (tokenIds) = abi.decode(
            data,
            (uint256[])
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _buyAssetForEth(tokenIds[i], estimateAssetPriceInEth(tokenIds[i]), recipient);
        }
    }

    function estimateAssetPriceInEth(uint256 tokenId) public view returns(uint256) {
        return ISaleClockAuction(SALE_CLOCK_AUCTION).getCurrentPrice(tokenId);
    }

    function estimateBatchAssetPriceInEth(bytes memory data) public view returns(uint256 totalCost) {
        uint256[] memory tokenIds;
        (tokenIds) = abi.decode(
            data,
            (uint256[])
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            totalCost += ISaleClockAuction(SALE_CLOCK_AUCTION).getCurrentPrice(tokenIds[i]);
        }
    }

    function _buyAssetForEth(uint256 _tokenId, uint256 _price, address _recipient) internal {
        bytes memory _data = abi.encodeWithSelector(ISaleClockAuction(SALE_CLOCK_AUCTION).bid.selector, _tokenId);

        (bool success, ) = SALE_CLOCK_AUCTION.call{value:_price}(_data);
        require(success, "_buyAssetForEth: cryptokitty buy failed.");

        ICryptoKitties(CRYPTOKITTIES).transfer(_recipient, _tokenId);
    }
}