// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-03-23
*/

// 

pragma solidity 0.8.11;

contract Ownable {
    address public ownerAddress;

    constructor() {
        ownerAddress = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == ownerAddress, "Ownable: caller is not the owner");
        _;
    }

    function setOwnerAddress(address _ownerAddress) public onlyOwner {
        ownerAddress = _ownerAddress;
    }
}

interface ICurveRegistry {
    function get_pool_from_lp_token(address) external view returns (address);
}

contract CurveRegistryOverrides is Ownable {
    address[] public curveRegistries;
    mapping(address => address) public poolByLpOverride;

    
    
    function setCurveRegistries(address[] memory _curveRegistries)
        public
        onlyOwner
    {
        curveRegistries = _curveRegistries;
    }

    
    function curveRegistriesList() public view returns (address[] memory) {
        return curveRegistries;
    }

    
    
    function setPoolForLp(address _poolAddress, address _lpAddress)
        public
        onlyOwner
    {
        poolByLpOverride[_lpAddress] = _poolAddress;
    }

    
    function poolByLp(address _lpAddress) public view returns (address) {
        address pool = poolByLpOverride[_lpAddress];
        if (pool != address(0)) {
            return pool;
        }
        for (uint256 i; i < curveRegistries.length; i++) {
            pool = ICurveRegistry(curveRegistries[i]).get_pool_from_lp_token(
                _lpAddress
            );
            if (pool != address(0)) {
                return pool;
            }
        }
        return address(0);
    }
}