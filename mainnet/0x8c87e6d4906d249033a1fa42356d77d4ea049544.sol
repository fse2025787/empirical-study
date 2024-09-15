// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2021-03-04
*/

// 

pragma solidity 0.6.12;


interface IERC20 { 
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}


interface ISushiBarEnter { 
    function enter(uint256 amount) external;
}


interface IAaveDeposit {
    function deposit(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
}


contract Saave {
    address constant sushiToken = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2; // SUSHI token contract
    address constant sushiBar = 0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272; // xSUSHI staking contract for SUSHI
    address constant aave = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9; // AAVE lending pool contract for xSUSHI staking into aXSUSHI
    
    constructor() public {
        IERC20(sushiToken).approve(sushiBar, type(uint256).max); // max approve `sushiBar` spender to stake SUSHI into xSUSHI from this contract
        IERC20(sushiBar).approve(aave, type(uint256).max); // max approve `aave` spender to stake xSUSHI into aXSUSHI from this contract
    }
    
    
    function saave(uint256 amount) external {
        IERC20(sushiToken).transferFrom(msg.sender, address(this), amount); // deposit caller SUSHI `amount` into this contract
        ISushiBarEnter(sushiBar).enter(amount); // stake deposited SUSHI `amount` into xSUSHI
        IAaveDeposit(aave).deposit(sushiBar, IERC20(sushiBar).balanceOf(address(this)), msg.sender, 0); // stake resulting xSUSHI into aXSUSHI - send to caller
    }
    
    
    function saaveTo(address to, uint256 amount) external {
        IERC20(sushiToken).transferFrom(msg.sender, address(this), amount); // deposit caller SUSHI `amount` into this contract
        ISushiBarEnter(sushiBar).enter(amount); // stake deposited SUSHI `amount` into xSUSHI
        IAaveDeposit(aave).deposit(sushiBar, IERC20(sushiBar).balanceOf(address(this)), to, 0); // stake resulting xSUSHI into aXSUSHI - send to `to`
    }
}