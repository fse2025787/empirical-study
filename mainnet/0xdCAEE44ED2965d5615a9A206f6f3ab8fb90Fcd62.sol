// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2021-04-08
*/

// 

pragma solidity 0.8.0;



// Part: IAxieInfinity

interface IAxieInfinity {

    
    ///  ownership of the NFT if enough Ether is supplied.
    
    ///  the Nonfungible Interface.
    
    function bid(
        address _nftAddress,
        uint256 _tokenId
    ) external payable;

    
    
    
    function getCurrentPrice(
        address _nftAddress,
        uint256 _tokenId
    )
    external
    view
    returns (uint256);
}

// Part: IERC721

interface IERC721 {
    
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    
    
    
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) external;
    
    function setApprovalForAll(address operator, bool approved) external;

    function approve(address to, uint256 tokenId) external;
    
    function isApprovedForAll(address owner, address operator) external returns (bool);
}

// File: AxieInfinityMarket.sol

library AxieInfinityMarket {

    address public constant AXIE_INFINITY = 0xF4985070Ce32b6B1994329DF787D1aCc9a2dd9e2;

    function buyAssetsForEth(bytes memory data, address recipient) public {
        address[] memory nftAddresses;
        uint256[] memory tokenIds;
        (nftAddresses, tokenIds) = abi.decode(
            data,
            (address[], uint256[])
        );
        for (uint256 i = 0; i < nftAddresses.length; i++) {
            _buyAssetForEth(nftAddresses[i], tokenIds[i], recipient);
        }
    }

    function estimateAssetPriceInEth(address nftAddress, uint256 tokenId) public view returns(uint256) {
        return IAxieInfinity(AXIE_INFINITY).getCurrentPrice(nftAddress, tokenId);
    }

    function estimateBatchAssetPriceInEth(bytes memory data) public view returns(uint256 totalCost) {
        address[] memory nftAddresses;
        uint256[] memory tokenIds;
        (nftAddresses, tokenIds) = abi.decode(
            data,
            (address[], uint256[])
        );
        for (uint256 i = 0; i < nftAddresses.length; i++) {
            totalCost += IAxieInfinity(AXIE_INFINITY).getCurrentPrice(nftAddresses[i], tokenIds[i]);
        }
    }

    function _buyAssetForEth(address _nftAddress, uint256 _tokenId, address _recipient) public {
        bytes memory _data = abi.encodeWithSelector(IAxieInfinity(AXIE_INFINITY).bid.selector, _nftAddress, _tokenId);

        (bool success, ) = AXIE_INFINITY.call{value:estimateAssetPriceInEth(_nftAddress,_tokenId)}(_data);
        require(success, "_buyAssetForEth: axie buy failed.");

        IERC721(_nftAddress).transferFrom(address(this), _recipient, _tokenId);
    }   

}