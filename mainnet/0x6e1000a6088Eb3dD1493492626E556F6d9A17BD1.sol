// SPDX-License-Identifier: GPL-3.0-only


// 

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.7.0;





interface IAntePool {
    
    
    
    
    event Stake(address indexed staker, uint256 amount, bool indexed isChallenger);

    
    
    
    
    event Unstake(address indexed staker, uint256 amount, bool indexed isChallenger);

    
    
    event TestChecked(address indexed checker);

    
    
    event FailureOccurred(address indexed checker);

    
    
    
    event ClaimPaid(address indexed claimer, uint256 amount);

    
    
    
    event WithdrawStake(address indexed staker, uint256 amount);

    
    
    
    event CancelWithdraw(address indexed staker, uint256 amount);

    
    
    
    /// the invariant validation currently passes
    function initialize(IAnteTest _anteTest) external;

    
    
    /// then decides to cancel that withdraw before the 24 hour wait period is over
    function cancelPendingWithdraw() external;

    
    
    function checkTest() external;

    
    
    /// claiming and that balance is zeroed out once the claim is done
    function claim() external;

    
    
    function stake(bool isChallenger) external payable;

    
    
    
    function unstake(uint256 amount, bool isChallenger) external;

    
    
    function unstakeAll(bool isChallenger) external;

    
    
    /// decay amounts and pools accurate
    function updateDecay() external;

    
    
    /// users from removing their stake when a challenger is going to verify test
    function withdrawStake() external;

    
    
    function anteTest() external view returns (IAnteTest);

    
    
    ///         totalAmount The total value locked in the challenger pool in wei
    ///         decayMultiplier The current multiplier for decay
    function challengerInfo()
        external
        view
        returns (
            uint256 numUsers,
            uint256 totalAmount,
            uint256 decayMultiplier
        );

    
    
    ///         totalAmount The total value locked in the staker pool in wei
    ///         decayMultiplier The current multiplier for decay
    function stakingInfo()
        external
        view
        returns (
            uint256 numUsers,
            uint256 totalAmount,
            uint256 decayMultiplier
        );

    
    
    /// 12 blocks to receive payout, this is to mitigate other challengers
    /// from trying to stick in a challenge right before the verification
    
    function eligibilityInfo() external view returns (uint256 eligibleAmount);

    
    
    function factory() external view returns (address);

    
    
    /// have logically failed beforehand, but without having a user initiating
    /// the verify test action
    
    function failedBlock() external view returns (uint256);

    
    
    
    /// value is an estimate
    
    function getChallengerPayout(address challenger) external view returns (uint256);

    
    
    
    /// withdraw process
    
    function getPendingWithdrawAllowedTime(address _user) external view returns (uint256);

    
    
    
    function getPendingWithdrawAmount(address _user) external view returns (uint256);

    
    
    
    
    /// decay has been either added (staker) or subtracted (challenger)
    
    function getStoredBalance(address _user, bool isChallenger) external view returns (uint256);

    
    
    function getTotalChallengerEligibleBalance() external view returns (uint256);

    
    
    function getTotalChallengerStaked() external view returns (uint256);

    
    
    function getTotalPendingWithdraw() external view returns (uint256);

    
    
    function getTotalStaked() external view returns (uint256);

    
    
    
    
    /// added to respective side
    
    function getUserStartAmount(address _user, bool isChallenger) external view returns (uint256);

    
    
    
    function getVerifierBounty() external view returns (uint256);

    
    
    
    function getCheckTestAllowedBlock(address _user) external view returns (uint256);

    
    
    /// Pool contract
    
    function lastUpdateBlock() external view returns (uint256);

    
    
    /// the Ante Test fails
    
    function lastVerifiedBlock() external view returns (uint256);

    
    
    function numPaidOut() external view returns (uint256);

    
    
    function numTimesVerified() external view returns (uint256);

    
    
    function pendingFailure() external view returns (bool);

    
    
    function totalPaidOut() external view returns (uint256);

    
    
    
    function verifier() external view returns (address);

    
    
    function withdrawInfo() external view returns (uint256 totalAmount);
}
// 

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.7.0;











contract AntePool is IAntePool {
    using SafeMath for uint256;
    using FullMath for uint256;
    using Address for address;
    using IterableAddressSetUtils for IterableAddressSetUtils.IterableAddressSet;

    
    struct UserInfo {
        // How much ETH this user deposited.
        uint256 startAmount;
        // How much decay this side of the pool accrued between (0, this user's
        // entry block), stored as a multiplier expressed as an 18-decimal
        // mantissa. For example, if this side of the pool accrued a decay of
        // 20% during this time period, we'd store 1.2e18 (staking side) or
        // 0.8e18 (challenger side).
        uint256 startDecayMultiplier;
    }

    
    struct PoolSideInfo {
        mapping(address => UserInfo) userInfo;
        // Number of users on this side of the pool.
        uint256 numUsers;
        // Amount staked across all users on this side of the pool, as of
        // `lastUpdateBlock`.`
        uint256 totalAmount;
        // How much decay this side of the pool accrued between (0,
        // lastUpdateBlock), stored as a multiplier expressed as an 18-decimal
        // mantissa. For example, if this side of the pool accrued a decay of
        // 20% during this time period, we'd store 1.2e18 (staking side) or
        // 0.8e18 (challenger side).
        uint256 decayMultiplier;
    }

    
    struct ChallengerEligibilityInfo {
        // Used when test fails to determine which challengers should receive payout
        // i.e., those which haven't staked within 12 blocks prior to test failure
        mapping(address => uint256) lastStakedBlock;
        uint256 eligibleAmount;
    }

    
    struct StakerWithdrawInfo {
        mapping(address => UserUnstakeInfo) userUnstakeInfo;
        uint256 totalAmount;
    }

    
    struct UserUnstakeInfo {
        uint256 lastUnstakeTimestamp;
        uint256 amount;
    }

    
    IAnteTest public override anteTest;
    
    address public override factory;
    
    
    /// people staking in uninitialized pools
    bool public override pendingFailure = true;
    
    uint256 public override numTimesVerified;
    
    uint256 public constant VERIFIER_BOUNTY = 5;
    
    uint256 public override failedBlock;
    
    uint256 public override lastVerifiedBlock;
    
    address public override verifier;
    
    uint256 public override numPaidOut;
    
    uint256 public override totalPaidOut;

    
    bool internal _initialized = false;
    
    uint256 internal _bounty;
    
    uint256 internal _remainingStake;

    
    /// 100 gwei decay per block per ETH is ~20-25% decay per year
    uint256 public constant DECAY_RATE_PER_BLOCK = 100 gwei;

    
    /// eligible for paytout on test failure
    uint8 public constant CHALLENGER_BLOCK_DELAY = 12;

    
    uint256 public constant MIN_CHALLENGER_STAKE = 1e16;

    
    /// starts when staker initiates the unstake action
    uint256 public constant UNSTAKE_DELAY = 24 hours;

    
    uint256 private constant ONE = 1e18;

    
    PoolSideInfo public override stakingInfo;
    
    PoolSideInfo public override challengerInfo;
    
    ChallengerEligibilityInfo public override eligibilityInfo;
    
    IterableAddressSetUtils.IterableAddressSet private challengers;
    
    StakerWithdrawInfo public override withdrawInfo;

    
    uint256 public override lastUpdateBlock;

    
    modifier testNotFailed() {
        _testNotFailed();
        _;
    }

    modifier notInitialized() {
        require(!_initialized, "ANTE: Pool already initialized");
        _;
    }

    
    /// the address of the factory here
    constructor() {
        factory = msg.sender;
        stakingInfo.decayMultiplier = ONE;
        challengerInfo.decayMultiplier = ONE;
        lastUpdateBlock = block.number;
    }

    
    function initialize(IAnteTest _anteTest) external override notInitialized {
        require(msg.sender == factory, "ANTE: only factory can initialize AntePool");
        require(address(_anteTest).isContract(), "ANTE: AnteTest must be a smart contract");
        // Check that anteTest has checkTestPasses function and that it currently passes
        // place check here to minimize reentrancy risk - most external function calls are locked
        // while pendingFailure is true
        require(_anteTest.checkTestPasses(), "ANTE: AnteTest does not implement checkTestPasses or test fails");

        _initialized = true;
        pendingFailure = false;
        anteTest = _anteTest;
    }

    /*****************************************************
     * ================ USER INTERFACE ================= *
     *****************************************************/

    
    
    function stake(bool isChallenger) external payable override testNotFailed {
        uint256 amount = msg.value;
        require(amount > 0, "ANTE: Cannot stake zero");

        updateDecay();

        PoolSideInfo storage side;
        if (isChallenger) {
            require(amount >= MIN_CHALLENGER_STAKE, "ANTE: Challenger must stake more than 0.01 ETH");
            side = challengerInfo;

            // Record challenger info for future use
            // Challengers are not eligible for rewards if challenging within 12 block window of test failure
            challengers.insert(msg.sender);
            eligibilityInfo.lastStakedBlock[msg.sender] = block.number;
        } else {
            side = stakingInfo;
        }

        UserInfo storage user = side.userInfo[msg.sender];

        // Calculate how much the user already has staked, including the
        // effects of any previously accrued decay.
        //   prevAmount = startAmount * decayMultipiler / startDecayMultiplier
        //   newAmount = amount + prevAmount
        if (user.startAmount > 0) {
            user.startAmount = amount.add(_storedBalance(user, side));
        } else {
            user.startAmount = amount;
            side.numUsers = side.numUsers.add(1);
        }
        side.totalAmount = side.totalAmount.add(amount);

        // Reset the startDecayMultiplier for this user, since we've updated
        // the startAmount to include any already-accrued decay.
        user.startDecayMultiplier = side.decayMultiplier;

        emit Stake(msg.sender, amount, isChallenger);
    }

    
    
    function unstake(uint256 amount, bool isChallenger) external override testNotFailed {
        require(amount > 0, "ANTE: Cannot unstake 0.");

        updateDecay();

        PoolSideInfo storage side = isChallenger ? challengerInfo : stakingInfo;

        UserInfo storage user = side.userInfo[msg.sender];
        _unstake(amount, isChallenger, side, user);
    }

    
    function unstakeAll(bool isChallenger) external override testNotFailed {
        updateDecay();

        PoolSideInfo storage side = isChallenger ? challengerInfo : stakingInfo;

        UserInfo storage user = side.userInfo[msg.sender];

        uint256 amount = _storedBalance(user, side);
        require(amount > 0, "ANTE: Nothing to unstake");

        _unstake(amount, isChallenger, side, user);
    }

    
    function withdrawStake() external override testNotFailed {
        UserUnstakeInfo storage unstakeUser = withdrawInfo.userUnstakeInfo[msg.sender];

        require(
            unstakeUser.lastUnstakeTimestamp < block.timestamp - UNSTAKE_DELAY,
            "ANTE: must wait 24 hours to withdraw stake"
        );
        require(unstakeUser.amount > 0, "ANTE: Nothing to withdraw");

        uint256 amount = unstakeUser.amount;
        withdrawInfo.totalAmount = withdrawInfo.totalAmount.sub(amount);
        unstakeUser.amount = 0;

        _safeTransfer(msg.sender, amount);

        emit WithdrawStake(msg.sender, amount);
    }

    
    function cancelPendingWithdraw() external override testNotFailed {
        UserUnstakeInfo storage unstakeUser = withdrawInfo.userUnstakeInfo[msg.sender];

        require(unstakeUser.amount > 0, "ANTE: No pending withdraw balance");
        uint256 amount = unstakeUser.amount;
        unstakeUser.amount = 0;

        updateDecay();

        UserInfo storage user = stakingInfo.userInfo[msg.sender];
        if (user.startAmount > 0) {
            user.startAmount = amount.add(_storedBalance(user, stakingInfo));
        } else {
            user.startAmount = amount;
            stakingInfo.numUsers = stakingInfo.numUsers.add(1);
        }
        stakingInfo.totalAmount = stakingInfo.totalAmount.add(amount);
        user.startDecayMultiplier = stakingInfo.decayMultiplier;

        withdrawInfo.totalAmount = withdrawInfo.totalAmount.sub(amount);

        emit CancelWithdraw(msg.sender, amount);
    }

    
    function checkTest() external override testNotFailed {
        require(challengers.exists(msg.sender), "ANTE: Only challengers can checkTest");
        require(
            block.number.sub(eligibilityInfo.lastStakedBlock[msg.sender]) > CHALLENGER_BLOCK_DELAY,
            "ANTE: must wait 12 blocks after challenging to call checkTest"
        );

        numTimesVerified = numTimesVerified.add(1);
        lastVerifiedBlock = block.number;
        emit TestChecked(msg.sender);
        if (!_checkTestNoRevert()) {
            updateDecay();
            verifier = msg.sender;
            failedBlock = block.number;
            pendingFailure = true;

            _calculateChallengerEligibility();
            _bounty = getVerifierBounty();

            uint256 totalStake = stakingInfo.totalAmount.add(withdrawInfo.totalAmount);
            _remainingStake = totalStake.sub(_bounty);

            emit FailureOccurred(msg.sender);
        }
    }

    
    function claim() external override {
        require(pendingFailure, "ANTE: Test has not failed");

        UserInfo storage user = challengerInfo.userInfo[msg.sender];
        require(user.startAmount > 0, "ANTE: No Challenger Staking balance");

        uint256 amount = _calculateChallengerPayout(user, msg.sender);
        // Zero out the user so they can't claim again.
        user.startAmount = 0;

        numPaidOut = numPaidOut.add(1);
        totalPaidOut = totalPaidOut.add(amount);

        _safeTransfer(msg.sender, amount);
        emit ClaimPaid(msg.sender, amount);
    }

    
    function updateDecay() public override {
        (uint256 decayMultiplierThisUpdate, uint256 decayThisUpdate) = _computeDecay();

        lastUpdateBlock = block.number;

        if (decayThisUpdate == 0) return;

        uint256 totalStaked = stakingInfo.totalAmount;
        uint256 totalChallengerStaked = challengerInfo.totalAmount;

        // update totoal accrued decay amounts for challengers
        // decayMultiplier for challengers = decayMultiplier for challengers * decayMultiplierThisUpdate
        // totalChallengerStaked = totalChallengerStaked - decayThisUpdate
        challengerInfo.decayMultiplier = challengerInfo.decayMultiplier.mulDiv(decayMultiplierThisUpdate, ONE);
        challengerInfo.totalAmount = totalChallengerStaked.sub(decayThisUpdate);

        // Update the new accrued decay amounts for stakers.
        //   totalStaked_new = totalStaked_old + decayThisUpdate
        //   decayMultipilerThisUpdate = totalStaked_new / totalStaked_old
        //   decayMultiplier_staker = decayMultiplier_staker * decayMultiplierThisUpdate
        uint256 totalStakedNew = totalStaked.add(decayThisUpdate);

        stakingInfo.decayMultiplier = stakingInfo.decayMultiplier.mulDiv(totalStakedNew, totalStaked);
        stakingInfo.totalAmount = totalStakedNew;
    }

    /*****************************************************
     * ================ VIEW FUNCTIONS ================= *
     *****************************************************/

    
    function getTotalChallengerStaked() external view override returns (uint256) {
        return challengerInfo.totalAmount;
    }

    
    function getTotalStaked() external view override returns (uint256) {
        return stakingInfo.totalAmount;
    }

    
    function getTotalPendingWithdraw() external view override returns (uint256) {
        return withdrawInfo.totalAmount;
    }

    
    function getTotalChallengerEligibleBalance() external view override returns (uint256) {
        return eligibilityInfo.eligibleAmount;
    }

    
    function getChallengerPayout(address challenger) external view override returns (uint256) {
        UserInfo storage user = challengerInfo.userInfo[challenger];
        require(user.startAmount > 0, "ANTE: No Challenger Staking balance");

        // If called before test failure returns an estimate
        if (pendingFailure) {
            return _calculateChallengerPayout(user, challenger);
        } else {
            uint256 amount = _storedBalance(user, challengerInfo);
            uint256 bounty = getVerifierBounty();
            uint256 totalStake = stakingInfo.totalAmount.add(withdrawInfo.totalAmount);

            return amount.add(amount.mulDiv(totalStake.sub(bounty), challengerInfo.totalAmount));
        }
    }

    
    function getStoredBalance(address _user, bool isChallenger) external view override returns (uint256) {
        (uint256 decayMultiplierThisUpdate, uint256 decayThisUpdate) = _computeDecay();

        UserInfo storage user = isChallenger ? challengerInfo.userInfo[_user] : stakingInfo.userInfo[_user];

        if (user.startAmount == 0) return 0;

        require(user.startDecayMultiplier > 0, "ANTE: Invalid startDecayMultiplier");

        uint256 decayMultiplier;

        if (isChallenger) {
            decayMultiplier = challengerInfo.decayMultiplier.mul(decayMultiplierThisUpdate).div(1e18);
        } else {
            uint256 totalStaked = stakingInfo.totalAmount;
            uint256 totalStakedNew = totalStaked.add(decayThisUpdate);
            decayMultiplier = stakingInfo.decayMultiplier.mul(totalStakedNew).div(totalStaked);
        }

        return user.startAmount.mulDiv(decayMultiplier, user.startDecayMultiplier);
    }

    
    function getPendingWithdrawAmount(address _user) external view override returns (uint256) {
        return withdrawInfo.userUnstakeInfo[_user].amount;
    }

    
    function getPendingWithdrawAllowedTime(address _user) external view override returns (uint256) {
        UserUnstakeInfo storage user = withdrawInfo.userUnstakeInfo[_user];
        require(user.amount > 0, "ANTE: nothing to withdraw");

        return user.lastUnstakeTimestamp.add(UNSTAKE_DELAY);
    }

    
    function getCheckTestAllowedBlock(address _user) external view override returns (uint256) {
        return eligibilityInfo.lastStakedBlock[_user].add(CHALLENGER_BLOCK_DELAY);
    }

    
    function getUserStartAmount(address _user, bool isChallenger) external view override returns (uint256) {
        return isChallenger ? challengerInfo.userInfo[_user].startAmount : stakingInfo.userInfo[_user].startAmount;
    }

    
    function getVerifierBounty() public view override returns (uint256) {
        uint256 totalStake = stakingInfo.totalAmount.add(withdrawInfo.totalAmount);
        return totalStake.mul(VERIFIER_BOUNTY).div(100);
    }

    /*****************************************************
     * =============== INTERNAL HELPERS ================ *
     *****************************************************/

    
    
    
    
    
    
    /// immediately, if the user is a staker, the amount is moved to the withdraw
    /// info and then the 24 hour waiting period starts
    function _unstake(
        uint256 amount,
        bool isChallenger,
        PoolSideInfo storage side,
        UserInfo storage user
    ) internal {
        // Calculate how much the user has available to unstake, including the
        // effects of any previously accrued decay.
        //   prevAmount = startAmount * decayMultiplier / startDecayMultiplier
        uint256 prevAmount = _storedBalance(user, side);

        if (prevAmount == amount) {
            user.startAmount = 0;
            user.startDecayMultiplier = 0;
            side.numUsers = side.numUsers.sub(1);

            // Remove from set of existing challengers
            if (isChallenger) challengers.remove(msg.sender);
        } else {
            require(amount <= prevAmount, "ANTE: Withdraw request exceeds balance.");
            user.startAmount = prevAmount.sub(amount);
            // Reset the startDecayMultiplier for this user, since we've updated
            // the startAmount to include any already-accrued decay.
            user.startDecayMultiplier = side.decayMultiplier;
        }
        side.totalAmount = side.totalAmount.sub(amount);

        if (isChallenger) _safeTransfer(msg.sender, amount);
        else {
            // Just initiate the withdraw if staker
            UserUnstakeInfo storage unstakeUser = withdrawInfo.userUnstakeInfo[msg.sender];
            unstakeUser.lastUnstakeTimestamp = block.timestamp;
            unstakeUser.amount = unstakeUser.amount.add(amount);

            withdrawInfo.totalAmount = withdrawInfo.totalAmount.add(amount);
        }

        emit Unstake(msg.sender, amount, isChallenger);
    }

    
    
    /// decay computation
    
    
    function _computeDecay() internal view returns (uint256 decayMultiplierThisUpdate, uint256 decayThisUpdate) {
        decayThisUpdate = 0;
        decayMultiplierThisUpdate = ONE;

        if (block.number <= lastUpdateBlock) {
            return (decayMultiplierThisUpdate, decayThisUpdate);
        }
        // Stop charging decay if the test already failed.
        if (pendingFailure) {
            return (decayMultiplierThisUpdate, decayThisUpdate);
        }
        // If we have no stakers or challengers, don't charge any decay.
        uint256 totalStaked = stakingInfo.totalAmount;
        uint256 totalChallengerStaked = challengerInfo.totalAmount;
        if (totalStaked == 0 || totalChallengerStaked == 0) {
            return (decayMultiplierThisUpdate, decayThisUpdate);
        }

        uint256 numBlocks = block.number.sub(lastUpdateBlock);

        // The rest of the function updates the new accrued decay amounts
        //   decayRateThisUpdate = DECAY_RATE_PER_BLOCK * numBlocks
        //   decayMultiplierThisUpdate = 1 - decayRateThisUpdate
        //   decayThisUpdate = totalChallengerStaked * decayRateThisUpdate
        uint256 decayRateThisUpdate = DECAY_RATE_PER_BLOCK.mul(numBlocks);

        // Failsafe to avoid underflow when calculating decayMultiplierThisUpdate
        if (decayRateThisUpdate >= ONE) {
            decayMultiplierThisUpdate = 0;
            decayThisUpdate = totalChallengerStaked;
        } else {
            decayMultiplierThisUpdate = ONE.sub(decayRateThisUpdate);
            decayThisUpdate = totalChallengerStaked.mulDiv(decayRateThisUpdate, ONE);
        }
    }

    
    
    /// will not get a payout but will be able to withdraw their capital
    /// (minus decay)
    function _calculateChallengerEligibility() internal {
        uint256 cutoffBlock = failedBlock.sub(CHALLENGER_BLOCK_DELAY);
        for (uint256 i = 0; i < challengers.addresses.length; i++) {
            address challenger = challengers.addresses[i];
            if (eligibilityInfo.lastStakedBlock[challenger] < cutoffBlock) {
                eligibilityInfo.eligibleAmount = eligibilityInfo.eligibleAmount.add(
                    _storedBalance(challengerInfo.userInfo[challenger], challengerInfo)
                );
            }
        }
    }

    
    
    function _checkTestNoRevert() internal returns (bool) {
        try anteTest.checkTestPasses() returns (bool passes) {
            return passes;
        } catch {
            return false;
        }
    }

    
    
    
    
    /// are no longer estimates
    
    function _calculateChallengerPayout(UserInfo storage user, address challenger) internal view returns (uint256) {
        // Calculate this user's challenging balance.
        uint256 amount = _storedBalance(user, challengerInfo);
        // Calculate how much of the staking pool this user gets, and add that
        // to the user's challenging balance.
        if (eligibilityInfo.lastStakedBlock[challenger] < failedBlock.sub(CHALLENGER_BLOCK_DELAY)) {
            amount = amount.add(amount.mulDiv(_remainingStake, eligibilityInfo.eligibleAmount));
        }

        return challenger == verifier ? amount.add(_bounty) : amount;
    }

    
    
    
    
    
    function _storedBalance(UserInfo storage user, PoolSideInfo storage side) internal view returns (uint256) {
        if (user.startAmount == 0) return 0;

        require(user.startDecayMultiplier > 0, "ANTE: Invalid startDecayMultiplier");
        return user.startAmount.mulDiv(side.decayMultiplier, user.startDecayMultiplier);
    }

    
    
    
    
    /// pool to not have enough ETH
    function _safeTransfer(address payable to, uint256 amount) internal {
        to.transfer(_min(amount, address(this).balance));
    }

    
    
    
    
    function _min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    
    function _testNotFailed() internal {
        require(!pendingFailure, "ANTE: Test already failed.");
    }
}

// 

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// 

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// 

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.7.0;



interface IAnteTest {
    
    
    
    function testAuthor() external view returns (address);

    
    
    
    function protocolName() external view returns (string memory);

    
    
    
    
    function testedContracts(uint256 i) external view returns (address);

    
    
    
    function testName() external view returns (string memory);

    
    
    
    function checkTestPasses() external returns (bool);
}

// 

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.7.0;


/// and existence checks and dynamic arrays for enumeration. Key uniqueness is enforced.

/// fixed gas cost at any scale, O(1).
/// Code inspired by https://github.com/rob-Hitchens/SetTypes/blob/master/contracts/AddressSet.sol
/// and updated to solidity 0.7.x
library IterableAddressSetUtils {
    
    struct IterableAddressSet {
        mapping(address => uint256) indices;
        address[] addresses;
    }

    
    
    
    
    function insert(IterableAddressSet storage self, address key) internal {
        if (!exists(self, key)) {
            self.addresses.push(key);
            self.indices[key] = self.addresses.length - 1;
        }
    }

    
    
    
    
    function remove(IterableAddressSet storage self, address key) internal {
        if (!exists(self, key)) {
            return;
        }

        uint256 last = self.addresses.length - 1;
        uint256 indexToReplace = self.indices[key];
        if (indexToReplace != last) {
            address keyToMove = self.addresses[last];
            self.indices[keyToMove] = indexToReplace;
            self.addresses[indexToReplace] = keyToMove;
        }

        delete self.indices[key];
        self.addresses.pop();
    }

    
    
    
    
    function exists(IterableAddressSet storage self, address key) internal view returns (bool) {
        if (self.addresses.length == 0) return false;

        return self.addresses[self.indices[key]] == key;
    }
}

// 

pragma solidity >=0.7.0;

// taken with <3 from https://github.com/Uniswap/uniswap-v3-core/blob/main/contracts/libraries/FullMath.sol
// under the MIT license


/// intermediate value without any loss of precision

/// where an intermediate value overflows 256 bits
library FullMath {
    
    /// or denominator == 0
    
    
    
    
    
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // 512-bit multiply [prod1 prod0] = a * b
        // Compute the product mod 2**256 and mod 2**256 - 1
        // then use the Chinese Remainder Theorem to reconstruct
        // the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2**256 + prod0
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Handle non-overflow cases, 256 by 256 division
        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        // Make sure the result is less than 2**256.
        // Also prevents denominator == 0
        require(denominator > prod1);

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Make division exact by subtracting the remainder from [prod1 prod0]
        // Compute remainder using mulmod
        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        // Subtract 256 bit number from 512 bit number
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator
        // Compute largest power of two divisor of denominator.
        // Always >= 1.
        uint256 twos = -denominator & denominator;
        // Divide denominator by power of two
        assembly {
            denominator := div(denominator, twos)
        }

        // Divide [prod1 prod0] by the factors of two
        assembly {
            prod0 := div(prod0, twos)
        }
        // Shift in bits from prod1 into prod0. For this we need
        // to flip `twos` such that it is 2**256 / twos.
        // If twos is zero, then it becomes one
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        // Invert denominator mod 2**256
        // Now that denominator is an odd number, it has an inverse
        // modulo 2**256 such that denominator * inv = 1 mod 2**256.
        // Compute the inverse by starting with a seed that is correct
        // correct for four bits. That is, denominator * inv = 1 mod 2**4
        uint256 inv = (3 * denominator) ^ 2;
        // Now use Newton-Raphson iteration to improve the precision.
        // Thanks to Hensel's lifting lemma, this also works in modular
        // arithmetic, doubling the correct bits in each step.
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256

        // Because the division is now exact we can divide by multiplying
        // with the modular inverse of denominator. This will give us the
        // correct result modulo 2**256. Since the precoditions guarantee
        // that the outcome is less than 2**256, this is the final result.
        // We don't need to compute the high bits of the result and prod1
        // is no longer required.
        result = prod0 * inv;
        return result;
    }
}
