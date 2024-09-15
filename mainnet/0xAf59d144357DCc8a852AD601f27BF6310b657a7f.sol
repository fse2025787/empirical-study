// SPDX-License-Identifier: MIT
pragma abicoder v2;

// 

pragma solidity ^0.7.6;


// solhint-disable func-name-mixedcase

interface IVeFeeDistributor {
  function claim(address _addr) external returns (uint256);
}

interface IGauge {
  function claim_rewards(address _addr, address _receiver) external returns (uint256);
}

contract RewardClaimHelper {
  
  
  
  function claimVeRewards(address _user, address[] memory _distributors) external {
    for (uint256 i = 0; i < _distributors.length; i++) {
      IVeFeeDistributor(_distributors[i]).claim(_user);
    }
  }

  
  
  
  function claimGaugeRewards(address _user, address[] memory _gauges) external {
    for (uint256 i = 0; i < _gauges.length; i++) {
      IGauge(_gauges[i]).claim_rewards(_user, _user);
    }
  }
}