// SPDX-License-Identifier: MIXED

/**
 *Submitted for verification at Etherscan.io on 2021-09-17
*/

/**
 *Submitted for verification at Etherscan.io on 2021-09-17
*/

/**
 *Submitted for verification at Etherscan.io on 2021-06-20
*/

// 

// File @boringcrypto/boring-solidity/contracts/libraries/[email protected]
// License-Identifier: MIT
pragma solidity 0.8.4;

// Audit on 5-Jan-2021 by Keno and BoringCrypto
// Source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol + Claimable.sol
// Edited by BoringCrypto

contract BoringOwnableData {
    address public owner;
    address public pendingOwner;
}

contract BoringOwnable is BoringOwnableData {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    
    /// Can only be invoked by the current `owner`.
    
    
    
    function transferOwnership(
        address newOwner,
        bool direct,
        bool renounce
    ) public onlyOwner {
        if (direct) {
            // Checks
            require(newOwner != address(0) || renounce, "Ownable: zero address");

            // Effects
            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
            pendingOwner = address(0);
        } else {
            // Effects
            pendingOwner = newOwner;
        }
    }

    
    function claimOwnership() public {
        address _pendingOwner = pendingOwner;

        // Checks
        require(msg.sender == _pendingOwner, "Ownable: caller != pending owner");

        // Effects
        emit OwnershipTransferred(owner, _pendingOwner);
        owner = _pendingOwner;
        pendingOwner = address(0);
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
}

// File @boringcrypto/boring-solidity/contracts/interfaces/[email protected]
interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File @sushiswap/bentobox-sdk/contracts/[email protected]

interface IBentoBoxV1 {
    function balanceOf(IERC20 token, address user) external view returns (uint256 share);
    function deposit(
        IERC20 token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external payable returns (uint256 amountOut, uint256 shareOut);

    function toAmount(
        IERC20 token,
        uint256 share,
        bool roundUp
    ) external view returns (uint256 amount);
    
    function toShare(
        IERC20 token,
        uint256 amount,
        bool roundUp
    ) external view returns (uint256 share);
    
    function transfer(
        IERC20 token,
        address from,
        address to,
        uint256 share
    ) external;

    function withdraw(
        IERC20 token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external returns (uint256 amountOut, uint256 shareOut);
}

// License-Identifier: MIT

interface Cauldron {
    function accrue() external;
    function withdrawFees() external;
    function accrueInfo() external view returns(uint64, uint128, uint64);
}

interface CauldronV1 {
    function accrue() external;
    function withdrawFees() external;
    function accrueInfo() external view returns(uint64, uint128);
}

contract AdvancedWithdrawer is BoringOwnable {
    
    Cauldron[] public cauldrons;
    CauldronV1[] public cauldronsv1;
    IBentoBoxV1 public constant bentoBox = IBentoBoxV1(0xF5BCE5077908a1b7370B9ae04AdC565EBd643966);
    IERC20 public constant MIM = IERC20(0x99D8a9C45b2ecA8864373A26D1459e3Dff1e17F3);
    
    constructor(Cauldron[] memory pools, CauldronV1[] memory poolsv1) {
        cauldrons = pools;
        cauldronsv1 = poolsv1;
    }
    
    function withdraw() external {
        uint256 length = cauldrons.length;
        for(uint256 i = 0; i < length; i++) {
            cauldrons[i].accrue();
            (, uint256 feesEarned, ) = cauldrons[i].accrueInfo();
            if(feesEarned < bentoBox.toAmount(MIM, bentoBox.balanceOf(MIM, address(cauldrons[i])), false)) {
                MIM.transferFrom(msg.sender, address(bentoBox), feesEarned);
                bentoBox.deposit(MIM, address(bentoBox), address(cauldrons[i]), feesEarned, 0);
            }
            cauldrons[i].withdrawFees();
        }
        
        length = cauldronsv1.length;
        for(uint256 i = 0; i < length; i++) {
            cauldronsv1[i].accrue();
            (, uint256 feesEarned) = cauldronsv1[i].accrueInfo();
            if(feesEarned < bentoBox.toAmount(MIM, bentoBox.balanceOf(MIM, address(cauldronsv1[i])), false)) {
                MIM.transferFrom(msg.sender, address(bentoBox), feesEarned);
                bentoBox.deposit(MIM, address(bentoBox), address(cauldronsv1[i]), feesEarned, 0);
            }
            cauldronsv1[i].withdrawFees();

        }
        
    }
    
    function addPool(Cauldron pool) external onlyOwner {
        cauldrons.push(pool);
    }
    
    function addPoolv1(CauldronV1 pool) external onlyOwner {
        cauldronsv1.push(pool);
    }
    
    
    function addPools(Cauldron[] memory pools) external onlyOwner {
        for(uint256 i = 0; i < pools.length; i++) {
            cauldrons.push(pools[i]);
        }
    }
    
}