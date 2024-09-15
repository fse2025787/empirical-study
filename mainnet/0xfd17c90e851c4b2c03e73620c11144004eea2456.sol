// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-08-30
*/

// 
pragma solidity 0.8.1;

////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////

contract JumpRateModelV2 {
    event NewInterestParams(
        uint256 baseRatePerBlock,
        uint256 multiplierPerBlock,
        uint256 jumpMultiplierPerBlock,
        uint256 kink
    );

    
    address public owner;

    
    uint256 public immutable blocksPerYear;

    
    uint256 public multiplierPerBlock;

    
    uint256 public baseRatePerBlock;

    
    uint256 public jumpMultiplierPerBlock;

    
    uint256 public kink;

    
    uint256 internal immutable borrowRateMaxMantissa;

    
    
    
    
    
    
    
    
    constructor(
        uint256 baseRatePerYear,
        uint256 multiplierPerYear,
        uint256 jumpMultiplierPerYear,
        uint256 kink_,
        address owner_,
        uint256 borrowRateMaxMantissa_,
        uint256 blocksPerYear_
    ) {
        require(baseRatePerYear > 0, "invalid base rate");
        require(multiplierPerYear > 0, "invalid multiplier per year");
        require(jumpMultiplierPerYear > 0, "invalid jump multiplier per year");
        require(kink_ > 0, "invalid kink");
        require(owner_ != address(0), "invalid owner");
        require(borrowRateMaxMantissa_ > 0, "invalid borrow rate max");
        require(blocksPerYear_ > 0, "invalid blocks per year");

        owner = owner_;
        borrowRateMaxMantissa = borrowRateMaxMantissa_;
        blocksPerYear = blocksPerYear_;
        updateJumpRateModelInternal(
            baseRatePerYear,
            multiplierPerYear,
            jumpMultiplierPerYear,
            kink_,
            blocksPerYear_
        );
    }

    
    
    
    
    
    function updateJumpRateModel(
        uint256 baseRatePerYear,
        uint256 multiplierPerYear,
        uint256 jumpMultiplierPerYear,
        uint256 kink_
    ) external {
        require(msg.sender == owner, "only the owner may call this function.");
        require(baseRatePerYear > 0, "invalid base rate");
        require(multiplierPerYear > 0, "invalid multiplier per year");
        require(jumpMultiplierPerYear > 0, "invalid jump multiplier per year");
        require(kink_ > 0, "invalid kink");

        updateJumpRateModelInternal(
            baseRatePerYear,
            multiplierPerYear,
            jumpMultiplierPerYear,
            kink_,
            blocksPerYear
        );
    }

    
    
    
    
    
    function utilizationRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) public pure returns (uint256) {
        // Utilization rate is 0 when there are no borrows
        if (borrows == 0) {
            return 0;
        }

        return (borrows * (1e18)) / (cash + borrows - reserves);
    }

    
    
    
    
    
    function getBorrowRateInternal(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) internal view returns (uint256) {
        uint256 util = utilizationRate(cash, borrows, reserves);

        if (util <= kink) {
            return (util * multiplierPerBlock) / 1e18 + baseRatePerBlock;
        } else {
            uint256 normalRate = (kink * multiplierPerBlock) / 1e18 + baseRatePerBlock;
            uint256 excessUtil = util - kink;
            return (excessUtil * jumpMultiplierPerBlock) / 1e18 + normalRate;
        }
    }

    /**
    
    
    
    
    
    
     */
    function getSupplyRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves,
        uint256 reserveFactorMantissa
    ) public view returns (uint256) {
        uint256 oneMinusReserveFactor = uint256(1e18) - reserveFactorMantissa;
        uint256 borrowRate = getBorrowRateInternal(cash, borrows, reserves);
        uint256 rateToPool = (borrowRate * oneMinusReserveFactor) / 1e18;
        return (utilizationRate(cash, borrows, reserves) * rateToPool) / 1e18;
    }

    
    
    
    
    
    function updateJumpRateModelInternal(
        uint256 baseRatePerYear,
        uint256 multiplierPerYear,
        uint256 jumpMultiplierPerYear,
        uint256 kink_,
        uint256 blocksPerYear_
    ) internal {
        baseRatePerBlock = baseRatePerYear / blocksPerYear_;
        multiplierPerBlock = (multiplierPerYear * 1e18) / (blocksPerYear_ * kink_);
        jumpMultiplierPerBlock = jumpMultiplierPerYear / blocksPerYear_;
        kink = kink_;

        emit NewInterestParams(baseRatePerBlock, multiplierPerBlock, jumpMultiplierPerBlock, kink);
    }

    
    
    
    
    
    function getBorrowRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) external view returns (uint256) {
        uint256 borrowRateMantissa = getBorrowRateInternal(cash, borrows, reserves);
        if (borrowRateMantissa > borrowRateMaxMantissa) {
            return borrowRateMaxMantissa;
        } else {
            return borrowRateMantissa;
        }
    }
}