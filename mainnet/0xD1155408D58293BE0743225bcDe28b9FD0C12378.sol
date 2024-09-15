// SPDX-License-Identifier: MIT


// 
pragma solidity ^0.8.15;


interface IErrors {
    
    
    
    error OwnerOnly(address sender, address owner);

    
    error ZeroAddress();

    
    error ZeroValue();

    
    error NonZeroValue();

    
    
    
    error WrongArrayLength(uint256 numValues1, uint256 numValues2);

    
    
    
    error Overflow(uint256 provided, uint256 max);

    
    
    error NonTransferable(address account);

    
    
    error NonDelegatable(address account);

    
    
    
    error InsufficientAllowance(uint256 provided, uint256 expected);

    
    
    error NoValueLocked(address account);

    
    
    
    error LockedValueNotZero(address account, uint256 amount);

    
    
    
    
    error LockExpired(address account, uint256 deadline, uint256 curTime);

    
    
    
    
    error LockNotExpired(address account, uint256 deadline, uint256 curTime);

    
    
    
    
    error UnlockTimeIncorrect(address account, uint256 minUnlockTime, uint256 providedUnlockTime);

    
    
    
    
    error MaxUnlockTimeReached(address account, uint256 maxUnlockTime, uint256 providedUnlockTime);

    
    
    
    error WrongBlockNumber(uint256 providedBlockNumber, uint256 actualBlockNumber);
}// 
pragma solidity ^0.8.15;






// Interface for the lock functionality
interface ILOCK {
    
    
    
    
    function createLockFor(address account, uint256 amount, uint256 unlockTime) external;
}

// Interface for the OLAS token allowance increase
interface IOLAS {
    
    
    
    
    function approve(address spender, uint256 amount) external returns (bool);

    
    
    
    function balanceOf(address account) external returns (uint256);
}

// Struct for storing claimable balance, lock and unlock time
// The struct size is one storage slot of uint256 (128 + 64 + padding)
struct ClaimableBalance {
    // Token amount to be locked. Initial OLAS cap is 1 bn tokens, or 1e27.
    // After 10 years, the inflation rate is 2% per year. It would take 1340+ years to reach 2^128 - 1 total supply
    uint128 amount;
    // Lock time period or number of steps
    // 2^64 - 1 value, which is bigger than the end of time in seconds while Earth is spinning
    uint64 period;
}


contract Sale is IErrors {
    event CreateVE(address indexed account, uint256 amount, uint256 timePeriod);
    event CreateBU(address indexed account, uint256 amount, uint256 numSteps);
    event ClaimVE(address indexed account, uint256 amount, uint256 timePeriod);
    event ClaimBU(address indexed account, uint256 amount, uint256 numSteps);
    event OwnerUpdated(address indexed owner);

    // Maximum number of steps for buOLAS (synced with buOLAS `MAX_NUM_STEPS`)
    uint256 internal constant MAX_NUM_STEPS = 10;
    // Minimum lock time for veOLAS (1 year)
    uint256 internal constant MINTIME = 365 * 86400;
    // Maximum lock time for veOLAS (synced with veOLAS `MAXTIME`)
    uint256 internal constant MAXTIME = 4 * 365 * 86400;
    // Overall balance that is claimable
    uint256 public balance;
    // OLAS token address
    address public immutable olasToken;
    // veOLAS token address
    address public immutable veToken;
    // buOLAS token address
    address public immutable buToken;
    // Owner address
    address public owner;
    // Mapping of account address => ClaimableBalance to lock for veOLAS
    mapping(address => ClaimableBalance) public mapVE;
    // Mapping of account address => ClaimableBalance to lock for buOLAS
    mapping(address => ClaimableBalance) public mapBU;

    
    
    
    
    constructor(address _olasToken, address _veToken, address _buToken)
    {
        olasToken = _olasToken;
        veToken = _veToken;
        buToken = _buToken;
        owner = msg.sender;
        // Issue allowance for veOLAS and buOLAS. These contracts are always trusted
        IOLAS(_olasToken).approve(address(_veToken), type(uint256).max);
        IOLAS(_olasToken).approve(address(_buToken), type(uint256).max);
    }

    
    
    function changeOwner(address newOwner) external {
        if (newOwner == address(0)) {
            revert ZeroAddress();
        }

        if (msg.sender != owner) {
            revert OwnerOnly(msg.sender, owner);
        }

        owner = newOwner;
        emit OwnerUpdated(newOwner);
    }

    
    
    
    
    
    
    
    function createBalancesFor(
        address[] memory veAccounts,
        uint256[] memory veAmounts,
        uint256[] memory veLockTimes,
        address[] memory buAccounts,
        uint256[] memory buAmounts,
        uint256[] memory buNumSteps
    ) external {
        // Check for the ownership
        if (owner != msg.sender) {
            revert OwnerOnly(msg.sender, owner);
        }

        // Check that all the corresponding arrays have the same length
        if (veAccounts.length != veAmounts.length || veAccounts.length != veLockTimes.length) {
            revert WrongArrayLength(veAccounts.length, veAmounts.length);
        }
        if (buAccounts.length != buAmounts.length || buAccounts.length != buNumSteps.length) {
            revert WrongArrayLength(buAccounts.length, buAmounts.length);
        }

        // Get the overall amount balances
        uint256 veBalance;
        uint256 buBalance;

        // Create lock-ready structures for veOLAS
        for (uint256 i = 0; i < veAccounts.length; ++i) {
            // Check for the zero addresses
            if (veAccounts[i] == address(0)) {
                revert ZeroAddress();
            }
            // Check for other zero values
            if (veAmounts[i] == 0) {
                revert ZeroValue();
            }
            // Check for the amount bounds
            if (veAmounts[i] > type(uint128).max) {
                revert Overflow(veAmounts[i], type(uint128).max);
            }
            // Check the end of a lock time
            if (veLockTimes[i] < MINTIME) {
                revert UnlockTimeIncorrect(veAccounts[i], MINTIME, veLockTimes[i]);
            }
            if (veLockTimes[i] > MAXTIME) {
                revert MaxUnlockTimeReached(veAccounts[i], MAXTIME, veLockTimes[i]);
            }
            // Check if the lock has already been placed
            ClaimableBalance memory lockedBalance = mapVE[veAccounts[i]];
            if (lockedBalance.amount > 0) {
                revert NonZeroValue();
            }

            // Update allowance, push values to the dedicated locking slot
            veBalance += veAmounts[i];
            lockedBalance.amount = uint128(veAmounts[i]);
            lockedBalance.period = uint64(veLockTimes[i]);
            mapVE[veAccounts[i]] = lockedBalance;

            emit CreateVE(veAccounts[i], veAmounts[i], veLockTimes[i]);
        }

        // Create lock-ready structures for buOLAS
        for (uint256 i = 0; i < buAccounts.length; ++i) {
            // Check for the zero addresses
            if (buAccounts[i] == address(0)) {
                revert ZeroAddress();
            }
            // Check for other zero values
            if (buAmounts[i] == 0 || buNumSteps[i] == 0) {
                revert ZeroValue();
            }
            // Check for the amount bounds
            if (buAmounts[i] > type(uint128).max) {
                revert Overflow(buAmounts[i], type(uint128).max);
            }
            // Check for the number of lock steps
            if (buNumSteps[i] > MAX_NUM_STEPS) {
                revert Overflow(buNumSteps[i], MAX_NUM_STEPS);
            }
            // Check if the lock has already been placed
            ClaimableBalance memory lockedBalance = mapBU[buAccounts[i]];
            if (lockedBalance.amount > 0) {
                revert NonZeroValue();
            }

            // Update allowance, push values to the dedicated locking slot
            buBalance += buAmounts[i];
            lockedBalance.amount = uint128(buAmounts[i]);
            lockedBalance.period = uint64(buNumSteps[i]);
            mapBU[buAccounts[i]] = lockedBalance;

            emit CreateBU(buAccounts[i], buAmounts[i], buNumSteps[i]);
        }

        // Own balance cannot be smaller than the sum of balances for all the accounts plus the previous balance
        uint256 curBalance = IOLAS(olasToken).balanceOf(address(this));
        uint256 balanceAfter = balance + buBalance + veBalance;
        if (curBalance < balanceAfter) {
            revert InsufficientAllowance(balanceAfter, curBalance);
        }
        balance = balanceAfter;
    }

    
    function claim() external {
        uint256 balanceClaim;
        // Get the balance, lock time and call the veOLAS locking function
        ClaimableBalance memory lockedBalance = mapVE[msg.sender];
        if (lockedBalance.amount > 0) {
            // We need to update the balance tracker
            balanceClaim = uint256(lockedBalance.amount);
            ILOCK(veToken).createLockFor(msg.sender, uint256(lockedBalance.amount), uint256(lockedBalance.period));
            mapVE[msg.sender] = ClaimableBalance(0, 0);
            emit ClaimVE(msg.sender, uint256(lockedBalance.amount), uint256(lockedBalance.period));
        }

        lockedBalance = mapBU[msg.sender];
        if (lockedBalance.amount > 0) {
            balanceClaim += uint256(lockedBalance.amount);
            ILOCK(buToken).createLockFor(msg.sender, uint256(lockedBalance.amount), uint256(lockedBalance.period));
            mapBU[msg.sender] = ClaimableBalance(0, 0);
            emit ClaimBU(msg.sender, uint256(lockedBalance.amount), uint256(lockedBalance.period));
        }

        // Check if anything was claimed
        if (balanceClaim == 0) {
            revert ZeroValue();
        }

        // The overall balance can not be smaller than the claimable balance, since createBalancesFor would revert before
        unchecked {
            balance -= balanceClaim;
        }
    }

    
    
    
    
    function claimableBalances(address account) external view returns (uint256 veBalance, uint256 buBalance) {
        veBalance = uint256(mapVE[account].amount);
        buBalance = uint256(mapBU[account].amount);
    }
}
