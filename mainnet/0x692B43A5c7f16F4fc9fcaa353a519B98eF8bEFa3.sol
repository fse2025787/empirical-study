// SPDX-License-Identifier: GPL-3.0-or-later

/**
 *Submitted for verification at Etherscan.io on 2022-05-09
*/

// 
// solhint-disable const-name-snakecase

pragma solidity 0.8.7;


interface IBentoBoxMinimal {

    struct Rebase {
        uint128 elastic;
        uint128 base;
    }

    struct StrategyData {
        uint64 strategyStartDate;
        uint64 targetPercentage;
        uint128 balance; // the balance of the strategy that BentoBox thinks is in there
    }

    function strategyData(address token) external view returns (StrategyData memory);

    
    function balanceOf(address, address) external view returns (uint256);

    
    
    
    
    
    
    
    
    function deposit(
        address token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external payable returns (uint256 amountOut, uint256 shareOut);

    
    
    
    
    
    
    function withdraw(
        address token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external returns (uint256 amountOut, uint256 shareOut);

    
    
    
    
    
    function transfer(
        address token,
        address from,
        address to,
        uint256 share
    ) external;

    
    
    
    
    
    function toShare(
        address token,
        uint256 amount,
        bool roundUp
    ) external view returns (uint256 share);

    
    
    
    
    
    function toAmount(
        address token,
        uint256 share,
        bool roundUp
    ) external view returns (uint256 amount);

    
    function registerProtocol() external;

    function totals(address token) external view returns (Rebase memory);

    function harvest(
        address token,
        bool balance,
        uint256 maxChangeAmount
    ) external;
}

interface IReducer {
    function reduceCompletely(address cauldron) external;
}

contract Rebalance {
    error NotHighEnough();
    address public constant UST = 0xa47c8bf37f92aBed4A126BDA807A7b7498661acD;
    IReducer private constant reducer = IReducer(0x16ebACab63581e69d6F7594C9Eb1a05dF808ea75);
    address private constant strategy = 0x9CD243E5200B290F10d74D93E0CA6C9e51B3d664;
    IBentoBoxMinimal private constant bentoBox = IBentoBoxMinimal(0xd96f48665a1410C0cd669A88898ecA36B9Fc2cce);

    function reduce() external {
        uint256 amount = bentoBox.toAmount(UST, bentoBox.balanceOf(UST, address(strategy)), false);

        if (amount <= 100 ether) {
            revert NotHighEnough();
        }

        bentoBox.harvest(UST, true, type(uint256).max);
    }
}