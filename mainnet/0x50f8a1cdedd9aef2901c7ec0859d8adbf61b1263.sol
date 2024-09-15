// SPDX-License-Identifier: AGPL-3.0-only

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
pragma solidity >=0.7.6;




interface ERC20Like {
    function balanceOf(address) external view returns (uint256);
    function transferFrom(address, address, uint256) external returns (bool);
    function mint(address, uint256) external;
    function burn(address, uint256) external;
    function totalSupply() external view returns (uint256);
    function approve(address, uint256) external;
}

interface LendingAdapter {
    function remainingCredit() external view returns (uint256);
    function draw(uint256 amount) external;
    function wipe(uint256 amount) external;
    function debt() external returns (uint256);
    function activated() external view returns (bool);
}


/// of the total balance
contract Reserve is Math, Auth {
    ERC20Like public currency;

    // additional currency from lending adapters
    // for deactivating set to address(0)
    LendingAdapter public lending;

    // currency available for borrowing new loans
    uint256 public currencyAvailable;

    // address or contract which holds the currency
    // by default it is address(this)
    address pot;

    // total currency in the reserve
    uint256 public balance_;

    event File(bytes32 indexed what, uint256 amount);
    event Depend(bytes32 contractName, address addr);

    constructor(address currency_) {
        currency = ERC20Like(currency_);
        pot = address(this);
        currency.approve(pot, type(uint256).max);
        wards[msg.sender] = 1;
        emit Rely(msg.sender);
    }

    
    
    
    function file(bytes32 what, uint256 amount) public auth {
        if (what == "currencyAvailable") {
            currencyAvailable = amount;
        } else {
            revert();
        }
        emit File(what, amount);
    }

    
    
    
    function depend(bytes32 contractName, address addr) public auth {
        if (contractName == "currency") {
            currency = ERC20Like(addr);
            if (pot == address(this)) {
                currency.approve(pot, type(uint256).max);
            }
        } else if (contractName == "pot") {
            pot = addr;
        } else if (contractName == "lending") {
            lending = LendingAdapter(addr);
        } else {
            revert();
        }
        emit Depend(contractName, addr);
    }

    
    
    function totalBalance() public view returns (uint256 totalBalance_) {
        return balance_;
    }

    
    
    function totalBalanceAvailable() public view returns (uint256 totalBalanceAvailable_) {
        if (address(lending) == address(0)) {
            return balance_;
        }

        return safeAdd(balance_, lending.remainingCredit());
    }

    
    
    function deposit(uint256 currencyAmount) public auth {
        if (currencyAmount == 0) return;
        _deposit(msg.sender, currencyAmount);
    }

    
    /// and is not used to repay a lending adapter
    
    function hardDeposit(uint256 currencyAmount) public auth {
        _depositAction(msg.sender, currencyAmount);
    }

    
    
    
    function _depositAction(address usr, uint256 currencyAmount) internal {
        require(currency.transferFrom(usr, pot, currencyAmount), "reserve-deposit-failed");
        balance_ = safeAdd(balance_, currencyAmount);
    }

    
    
    
    function _deposit(address usr, uint256 currencyAmount) internal {
        _depositAction(usr, currencyAmount);
        if (address(lending) != address(0) && lending.debt() > 0 && lending.activated()) {
            uint256 wipeAmount = lending.debt();
            uint256 available = balance_;
            if (available < wipeAmount) {
                wipeAmount = available;
            }
            lending.wipe(wipeAmount);
        }
    }

    
    
    function payout(uint256 currencyAmount) public auth {
        if (currencyAmount == 0) return;
        _payout(msg.sender, currencyAmount);
    }

    
    
    
    function _payoutAction(address usr, uint256 currencyAmount) internal {
        require(currency.transferFrom(pot, usr, currencyAmount), "reserve-payout-failed");
        balance_ = safeSub(balance_, currencyAmount);
    }

    
    
    function hardPayout(uint256 currencyAmount) public auth {
        _payoutAction(msg.sender, currencyAmount);
    }

    
    
    
    function _payout(address usr, uint256 currencyAmount) internal {
        uint256 reserveBalance = balance_;
        if (currencyAmount > reserveBalance && address(lending) != address(0) && lending.activated()) {
            uint256 drawAmount = safeSub(currencyAmount, reserveBalance);
            uint256 left = lending.remainingCredit();
            if (drawAmount > left) {
                drawAmount = left;
            }

            lending.draw(drawAmount);
        }

        _payoutAction(usr, currencyAmount);
    }

    
    /// in the reserve are compulsory available for loans in the current epoch
    
    function payoutForLoans(uint256 currencyAmount) public auth {
        require(currencyAvailable >= currencyAmount, "not-enough-currency-reserve");

        currencyAvailable = safeSub(currencyAvailable, currencyAmount);
        _payout(msg.sender, currencyAmount);
    }
}