// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;


// 

pragma solidity ^0.8.0;



interface IRewarder {
    function onIOSTReward(uint256 pid, address user, address recipient, uint256 iostAmount, uint256 newLpAmount) external;
    function pendingTokens(uint256 pid, address user, uint256 iostAmount) external view returns (IERC20[] memory, uint256[] memory);
}
// 

pragma solidity ^0.8.0;




contract EmptyRewarder is IRewarder {
    function onIOSTReward(uint256 pid, address user, address recipient, uint256 iostAmount, uint256 newLpAmount) override external {
    }
    function pendingTokens(uint256 pid, address user, uint256 iostAmount) override external view returns (IERC20[] memory, uint256[] memory){    
    }
}

// 
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}