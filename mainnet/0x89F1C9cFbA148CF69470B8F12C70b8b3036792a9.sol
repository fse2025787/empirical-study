// SPDX-License-Identifier: MIT

// 
pragma solidity ^0.8.0;



contract UbiBurner {
    event Burn(address token, uint256 amount);

    function burn(address _address, uint256 _amount) public {
      IUBI(_address).burn(_amount);
      emit Burn(_address, _amount);
    }
}

// 
pragma solidity 0.8.0;

interface IUBI {
    function burn(uint256 _amount) external;
}

