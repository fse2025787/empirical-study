// SPDX-License-Identifier: MIT

//	

pragma solidity ^0.8.0;

interface IEthTerrestrials {
  function getTokenSeed(uint256 tokenId) external view returns (uint8[10] memory);
  function tokenSVG(uint256 tokenId, bool background) external view returns (string memory);
}

interface IV2Descriptor {
  function getSvgFromSeed(uint8[10] memory seed) external view returns (string memory);
}




contract EthTerrestrialLogoElement {
  IEthTerrestrials ethTerrestrials;
  IV2Descriptor v2Descriptor;

  constructor(address _ethTerrestrials, address _v2Descriptor) {
    ethTerrestrials = IEthTerrestrials(_ethTerrestrials);
    v2Descriptor = IV2Descriptor(_v2Descriptor);
  }

  
  
  function mustBeOwnerForLogo() external view returns (bool) {
    return false;
  }

  
  
  
  function getSvg(uint256 tokenId) public view returns (string memory) {
    // tripped ethT
    if (tokenId > 111) {
      uint8[10] memory seed = ethTerrestrials.getTokenSeed(tokenId);
      seed[0] = type(uint8).max;
      seed[9] = type(uint8).max;
      return v2Descriptor.getSvgFromSeed(seed);
    } else {
      // 1:1 or genesis ethT
      return ethTerrestrials.tokenSVG(tokenId, true);
    }

  }
}