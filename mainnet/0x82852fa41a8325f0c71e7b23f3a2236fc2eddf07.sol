
pragma solidity ^0.4.24;
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}





contract paymentContract {

    using SafeMath for uint256;

    address operatingAddress;
    address coldStorage;

    uint public opThreshold;
    





    constructor(address _operatingAddress, address _coldStorage, uint _threshold) public {
        operatingAddress = _operatingAddress;
        coldStorage = _coldStorage;
        opThreshold = _threshold * 1 ether;
    }



    function () public payable {
        distribute();
    }

    
    
    
        function distribute() internal {
            if(operatingAddress.balance < opThreshold) {
                if(address(this).balance < (opThreshold - operatingAddress.balance)){
                    operatingAddress.transfer(address(this).balance);
                } else {
                    operatingAddress.transfer(opThreshold - operatingAddress.balance);
                    coldStorage.transfer(address(this).balance);
                }
            } else {
                coldStorage.transfer(address(this).balance);
            }
        }
}