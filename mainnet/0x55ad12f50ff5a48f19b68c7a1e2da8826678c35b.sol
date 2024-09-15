// SPDX-License-Identifier: AGPL-3.0-only


// 
// Copyright (C) 2018 Rain <[email protected]>
pragma solidity >=0.5.15;

contract Math {
    uint256 constant ONE = 10 ** 27;

    function safeAdd(uint x, uint y) public pure returns (uint z) {
        require((z = x + y) >= x, "safe-add-failed");
    }

    function safeSub(uint x, uint y) public pure returns (uint z) {
        require((z = x - y) <= x, "safe-sub-failed");
    }

    function safeMul(uint x, uint y) public pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "safe-mul-failed");
    }

    function safeDiv(uint x, uint y) public pure returns (uint z) {
        z = x / y;
    }

    function rmul(uint x, uint y) public pure returns (uint z) {
        z = safeMul(x, y) / ONE;
    }

    function rdiv(uint x, uint y) public pure returns (uint z) {
        require(y > 0, "division by zero");
        z = safeAdd(safeMul(x, ONE), y / 2) / y;
    }

    function rdivup(uint x, uint y) internal pure returns (uint z) {
        require(y > 0, "division by zero");
        // always rounds up
        z = safeAdd(safeMul(x, ONE), safeSub(y, 1)) / y;
    }


}
// 
// Copyright (C) Centrifuge 2020, based on MakerDAO dss https://github.com/makerdao/dss
pragma solidity >=0.5.15;

contract Auth {
    mapping (address => uint256) public wards;
    
    event Rely(address indexed usr);
    event Deny(address indexed usr);

    function rely(address usr) external auth {
        wards[usr] = 1;
        emit Rely(usr);
    }
    function deny(address usr) external auth {
        wards[usr] = 0;
        emit Deny(usr);
    }

    modifier auth {
        require(wards[msg.sender] == 1, "not-authorized");
        _;
    }

}

// 
// Copyright (C) 2018 Rain <[email protected]> and Centrifuge, referencing MakerDAO dss => https://github.com/makerdao/dss/blob/master/src/pot.sol
pragma solidity >=0.5.15;



contract Interest is Math {
    // @notice This function provides compounding in seconds
    // @param chi Accumulated interest rate over time
    // @param ratePerSecond Interest rate accumulation per second in RAD(10ˆ27)
    // @param lastUpdated When the interest rate was last updated
    // @param pie Total sum of all amounts accumulating under one interest rate, divided by that rate
    // @return The new accumulated rate, as well as the difference between the debt calculated with the old and new accumulated rates.
    function compounding(uint chi, uint ratePerSecond, uint lastUpdated, uint pie) public view returns (uint, uint) {
        require(block.timestamp >= lastUpdated, "tinlake-math/invalid-timestamp");
        require(chi != 0);
        // instead of a interestBearingAmount we use a accumulated interest rate index (chi)
        uint updatedChi = _chargeInterest(chi ,ratePerSecond, lastUpdated, block.timestamp);
        return (updatedChi, safeSub(rmul(updatedChi, pie), rmul(chi, pie)));
    }

    // @notice This function charge interest on a interestBearingAmount
    // @param interestBearingAmount is the interest bearing amount
    // @param ratePerSecond Interest rate accumulation per second in RAD(10ˆ27)
    // @param lastUpdated last time the interest has been charged
    // @return interestBearingAmount + interest
    function chargeInterest(uint interestBearingAmount, uint ratePerSecond, uint lastUpdated) public view returns (uint) {
        if (block.timestamp >= lastUpdated) {
            interestBearingAmount = _chargeInterest(interestBearingAmount, ratePerSecond, lastUpdated, block.timestamp);
        }
        return interestBearingAmount;
    }

    function _chargeInterest(uint interestBearingAmount, uint ratePerSecond, uint lastUpdated, uint current) internal pure returns (uint) {
        return rmul(rpow(ratePerSecond, current - lastUpdated, ONE), interestBearingAmount);
    }


    // convert pie to debt/savings amount
    function toAmount(uint chi, uint pie) public pure returns (uint) {
        return rmul(pie, chi);
    }

    // convert debt/savings amount to pie
    function toPie(uint chi, uint amount) public pure returns (uint) {
        return rdivup(amount, chi);
    }

    function rpow(uint x, uint n, uint base) public pure returns (uint z) {
        assembly {
            switch x case 0 {switch n case 0 {z := base} default {z := 0}}
            default {
                switch mod(n, 2) case 0 { z := base } default { z := x }
                let half := div(base, 2)  // for rounding.
                for { n := div(n, 2) } n { n := div(n,2) } {
                let xx := mul(x, x)
                if iszero(eq(div(xx, x), x)) { revert(0,0) }
                let xxRound := add(xx, half)
                if lt(xxRound, xx) { revert(0,0) }
                x := div(xxRound, base)
                if mod(n,2) {
                    let zx := mul(z, x)
                    if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) { revert(0,0) }
                    let zxRound := add(zx, half)
                    if lt(zxRound, zx) { revert(0,0) }
                    z := div(zxRound, base)
                }
            }
            }
        }
    }
}

// 
pragma solidity >=0.7.6;




contract PileFab {
    function newPile() public returns (address) {
        Pile pile = new Pile();
        pile.rely(msg.sender);
        pile.deny(address(this));
        return address(pile);
    }
}

// 
// Copyright (C) 2018  Rain <[email protected]>, Centrifuge
pragma solidity >=0.7.6;





/// The following is one implementation of a debt module.
/// It keeps track of different buckets of interest rates and is optimized for many loans per interest bucket.
/// Each bucket holds it own rate accumulators (chi values). It calculates debt for each
/// loan according to its interest rate category and pie value.
contract Pile is Auth, Interest {
    
    struct Rate {
        // total debt of all loans with this rate
        uint256 pie;
        // accumlated rate index over time
        uint256 chi;
        // interest rate per second
        uint256 ratePerSecond;
        // last time the rate was accumulated
        uint48 lastUpdated;
        // fixed rate applied to each loan of the group
        uint256 fixedRate;
    }

    
    mapping(uint256 => Rate) public rates;

    
    /// the debt is stored as pie
    /// pie is defined as pie = debt/chi therefore debt = pie * chi
    /// where chi is the accumulated interest rate index over time
    mapping(uint256 => uint256) public pie;

    
    mapping(uint256 => uint256) public loanRates;

    /// Events
    event IncreaseDebt(uint256 indexed loan, uint256 currencyAmount);
    event DecreaseDebt(uint256 indexed loan, uint256 currencyAmount);
    event SetRate(uint256 indexed loan, uint256 rate);
    event ChangeRate(uint256 indexed loan, uint256 newRate);
    event File(bytes32 indexed what, uint256 rate, uint256 value);

    constructor() {
        // pre-definition for loans without interest rates
        rates[0].chi = ONE;
        rates[0].ratePerSecond = ONE;

        wards[msg.sender] = 1;
        emit Rely(msg.sender);
    }

    
    /// only a ward can call this function
    
    
    
    function file(bytes32 what, uint256 rate, uint256 value) external auth {
        if (what == "rate") {
            require(value != 0, "rate-per-second-can-not-be-0");
            if (rates[rate].chi == 0) {
                rates[rate].chi = ONE;
                rates[rate].lastUpdated = uint48(block.timestamp);
            } else {
                drip(rate);
            }
            rates[rate].ratePerSecond = value;
        } else if (what == "fixedRate") {
            rates[rate].fixedRate = value;
        } else {
            revert("unknown parameter");
        }

        emit File(what, rate, value);
    }

    
    /// a change of the loan debt updates the rate debt and total debt
    
    
    function incDebt(uint256 loan, uint256 currencyAmount) external auth {
        uint256 rate = loanRates[loan];
        require(block.timestamp == rates[rate].lastUpdated, "rate-group-not-updated");
        currencyAmount = safeAdd(currencyAmount, rmul(currencyAmount, rates[rate].fixedRate));
        uint256 pieAmount = toPie(rates[rate].chi, currencyAmount);

        pie[loan] = safeAdd(pie[loan], pieAmount);
        rates[rate].pie = safeAdd(rates[rate].pie, pieAmount);

        emit IncreaseDebt(loan, currencyAmount);
    }

    
    /// a change of the loan debt updates the rate debt and total debt
    
    
    function decDebt(uint256 loan, uint256 currencyAmount) external auth {
        uint256 rate = loanRates[loan];
        require(block.timestamp == rates[rate].lastUpdated, "rate-group-not-updated");
        uint256 pieAmount = toPie(rates[rate].chi, currencyAmount);

        pie[loan] = safeSub(pie[loan], pieAmount);
        rates[rate].pie = safeSub(rates[rate].pie, pieAmount);

        emit DecreaseDebt(loan, currencyAmount);
    }

    
    
    
    function debt(uint256 loan) external view returns (uint256 loanDebt) {
        uint256 rate_ = loanRates[loan];
        uint256 chi_ = rates[rate_].chi;
        if (block.timestamp >= rates[rate_].lastUpdated) {
            chi_ = chargeInterest(rates[rate_].chi, rates[rate_].ratePerSecond, rates[rate_].lastUpdated);
        }
        return toAmount(chi_, pie[loan]);
    }

    
    
    
    function rateDebt(uint256 rate) external view returns (uint256 totalDebt) {
        uint256 chi_ = rates[rate].chi;
        uint256 pie_ = rates[rate].pie;

        if (block.timestamp >= rates[rate].lastUpdated) {
            chi_ = chargeInterest(rates[rate].chi, rates[rate].ratePerSecond, rates[rate].lastUpdated);
        }
        return toAmount(chi_, pie_);
    }

    
    
    
    function setRate(uint256 loan, uint256 rate) external auth {
        require(pie[loan] == 0, "non-zero-debt");
        // rate category has to be initiated
        require(rates[rate].chi != 0, "rate-group-not-set");
        loanRates[loan] = rate;
        emit SetRate(loan, rate);
    }

    
    
    
    function changeRate(uint256 loan, uint256 newRate) external auth {
        require(rates[newRate].chi != 0, "rate-group-not-set");
        uint256 currentRate = loanRates[loan];
        drip(currentRate);
        drip(newRate);
        uint256 pie_ = pie[loan];
        uint256 debt_ = toAmount(rates[currentRate].chi, pie_);
        rates[currentRate].pie = safeSub(rates[currentRate].pie, pie_);
        pie[loan] = toPie(rates[newRate].chi, debt_);
        rates[newRate].pie = safeAdd(rates[newRate].pie, pie[loan]);
        loanRates[loan] = newRate;
        emit ChangeRate(loan, newRate);
    }

    
    
    function accrue(uint256 loan) external {
        drip(loanRates[loan]);
    }

    
    
    function drip(uint256 rate) public {
        if (block.timestamp >= rates[rate].lastUpdated) {
            (uint256 chi,) =
                compounding(rates[rate].chi, rates[rate].ratePerSecond, rates[rate].lastUpdated, rates[rate].pie);
            rates[rate].chi = chi;
            rates[rate].lastUpdated = uint48(block.timestamp);
        }
    }
}