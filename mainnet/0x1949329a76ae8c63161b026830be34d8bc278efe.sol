
pragma solidity ^0.4.20;

contract Owned {
    address public owner;

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}


interface AquaPriceOracle {
  function getAudCentWeiPrice() external constant returns (uint);
  function getAquaTokenAudCentsPrice() external constant returns (uint);
  event NewPrice(uint _audCentWeiPrice, uint _aquaTokenAudCentsPrice);
}


contract SimpleAquaPriceOracle is Owned, AquaPriceOracle  {
  uint internal audCentWeiPrice;
  uint internal aquaTokenAudCentsPrice;
 
  ///Event is triggered when price is updated
  
  
  event NewPrice(uint _audCentWeiPrice, uint _aquaTokenAudCentsPrice);
 
  ///Function returns price of A$0.01 in Wei
  
  function getAudCentWeiPrice() external constant returns (uint) {
      return audCentWeiPrice;
  }
  
  ///Function returns price of 1 Aqua Token expressed in (Australian dollar) cents
  
  function getAquaTokenAudCentsPrice() external constant returns (uint) {
      return aquaTokenAudCentsPrice;
  }
 
  ///Constructor initializes Aqua Price Oracle smart contract
  
  
  function SimpleAquaPriceOracle(uint _audCentWeiPrice, uint _aquaTokenAudCentsPrice) public {
      updatePrice(_audCentWeiPrice, _aquaTokenAudCentsPrice);
  }
  
  ///Function updates prices
  
  
  function updatePrice(uint _audCentWeiPrice, uint _aquaTokenAudCentsPrice) onlyOwner public {
    audCentWeiPrice = _audCentWeiPrice;
    aquaTokenAudCentsPrice = _aquaTokenAudCentsPrice;
    NewPrice(audCentWeiPrice, aquaTokenAudCentsPrice);
  }
}