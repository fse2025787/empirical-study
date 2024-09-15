
/**
 *Submitted for verification at Etherscan.io on 2021-07-08
*/

// Sources flattened with hardhat v2.4.0 https://hardhat.org

// File contracts/auxiliary/interfaces/v0.8.4/IERC20Aux.sol


pragma solidity 0.8.4;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Aux {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File contracts/auxiliary/interfaces/v0.8.4/IApi3Token.sol

pragma solidity 0.8.4;

interface IApi3Token is IERC20Aux {
    event MinterStatusUpdated(
        address indexed minterAddress,
        bool minterStatus
        );

    event BurnerStatusUpdated(
        address indexed burnerAddress,
        bool burnerStatus
        );

    function updateMinterStatus(
        address minterAddress,
        bool minterStatus
        )
        external;

    function updateBurnerStatus(bool burnerStatus)
        external;

    function mint(
        address account,
        uint256 amount
        )
        external;

    function burn(uint256 amount)
        external;

    function getMinterStatus(address minterAddress)
        external
        view
        returns (bool minterStatus);

    function getBurnerStatus(address burnerAddress)
        external
        view
        returns (bool burnerStatus);
}


// File contracts/interfaces/IStateUtils.sol

pragma solidity 0.8.4;

interface IStateUtils {
    event SetDaoApps(
        address agentAppPrimary,
        address agentAppSecondary,
        address votingAppPrimary,
        address votingAppSecondary
        );

    event SetClaimsManagerStatus(
        address indexed claimsManager,
        bool indexed status
        );

    event SetStakeTarget(uint256 stakeTarget);

    event SetMaxApr(uint256 maxApr);

    event SetMinApr(uint256 minApr);

    event SetUnstakeWaitPeriod(uint256 unstakeWaitPeriod);

    event SetAprUpdateStep(uint256 aprUpdateStep);

    event SetProposalVotingPowerThreshold(uint256 proposalVotingPowerThreshold);

    event UpdatedLastProposalTimestamp(
        address indexed user,
        uint256 lastProposalTimestamp,
        address votingApp
        );

    function setDaoApps(
        address _agentAppPrimary,
        address _agentAppSecondary,
        address _votingAppPrimary,
        address _votingAppSecondary
        )
        external;

    function setClaimsManagerStatus(
        address claimsManager,
        bool status
        )
        external;

    function setStakeTarget(uint256 _stakeTarget)
        external;

    function setMaxApr(uint256 _maxApr)
        external;

    function setMinApr(uint256 _minApr)
        external;

    function setUnstakeWaitPeriod(uint256 _unstakeWaitPeriod)
        external;

    function setAprUpdateStep(uint256 _aprUpdateStep)
        external;

    function setProposalVotingPowerThreshold(uint256 _proposalVotingPowerThreshold)
        external;

    function updateLastProposalTimestamp(address userAddress)
        external;

    function isGenesisEpoch()
        external
        view
        returns (bool);
}


// File contracts/StateUtils.sol

pragma solidity 0.8.4;



contract StateUtils is IStateUtils {
    struct Checkpoint {
        uint32 fromBlock;
        uint224 value;
    }

    struct AddressCheckpoint {
        uint32 fromBlock;
        address _address;
    }

    struct Reward {
        uint32 atBlock;
        uint224 amount;
        uint256 totalSharesThen;
        uint256 totalStakeThen;
    }

    struct User {
        Checkpoint[] shares;
        Checkpoint[] delegatedTo;
        AddressCheckpoint[] delegates;
        uint256 unstaked;
        uint256 vesting;
        uint256 unstakeAmount;
        uint256 unstakeShares;
        uint256 unstakeScheduledFor;
        uint256 lastDelegationUpdateTimestamp;
        uint256 lastProposalTimestamp;
    }

    struct LockedCalculation {
        uint256 initialIndEpoch;
        uint256 nextIndEpoch;
        uint256 locked;
    }

    
    /// once. It is hardcoded as 7 days.
    
    /// for two additional things:
    /// (1) After a user makes a proposal, they cannot make a second one
    /// before `EPOCH_LENGTH` has passed
    /// (2) After a user updates their delegation status, they have to wait
    /// `EPOCH_LENGTH` before updating it again
    uint256 public constant EPOCH_LENGTH = 1 weeks;

    
    /// Hardcoded as 52 epochs, which approximately corresponds to a year with
    /// an `EPOCH_LENGTH` of 1 week.
    uint256 public constant REWARD_VESTING_PERIOD = 52;

    // All percentage values are represented as 1e18 = 100%
    uint256 internal constant ONE_PERCENT = 1e18 / 100;
    uint256 internal constant HUNDRED_PERCENT = 1e18;

    // To assert that typecasts do not overflow
    uint256 internal constant MAX_UINT32 = 2**32 - 1;
    uint256 internal constant MAX_UINT224 = 2**224 - 1;

    
    /// `genesisEpoch` is the index of the epoch in which the pool is deployed.
    
    /// epoch
    uint256 public immutable genesisEpoch;

    
    IApi3Token public immutable api3Token;

    
    address public immutable timelockManager;

    
    
    /// The primary Api3Voting app requires a higher quorum by default, and the
    /// primary Agent is more privileged.
    address public agentAppPrimary;

    
    
    /// app. The secondary Api3Voting app requires a lower quorum by default,
    /// and the primary Agent is less privileged.
    address public agentAppSecondary;

    
    
    address public votingAppPrimary;

    
    
    address public votingAppSecondary;

    
    
    /// claims from the staking pool, effectively slashing the stakers. The
    /// statuses are kept as a mapping to support multiple claims managers.
    mapping(address => bool) public claimsManagerStatus;

    
    
    /// reward was paid for that epoch
    mapping(uint256 => Reward) public epochIndexToReward;

    
    uint256 public epochIndexOfLastReward;

    
    uint256 public totalStake;

    
    /// total token supply. The staking rewards increase if the total staked
    /// amount is below this, and vice versa.
    
    /// parameter is governable by the DAO.
    uint256 public stakeTarget = ONE_PERCENT * 50;

    
    /// staking rewards in percentages
    
    uint256 public minApr = ONE_PERCENT * 25 / 10;

    
    /// staking rewards in percentages
    
    uint256 public maxApr = ONE_PERCENT * 75;

    
    
    uint256 public aprUpdateStep = ONE_PERCENT;

    
    /// `unstakeWaitPeriod` before being able to unstake. This is to prevent
    /// the stakers from frontrunning insurance claims by unstaking to evade
    /// them, or repeatedly unstake/stake to work around the proposal spam
    /// protection. The tokens awaiting to be unstaked during this period do
    /// not grant voting power or rewards.
    
    /// to set this to a value that is large enough to allow insurance claims
    /// to be resolved.
    uint256 public unstakeWaitPeriod = EPOCH_LENGTH;

    
    /// proposals (in percentages)
    
    /// Default value is 0.1%. This parameter is governable by the DAO.
    uint256 public proposalVotingPowerThreshold = ONE_PERCENT / 10;

    
    
    /// Every epoch (week), APR/52 of the total staked tokens will be added to
    /// the pool, effectively distributing them to the stakers.
    uint256 public apr = (maxApr + minApr) / 2;

    
    mapping(address => User) public users;

    // Keeps the total number of shares of the pool
    Checkpoint[] public poolShares;

    // Keeps user states used in `withdrawPrecalculated()` calls
    mapping(address => LockedCalculation) public userToLockedCalculation;

    // Kept to prevent third parties from frontrunning the initialization
    // `setDaoApps()` call and grief the deployment
    address private deployer;

    
    modifier onlyAgentApp() {
        require(
            msg.sender == agentAppPrimary || msg.sender == agentAppSecondary,
            "Pool: Caller not agent"
            );
        _;
    }

    
    modifier onlyAgentAppPrimary() {
        require(
            msg.sender == agentAppPrimary,
            "Pool: Caller not primary agent"
            );
        _;
    }

    
    modifier onlyVotingApp() {
        require(
            msg.sender == votingAppPrimary || msg.sender == votingAppSecondary,
            "Pool: Caller not voting app"
            );
        _;
    }

    
    
    constructor(
        address api3TokenAddress,
        address timelockManagerAddress
        )
    {
        require(
            api3TokenAddress != address(0),
            "Pool: Invalid Api3Token"
            );
        require(
            timelockManagerAddress != address(0),
            "Pool: Invalid TimelockManager"
            );
        deployer = msg.sender;
        api3Token = IApi3Token(api3TokenAddress);
        timelockManager = timelockManagerAddress;
        // Initialize the share price at 1
        updateCheckpointArray(poolShares, 1);
        totalStake = 1;
        // Set the current epoch as the genesis epoch and skip its reward
        // payment
        uint256 currentEpoch = block.timestamp / EPOCH_LENGTH;
        genesisEpoch = currentEpoch;
        epochIndexOfLastReward = currentEpoch;
    }

    
    
    /// all app addresses as a means of an upgrade
    
    
    
    
    function setDaoApps(
        address _agentAppPrimary,
        address _agentAppSecondary,
        address _votingAppPrimary,
        address _votingAppSecondary
        )
        external
        override
    {
        // solhint-disable-next-line reason-string
        require(
            msg.sender == agentAppPrimary
                || (agentAppPrimary == address(0) && msg.sender == deployer),
            "Pool: Caller not primary agent or deployer initializing values"
            );
        require(
            _agentAppPrimary != address(0)
                && _agentAppSecondary != address(0)
                && _votingAppPrimary != address(0)
                && _votingAppSecondary != address(0),
            "Pool: Invalid DAO apps"
            );
        agentAppPrimary = _agentAppPrimary;
        agentAppSecondary = _agentAppSecondary;
        votingAppPrimary = _votingAppPrimary;
        votingAppSecondary = _votingAppSecondary;
        emit SetDaoApps(
            agentAppPrimary,
            agentAppSecondary,
            votingAppPrimary,
            votingAppSecondary
            );
    }

    
    /// of a claims manager contract
    
    /// withdraw as many tokens as it wants from the pool to pay out insurance
    /// claims.
    /// Only the primary Agent can do this because it is a critical operation.
    /// WARNING: A compromised contract being given claims manager status may
    /// result in loss of staked funds. If a proposal has been made to call
    /// this method to set a contract as a claims manager, you are recommended
    /// to review the contract yourself and/or refer to the audit reports to
    /// understand the implications.
    
    
    function setClaimsManagerStatus(
        address claimsManager,
        bool status
        )
        external
        override
        onlyAgentAppPrimary()
    {
        claimsManagerStatus[claimsManager] = status;
        emit SetClaimsManagerStatus(
            claimsManager,
            status
            );
    }

    
    
    function setStakeTarget(uint256 _stakeTarget)
        external
        override
        onlyAgentApp()
    {
        require(
            _stakeTarget <= HUNDRED_PERCENT,
            "Pool: Invalid percentage value"
            );
        stakeTarget = _stakeTarget;
        emit SetStakeTarget(_stakeTarget);
    }

    
    
    function setMaxApr(uint256 _maxApr)
        external
        override
        onlyAgentApp()
    {
        require(
            _maxApr >= minApr,
            "Pool: Max APR smaller than min"
            );
        maxApr = _maxApr;
        emit SetMaxApr(_maxApr);
    }

    
    
    function setMinApr(uint256 _minApr)
        external
        override
        onlyAgentApp()
    {
        require(
            _minApr <= maxApr,
            "Pool: Min APR larger than max"
            );
        minApr = _minApr;
        emit SetMinApr(_minApr);
    }

    
    /// period
    
    /// claims to be resolved.
    /// Even when the insurance functionality is not implemented, the minimum
    /// valid value is `EPOCH_LENGTH` to prevent users from unstaking,
    /// withdrawing and staking with another address to work around the
    /// proposal spam protection.
    /// Only the primary Agent can do this because it is a critical operation.
    
    function setUnstakeWaitPeriod(uint256 _unstakeWaitPeriod)
        external
        override
        onlyAgentAppPrimary()
    {
        require(
            _unstakeWaitPeriod >= EPOCH_LENGTH,
            "Pool: Period shorter than epoch"
            );
        unstakeWaitPeriod = _unstakeWaitPeriod;
        emit SetUnstakeWaitPeriod(_unstakeWaitPeriod);
    }

    
    
    /// Only the primary Agent can do this because it is a critical operation.
    
    function setAprUpdateStep(uint256 _aprUpdateStep)
        external
        override
        onlyAgentAppPrimary()
    {
        aprUpdateStep = _aprUpdateStep;
        emit SetAprUpdateStep(_aprUpdateStep);
    }

    
    /// threshold for proposals
    
    /// operation.
    
    /// proposals
    function setProposalVotingPowerThreshold(uint256 _proposalVotingPowerThreshold)
        external
        override
        onlyAgentAppPrimary()
    {
        require(
            _proposalVotingPowerThreshold >= ONE_PERCENT / 10
                && _proposalVotingPowerThreshold <= ONE_PERCENT * 10,
            "Pool: Threshold outside limits");
        proposalVotingPowerThreshold = _proposalVotingPowerThreshold;
        emit SetProposalVotingPowerThreshold(_proposalVotingPowerThreshold);
    }

    
    /// update the timestamp of the user's last proposal
    
    function updateLastProposalTimestamp(address userAddress)
        external
        override
        onlyVotingApp()
    {
        users[userAddress].lastProposalTimestamp = block.timestamp;
        emit UpdatedLastProposalTimestamp(
            userAddress,
            block.timestamp,
            msg.sender
            );
    }

    
    
    /// genesis epoch
    
    function isGenesisEpoch()
        external
        view
        override
        returns (bool)
    {
        return block.timestamp / EPOCH_LENGTH == genesisEpoch;
    }

    
    /// checkpoint
    
    /// will always fit in a uint224. `value` will either be a raw token amount
    /// or a raw pool share amount so this assumption will be correct in
    /// practice with a token with 18 decimals, 1e8 initial total supply and no
    /// hyperinflation.
    
    
    function updateCheckpointArray(
        Checkpoint[] storage checkpointArray,
        uint256 value
        )
        internal
    {
        assert(block.number <= MAX_UINT32);
        assert(value <= MAX_UINT224);
        checkpointArray.push(Checkpoint({
            fromBlock: uint32(block.number),
            value: uint224(value)
            }));
    }

    
    /// pushing a new checkpoint
    
    
    
    function updateAddressCheckpointArray(
        AddressCheckpoint[] storage addressCheckpointArray,
        address _address
        )
        internal
    {
        assert(block.number <= MAX_UINT32);
        addressCheckpointArray.push(AddressCheckpoint({
            fromBlock: uint32(block.number),
            _address: _address
            }));
    }
}


// File contracts/interfaces/IGetterUtils.sol

pragma solidity 0.8.4;

interface IGetterUtils is IStateUtils {
    function userVotingPowerAt(
        address userAddress,
        uint256 _block
        )
        external
        view
        returns (uint256);

    function userVotingPower(address userAddress)
        external
        view
        returns (uint256);

    function totalSharesAt(uint256 _block)
        external
        view
        returns (uint256);

    function totalShares()
        external
        view
        returns (uint256);

    function userSharesAt(
        address userAddress,
        uint256 _block
        )
        external
        view
        returns (uint256);

    function userShares(address userAddress)
        external
        view
        returns (uint256);

    function userStake(address userAddress)
        external
        view
        returns (uint256);

    function delegatedToUserAt(
        address userAddress,
        uint256 _block
        )
        external
        view
        returns (uint256);

    function delegatedToUser(address userAddress)
        external
        view
        returns (uint256);

    function userDelegateAt(
        address userAddress,
        uint256 _block
        )
        external
        view
        returns (address);

    function userDelegate(address userAddress)
        external
        view
        returns (address);

    function userLocked(address userAddress)
        external
        view
        returns (uint256);

    function getUser(address userAddress)
        external
        view
        returns (
            uint256 unstaked,
            uint256 vesting,
            uint256 unstakeShares,
            uint256 unstakeAmount,
            uint256 unstakeScheduledFor,
            uint256 lastDelegationUpdateTimestamp,
            uint256 lastProposalTimestamp
            );
}


// File contracts/GetterUtils.sol

pragma solidity 0.8.4;



abstract contract GetterUtils is StateUtils, IGetterUtils {
    
    
    
    
    function userVotingPowerAt(
        address userAddress,
        uint256 _block
        )
        public
        view
        override
        returns (uint256)
    {
        // Users that have a delegate have no voting power
        if (userDelegateAt(userAddress, _block) != address(0))
        {
            return 0;
        }
        return userSharesAt(userAddress, _block)
            + delegatedToUserAt(userAddress, _block);
    }

    
    
    
    function userVotingPower(address userAddress)
        external
        view
        override
        returns (uint256)
    {
        return userVotingPowerAt(userAddress, block.number);
    }

    
    
    
    
    function totalSharesAt(uint256 _block)
        public
        view
        override
        returns (uint256)
    {
        return getValueAt(poolShares, _block);
    }

    
    
    
    function totalShares()
        public
        view
        override
        returns (uint256)
    {
        return totalSharesAt(block.number);
    }

    
    
    
    
    function userSharesAt(
        address userAddress,
        uint256 _block
        )
        public
        view
        override
        returns (uint256)
    {
        return getValueAt(users[userAddress].shares, _block);
    }

    
    
    
    function userShares(address userAddress)
        public
        view
        override
        returns (uint256)
    {
        return userSharesAt(userAddress, block.number);
    }

    
    
    
    function userStake(address userAddress)
        public
        view
        override
        returns (uint256)
    {
        return userShares(userAddress) * totalStake / totalShares();
    }

    
    /// specific block
    
    
    
    function delegatedToUserAt(
        address userAddress,
        uint256 _block
        )
        public
        view
        override
        returns (uint256)
    {
        return getValueAt(users[userAddress].delegatedTo, _block);
    }

    
    
    
    function delegatedToUser(address userAddress)
        public
        view
        override
        returns (uint256)
    {
        return delegatedToUserAt(userAddress, block.number);
    }

    
    
    
    
    function userDelegateAt(
        address userAddress,
        uint256 _block
        )
        public
        view
        override
        returns (address)
    {
        return getAddressAt(users[userAddress].delegates, _block);
    }

    
    
    
    function userDelegate(address userAddress)
        public
        view
        override
        returns (address)
    {
        return userDelegateAt(userAddress, block.number);
    }

    
    
    
    function userLocked(address userAddress)
        public
        view
        override
        returns (uint256 locked)
    {
        Checkpoint[] storage _userShares = users[userAddress].shares;
        uint256 currentEpoch = block.timestamp / EPOCH_LENGTH;
        uint256 oldestLockedEpoch = getOldestLockedEpoch();
        uint256 indUserShares = _userShares.length;
        for (
                uint256 indEpoch = currentEpoch;
                indEpoch >= oldestLockedEpoch;
                indEpoch--
            )
        {
            // The user has never staked at this point, we can exit early
            if (indUserShares == 0)
            {
                break;
            }
            Reward storage lockedReward = epochIndexToReward[indEpoch];
            if (lockedReward.atBlock != 0)
            {
                for (; indUserShares > 0; indUserShares--)
                {
                    Checkpoint storage userShare = _userShares[indUserShares - 1];
                    if (userShare.fromBlock <= lockedReward.atBlock)
                    {
                        locked += lockedReward.amount * userShare.value / lockedReward.totalSharesThen;
                        break;
                    }
                }
            }
        }
    }

    
    
    
    
    
    
    
    
    
    /// recent proposal
    function getUser(address userAddress)
        external
        view
        override
        returns (
            uint256 unstaked,
            uint256 vesting,
            uint256 unstakeAmount,
            uint256 unstakeShares,
            uint256 unstakeScheduledFor,
            uint256 lastDelegationUpdateTimestamp,
            uint256 lastProposalTimestamp
            )
    {
        User storage user = users[userAddress];
        unstaked = user.unstaked;
        vesting = user.vesting;
        unstakeAmount = user.unstakeAmount;
        unstakeShares = user.unstakeShares;
        unstakeScheduledFor = user.unstakeScheduledFor;
        lastDelegationUpdateTimestamp = user.lastDelegationUpdateTimestamp;
        lastProposalTimestamp = user.lastProposalTimestamp;
    }

    
    /// block using binary search
    
    /// https://github.com/aragon/minime/blob/1d5251fc88eee5024ff318d95bc9f4c5de130430/contracts/MiniMeToken.sol#L431
    
    
    
    function getValueAt(
        Checkpoint[] storage checkpoints,
        uint256 _block
        )
        internal
        view
        returns (uint256)
    {
        if (checkpoints.length == 0)
            return 0;

        // Shortcut for the actual value
        if (_block >= checkpoints[checkpoints.length -1].fromBlock)
            return checkpoints[checkpoints.length - 1].value;
        if (_block < checkpoints[0].fromBlock)
            return 0;

        // Limit the search to the last 1024 elements if the value being
        // searched falls within that window
        uint min = 0;
        if (
            checkpoints.length > 1024
                && checkpoints[checkpoints.length - 1024].fromBlock < _block
            )
        {
            min = checkpoints.length - 1024;
        }

        // Binary search of the value in the array
        uint max = checkpoints.length - 1;
        while (max > min) {
            uint mid = (max + min + 1) / 2;
            if (checkpoints[mid].fromBlock <= _block) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }
        return checkpoints[min].value;
    }

    
    /// specific block using binary search
    
    /// https://github.com/aragon/minime/blob/1d5251fc88eee5024ff318d95bc9f4c5de130430/contracts/MiniMeToken.sol#L431
    
    
    
    function getAddressAt(
        AddressCheckpoint[] storage checkpoints,
        uint256 _block
        )
        private
        view
        returns (address)
    {
        if (checkpoints.length == 0)
            return address(0);

        // Shortcut for the actual value
        if (_block >= checkpoints[checkpoints.length -1].fromBlock)
            return checkpoints[checkpoints.length - 1]._address;
        if (_block < checkpoints[0].fromBlock)
            return address(0);

        // Limit the search to the last 1024 elements if the value being
        // searched falls within that window
        uint min = 0;
        if (
            checkpoints.length > 1024
                && checkpoints[checkpoints.length - 1024].fromBlock < _block
            )
        {
            min = checkpoints.length - 1024;
        }

        // Binary search of the value in the array
        uint max = checkpoints.length - 1;
        while (max > min) {
            uint mid = (max + min + 1) / 2;
            if (checkpoints[mid].fromBlock <= _block) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }
        return checkpoints[min]._address;
    }

    
    /// reward should be locked in the current epoch
    
    function getOldestLockedEpoch()
        internal
        view
        returns (uint256 oldestLockedEpoch)
    {
        uint256 currentEpoch = block.timestamp / EPOCH_LENGTH;
        oldestLockedEpoch = currentEpoch - REWARD_VESTING_PERIOD + 1;
        if (oldestLockedEpoch < genesisEpoch + 1)
        {
            oldestLockedEpoch = genesisEpoch + 1;
        }
    }
}


// File contracts/interfaces/IRewardUtils.sol

pragma solidity 0.8.4;

interface IRewardUtils is IGetterUtils {
    event MintedReward(
        uint256 indexed epochIndex,
        uint256 amount,
        uint256 newApr,
        uint256 totalStake
        );

    function mintReward()
        external;
}


// File contracts/RewardUtils.sol

pragma solidity 0.8.4;



abstract contract RewardUtils is GetterUtils, IRewardUtils {
    
    
    /// Skips the reward payment if the pool is not authorized to mint tokens.
    /// Neither of these conditions will occur in practice.
    function mintReward()
        public
        override
    {
        uint256 currentEpoch = block.timestamp / EPOCH_LENGTH;
        // This will be skipped in most cases because someone else will have
        // triggered the payment for this epoch
        if (epochIndexOfLastReward < currentEpoch)
        {
            if (api3Token.getMinterStatus(address(this)))
            {
                uint256 rewardAmount = totalStake * apr * EPOCH_LENGTH / 365 days / HUNDRED_PERCENT;
                assert(block.number <= MAX_UINT32);
                assert(rewardAmount <= MAX_UINT224);
                epochIndexToReward[currentEpoch] = Reward({
                    atBlock: uint32(block.number),
                    amount: uint224(rewardAmount),
                    totalSharesThen: totalShares(),
                    totalStakeThen: totalStake
                    });
                api3Token.mint(address(this), rewardAmount);
                totalStake += rewardAmount;
                updateCurrentApr();
                emit MintedReward(
                    currentEpoch,
                    rewardAmount,
                    apr,
                    totalStake
                    );
            }
            epochIndexOfLastReward = currentEpoch;
        }
    }

    
    
    function updateCurrentApr()
        internal
    {
        uint256 totalStakePercentage = totalStake
            * HUNDRED_PERCENT
            / api3Token.totalSupply();
        if (totalStakePercentage > stakeTarget)
        {
            apr = apr > aprUpdateStep ? apr - aprUpdateStep : 0;
        }
        else
        {
            apr += aprUpdateStep;
        }
        if (apr > maxApr) {
            apr = maxApr;
        }
        else if (apr < minApr) {
            apr = minApr;
        }
    }
}


// File contracts/interfaces/IDelegationUtils.sol

pragma solidity 0.8.4;

interface IDelegationUtils is IRewardUtils {
    event Delegated(
        address indexed user,
        address indexed delegate,
        uint256 shares,
        uint256 totalDelegatedTo
        );

    event Undelegated(
        address indexed user,
        address indexed delegate,
        uint256 shares,
        uint256 totalDelegatedTo
        );

    event UpdatedDelegation(
        address indexed user,
        address indexed delegate,
        bool delta,
        uint256 shares,
        uint256 totalDelegatedTo
        );

    function delegateVotingPower(address delegate) 
        external;

    function undelegateVotingPower()
        external;

    
}


// File contracts/DelegationUtils.sol

pragma solidity 0.8.4;



abstract contract DelegationUtils is RewardUtils, IDelegationUtils {
    
    
    function delegateVotingPower(address delegate) 
        external
        override
    {
        mintReward();
        require(
            delegate != address(0) && delegate != msg.sender,
            "Pool: Invalid delegate"
            );
        // Delegating users cannot use their voting power, so we are
        // verifying that the delegate is not currently delegating. However,
        // the delegate may delegate after they have been delegated to.
        require(
            userDelegate(delegate) == address(0),
            "Pool: Delegate is delegating"
            );
        User storage user = users[msg.sender];
        // Do not allow frequent delegation updates as that can be used to spam
        // proposals
        require(
            user.lastDelegationUpdateTimestamp + EPOCH_LENGTH < block.timestamp,
            "Pool: Updated delegate recently"
            );
        user.lastDelegationUpdateTimestamp = block.timestamp;

        uint256 userShares = userShares(msg.sender);
        require(
            userShares != 0,
            "Pool: Have no shares to delegate"
            );

        address previousDelegate = userDelegate(msg.sender);
        require(
            previousDelegate != delegate,
            "Pool: Already delegated"
            );
        if (previousDelegate != address(0)) {
            // Need to revoke previous delegation
            updateCheckpointArray(
                users[previousDelegate].delegatedTo,
                delegatedToUser(previousDelegate) - userShares
                );
        }

        // Assign the new delegation
        uint256 delegatedToUpdate = delegatedToUser(delegate) + userShares;
        updateCheckpointArray(
            users[delegate].delegatedTo,
            delegatedToUpdate
            );

        // Record the new delegate for the user
        updateAddressCheckpointArray(
            user.delegates,
            delegate
            );
        emit Delegated(
            msg.sender,
            delegate,
            userShares,
            delegatedToUpdate
            );
    }

    
    function undelegateVotingPower()
        external
        override
    {
        mintReward();
        User storage user = users[msg.sender];
        address previousDelegate = userDelegate(msg.sender);
        require(
            previousDelegate != address(0),
            "Pool: Not delegated"
            );
        require(
            user.lastDelegationUpdateTimestamp + EPOCH_LENGTH < block.timestamp,
            "Pool: Updated delegate recently"
            );
        user.lastDelegationUpdateTimestamp = block.timestamp;

        uint256 userShares = userShares(msg.sender);
        uint256 delegatedToUpdate = delegatedToUser(previousDelegate) - userShares;
        updateCheckpointArray(
            users[previousDelegate].delegatedTo,
            delegatedToUpdate
            );
        updateAddressCheckpointArray(
            user.delegates,
            address(0)
            );
        emit Undelegated(
            msg.sender,
            previousDelegate,
            userShares,
            delegatedToUpdate
            );
    }

    
    /// the delegated voting power
    
    
    
    /// and vice versa)
    function updateDelegatedVotingPower(
        uint256 shares,
        bool delta
        )
        internal
    {
        address delegate = userDelegate(msg.sender);
        if (delegate == address(0))
        {
            return;
        }
        uint256 currentDelegatedTo = delegatedToUser(delegate);
        uint256 delegatedToUpdate = delta
            ? currentDelegatedTo + shares
            : currentDelegatedTo - shares;
        updateCheckpointArray(
            users[delegate].delegatedTo,
            delegatedToUpdate
            );
        emit UpdatedDelegation(
            msg.sender,
            delegate,
            delta,
            shares,
            delegatedToUpdate
            );
    }
}


// File contracts/interfaces/ITransferUtils.sol

pragma solidity 0.8.4;

interface ITransferUtils is IDelegationUtils{
    event Deposited(
        address indexed user,
        uint256 amount,
        uint256 userUnstaked
        );

    event Withdrawn(
        address indexed user,
        uint256 amount,
        uint256 userUnstaked
        );

    event CalculatingUserLocked(
        address indexed user,
        uint256 nextIndEpoch,
        uint256 oldestLockedEpoch
        );

    event CalculatedUserLocked(
        address indexed user,
        uint256 amount
        );

    function depositRegular(uint256 amount)
        external;

    function withdrawRegular(uint256 amount)
        external;

    function precalculateUserLocked(
        address userAddress,
        uint256 noEpochsPerIteration
        )
        external
        returns (bool finished);

    function withdrawPrecalculated(uint256 amount)
        external;
}


// File contracts/TransferUtils.sol

pragma solidity 0.8.4;



abstract contract TransferUtils is DelegationUtils, ITransferUtils {
    
    
    /// before calling this.
    /// The method is named `depositRegular()` to prevent potential confusion.
    /// See `deposit()` for more context.
    
    function depositRegular(uint256 amount)
        public
        override
    {
        mintReward();
        uint256 unstakedUpdate = users[msg.sender].unstaked + amount;
        users[msg.sender].unstaked = unstakedUpdate;
        // Should never return false because the API3 token uses the
        // OpenZeppelin implementation
        assert(api3Token.transferFrom(msg.sender, address(this), amount));
        emit Deposited(
            msg.sender,
            amount,
            unstakedUpdate
            );
    }

    
    
    /// they have at least `amount` unlocked tokens to withdraw.
    /// The method is named `withdrawRegular()` to be consistent with the name
    /// `depositRegular()`. See `depositRegular()` for more context.
    
    function withdrawRegular(uint256 amount)
        public
        override
    {
        mintReward();
        withdraw(amount, userLocked(msg.sender));
    }

    
    /// multiple transactions
    
    /// frequently (50+/week) in the last `REWARD_VESTING_PERIOD`, the
    /// `userLocked()` call gas cost may exceed the block gas limit. In that
    /// case, the user may call this method multiple times to have their locked
    /// tokens calculated and use `withdrawPrecalculated()` to withdraw.
    
    
    
    function precalculateUserLocked(
        address userAddress,
        uint256 noEpochsPerIteration
        )
        external
        override
        returns (bool finished)
    {
        mintReward();
        require(
            noEpochsPerIteration > 0,
            "Pool: Zero iteration window"
            );
        uint256 currentEpoch = block.timestamp / EPOCH_LENGTH;
        LockedCalculation storage lockedCalculation = userToLockedCalculation[userAddress];
        // Reset the state if there was no calculation made in this epoch
        if (lockedCalculation.initialIndEpoch != currentEpoch)
        {
            lockedCalculation.initialIndEpoch = currentEpoch;
            lockedCalculation.nextIndEpoch = currentEpoch;
            lockedCalculation.locked = 0;
        }
        uint256 indEpoch = lockedCalculation.nextIndEpoch;
        uint256 locked = lockedCalculation.locked;
        uint256 oldestLockedEpoch = getOldestLockedEpoch();
        for (; indEpoch >= oldestLockedEpoch; indEpoch--)
        {
            if (lockedCalculation.nextIndEpoch >= indEpoch + noEpochsPerIteration)
            {
                lockedCalculation.nextIndEpoch = indEpoch;
                lockedCalculation.locked = locked;
                emit CalculatingUserLocked(
                    userAddress,
                    indEpoch,
                    oldestLockedEpoch
                    );
                return false;
            }
            Reward storage lockedReward = epochIndexToReward[indEpoch];
            if (lockedReward.atBlock != 0)
            {
                uint256 userSharesThen = userSharesAt(userAddress, lockedReward.atBlock);
                locked += lockedReward.amount * userSharesThen / lockedReward.totalSharesThen;
            }
        }
        lockedCalculation.nextIndEpoch = indEpoch;
        lockedCalculation.locked = locked;
        emit CalculatedUserLocked(userAddress, locked);
        return true;
    }

    
    /// is calculated with repeated calls to `precalculateUserLocked()`
    
    /// `withdrawRegular()` hits the block gas limit
    
    function withdrawPrecalculated(uint256 amount)
        external
        override
    {
        mintReward();
        uint256 currentEpoch = block.timestamp / EPOCH_LENGTH;
        LockedCalculation storage lockedCalculation = userToLockedCalculation[msg.sender];
        require(
            lockedCalculation.initialIndEpoch == currentEpoch,
            "Pool: Calculation not up to date"
            );
        require(
            lockedCalculation.nextIndEpoch < getOldestLockedEpoch(),
            "Pool: Calculation not complete"
            );
        withdraw(amount, lockedCalculation.locked);
    }

    
    /// is determined
    
    
    function withdraw(
        uint256 amount,
        uint256 userLocked
        )
        private
    {
        User storage user = users[msg.sender];
        // Check if the user has `amount` unlocked tokens to withdraw
        uint256 lockedAndVesting = userLocked + user.vesting;
        uint256 userTotalFunds = user.unstaked + userStake(msg.sender);
        require(
            userTotalFunds >= lockedAndVesting + amount,
            "Pool: Not enough unlocked funds"
            );
        require(
            user.unstaked >= amount,
            "Pool: Not enough unstaked funds"
            );
        // Carry on with the withdrawal
        uint256 unstakedUpdate = user.unstaked - amount;
        user.unstaked = unstakedUpdate;
        // Should never return false because the API3 token uses the
        // OpenZeppelin implementation
        assert(api3Token.transfer(msg.sender, amount));
        emit Withdrawn(
            msg.sender,
            amount,
            unstakedUpdate
            );
    }
}


// File contracts/interfaces/IStakeUtils.sol

pragma solidity 0.8.4;

interface IStakeUtils is ITransferUtils{
    event Staked(
        address indexed user,
        uint256 amount,
        uint256 mintedShares,
        uint256 userUnstaked,
        uint256 userShares,
        uint256 totalShares,
        uint256 totalStake
        );

    event ScheduledUnstake(
        address indexed user,
        uint256 amount,
        uint256 shares,
        uint256 scheduledFor,
        uint256 userShares
        );

    event Unstaked(
        address indexed user,
        uint256 amount,
        uint256 userUnstaked,
        uint256 totalShares,
        uint256 totalStake
        );

    function stake(uint256 amount)
        external;

    function depositAndStake(uint256 amount)
        external;

    function scheduleUnstake(uint256 amount)
        external;

    function unstake(address userAddress)
        external
        returns (uint256);

    function unstakeAndWithdraw()
        external;
}


// File contracts/StakeUtils.sol

pragma solidity 0.8.4;



abstract contract StakeUtils is TransferUtils, IStakeUtils {
    
    
    function stake(uint256 amount)
        public
        override
    {
        mintReward();
        User storage user = users[msg.sender];
        require(
            user.unstaked >= amount,
            "Pool: Amount exceeds unstaked"
            );
        uint256 userUnstakedUpdate = user.unstaked - amount;
        user.unstaked = userUnstakedUpdate;
        uint256 totalSharesNow = totalShares();
        uint256 sharesToMint = amount * totalSharesNow / totalStake;
        uint256 userSharesUpdate = userShares(msg.sender) + sharesToMint;
        updateCheckpointArray(
            user.shares,
            userSharesUpdate
            );
        uint256 totalSharesUpdate = totalSharesNow + sharesToMint;
        updateCheckpointArray(
            poolShares,
            totalSharesUpdate
            );
        totalStake += amount;
        updateDelegatedVotingPower(sharesToMint, true);
        emit Staked(
            msg.sender,
            amount,
            sharesToMint,
            userUnstakedUpdate,
            userSharesUpdate,
            totalSharesUpdate,
            totalStake
            );
    }

    
    
    function depositAndStake(uint256 amount)
        external
        override
    {
        depositRegular(amount);
        stake(amount);
    }

    
    
    /// meaning that they will not receive rewards or voting power for them any
    /// longer.
    /// At unstaking-time, the user unstakes either the amount of tokens
    /// scheduled to unstake, or the amount of tokens `shares` corresponds to
    /// at unstaking-time, whichever is smaller. This corresponds to tokens
    /// being scheduled to be unstaked not receiving any rewards, but being
    /// subject to claim payouts.
    /// In the instance that a claim has been paid out before an unstaking is
    /// executed, the user may potentially receive rewards during
    /// `unstakeWaitPeriod` (but not if there has not been a claim payout) but
    /// the amount of tokens that they can unstake will not be able to exceed
    /// the amount they scheduled the unstaking for.
    
    function scheduleUnstake(uint256 amount)
        external
        override
    {
        mintReward();
        uint256 userSharesNow = userShares(msg.sender);
        uint256 totalSharesNow = totalShares();
        uint256 userStaked = userSharesNow * totalStake / totalSharesNow;
        require(
            userStaked >= amount,
            "Pool: Amount exceeds staked"
            );

        User storage user = users[msg.sender];
        require(
            user.unstakeScheduledFor == 0,
            "Pool: Unexecuted unstake exists"
            );

        uint256 sharesToUnstake = amount * totalSharesNow / totalStake;
        // This will only happen if the user wants to schedule an unstake for a
        // few Wei
        require(sharesToUnstake > 0, "Pool: Unstake amount too small");
        uint256 unstakeScheduledFor = block.timestamp + unstakeWaitPeriod;
        user.unstakeScheduledFor = unstakeScheduledFor;
        user.unstakeAmount = amount;
        user.unstakeShares = sharesToUnstake;
        uint256 userSharesUpdate = userSharesNow - sharesToUnstake;
        updateCheckpointArray(
            user.shares,
            userSharesUpdate
            );
        updateDelegatedVotingPower(sharesToUnstake, false);
        emit ScheduledUnstake(
            msg.sender,
            amount,
            sharesToUnstake,
            unstakeScheduledFor,
            userSharesUpdate
            );
    }

    
    
    /// use bots, etc. to execute their unstaking as soon as possible.
    
    
    function unstake(address userAddress)
        public
        override
        returns (uint256)
    {
        mintReward();
        User storage user = users[userAddress];
        require(
            user.unstakeScheduledFor != 0,
            "Pool: No unstake scheduled"
            );
        require(
            user.unstakeScheduledFor < block.timestamp,
            "Pool: Unstake not mature yet"
            );
        uint256 totalShares = totalShares();
        uint256 unstakeAmount = user.unstakeAmount;
        uint256 unstakeAmountByShares = user.unstakeShares * totalStake / totalShares;
        // If there was a claim payout in between the scheduling and the actual
        // unstake then the amount might be lower than expected at scheduling
        // time
        if (unstakeAmount > unstakeAmountByShares)
        {
            unstakeAmount = unstakeAmountByShares;
        }
        uint256 userUnstakedUpdate = user.unstaked + unstakeAmount;
        user.unstaked = userUnstakedUpdate;

        uint256 totalSharesUpdate = totalShares - user.unstakeShares;
        updateCheckpointArray(
            poolShares,
            totalSharesUpdate
            );
        totalStake -= unstakeAmount;

        user.unstakeAmount = 0;
        user.unstakeShares = 0;
        user.unstakeScheduledFor = 0;
        emit Unstaked(
            userAddress,
            unstakeAmount,
            userUnstakedUpdate,
            totalSharesUpdate,
            totalStake
            );
        return unstakeAmount;
    }

    
    /// user's wallet in a single transaction
    
    /// `unstakeAmount` tokens that are withdrawable
    function unstakeAndWithdraw()
        external
        override
    {
        withdrawRegular(unstake(msg.sender));
    }
}


// File contracts/interfaces/IClaimUtils.sol

pragma solidity 0.8.4;

interface IClaimUtils is IStakeUtils {
    event PaidOutClaim(
        address indexed recipient,
        uint256 amount,
        uint256 totalStake
        );

    function payOutClaim(
        address recipient,
        uint256 amount
        )
        external;
}


// File contracts/ClaimUtils.sol

pragma solidity 0.8.4;



abstract contract ClaimUtils is StakeUtils, IClaimUtils {
    
    modifier onlyClaimsManager() {
        require(
            claimsManagerStatus[msg.sender],
            "Pool: Caller not claims manager"
            );
        _;
    }

    
    
    /// withdraw as many tokens as it wants from the pool to pay out insurance
    /// claims. Any kind of limiting logic (e.g., maximum amount of tokens that
    /// can be withdrawn) is implemented at its end and is out of the scope of
    /// this contract.
    /// This will revert if the pool does not have enough staked funds.
    
    
    function payOutClaim(
        address recipient,
        uint256 amount
        )
        external
        override
        onlyClaimsManager()
    {
        mintReward();
        // totalStake should not go lower than 1
        require(
            totalStake > amount,
            "Pool: Amount exceeds total stake"
            );
        totalStake -= amount;
        // Should never return false because the API3 token uses the
        // OpenZeppelin implementation
        assert(api3Token.transfer(recipient, amount));
        emit PaidOutClaim(
            recipient,
            amount,
            totalStake
            );
    }
}


// File contracts/interfaces/ITimelockUtils.sol

pragma solidity 0.8.4;

interface ITimelockUtils is IClaimUtils {
    event DepositedByTimelockManager(
        address indexed user,
        uint256 amount,
        uint256 userUnstaked
        );

    event DepositedVesting(
        address indexed user,
        uint256 amount,
        uint256 start,
        uint256 end,
        uint256 userUnstaked,
        uint256 userVesting
        );

    event VestedTimelock(
        address indexed user,
        uint256 amount,
        uint256 userVesting
        );

    function deposit(
        address source,
        uint256 amount,
        address userAddress
        )
        external;

    function depositWithVesting(
        address source,
        uint256 amount,
        address userAddress,
        uint256 releaseStart,
        uint256 releaseEnd
        )
        external;

    function updateTimelockStatus(address userAddress)
        external;
}


// File contracts/TimelockUtils.sol

pragma solidity 0.8.4;




/// API3 tokens that are locked under a vesting schedule.
/// This contract keeps its own type definitions, event declarations and state
/// variables for them to be easier to remove for a subDAO where they will
/// likely not be used.
abstract contract TimelockUtils is ClaimUtils, ITimelockUtils {
    struct Timelock {
        uint256 totalAmount;
        uint256 remainingAmount;
        uint256 releaseStart;
        uint256 releaseEnd;
    }

    
    
    /// transferred from the TimelockManager contract. This is acceptable
    /// because TimelockManager is implemented in a way to not allow multiple
    /// timelocks per user.
    mapping(address => Timelock) public userToTimelock;

    
    /// behalf of a user
    
    /// It is named as `deposit()` and not `depositAsTimelockManager()` for
    /// example, because the TimelockManager is already deployed and expects
    /// the `deposit(address,uint256,address)` interface.
    
    
    
    function deposit(
        address source,
        uint256 amount,
        address userAddress
        )
        external
        override
    {
        require(
            msg.sender == timelockManager,
            "Pool: Caller not TimelockManager"
            );
        uint256 unstakedUpdate = users[userAddress].unstaked + amount;
        users[userAddress].unstaked = unstakedUpdate;
        // Should never return false because the API3 token uses the
        // OpenZeppelin implementation
        assert(api3Token.transferFrom(source, address(this), amount));
        emit DepositedByTimelockManager(
            userAddress,
            amount,
            unstakedUpdate
            );
    }

    
    /// behalf of a user on a linear vesting schedule
    
    
    
    
    
    
    function depositWithVesting(
        address source,
        uint256 amount,
        address userAddress,
        uint256 releaseStart,
        uint256 releaseEnd
        )
        external
        override
    {
        require(
            msg.sender == timelockManager,
            "Pool: Caller not TimelockManager"
            );
        require(
            userToTimelock[userAddress].remainingAmount == 0,
            "Pool: User has active timelock"
            );
        require(
            releaseEnd > releaseStart,
            "Pool: Timelock start after end"
            );
        require(
            amount != 0,
            "Pool: Timelock amount zero"
            );
        uint256 unstakedUpdate = users[userAddress].unstaked + amount;
        users[userAddress].unstaked = unstakedUpdate;
        uint256 vestingUpdate = users[userAddress].vesting + amount;
        users[userAddress].vesting = vestingUpdate;
        userToTimelock[userAddress] = Timelock({
            totalAmount: amount,
            remainingAmount: amount,
            releaseStart: releaseStart,
            releaseEnd: releaseEnd
            });
        // Should never return false because the API3 token uses the
        // OpenZeppelin implementation
        assert(api3Token.transferFrom(source, address(this), amount));
        emit DepositedVesting(
            userAddress,
            amount,
            releaseStart,
            releaseEnd,
            unstakedUpdate,
            vestingUpdate
            );
    }

    
    
    /// updated
    function updateTimelockStatus(address userAddress)
        external
        override
    {
        Timelock storage timelock = userToTimelock[userAddress];
        require(
            block.timestamp > timelock.releaseStart,
            "Pool: Release not started yet"
            );
        require(
            timelock.remainingAmount > 0,
            "Pool: Timelock already released"
            );
        uint256 totalUnlocked;
        if (block.timestamp >= timelock.releaseEnd)
        {
            totalUnlocked = timelock.totalAmount;
        }
        else
        {
            uint256 passedTime = block.timestamp - timelock.releaseStart;
            uint256 totalTime = timelock.releaseEnd - timelock.releaseStart;
            totalUnlocked = timelock.totalAmount * passedTime / totalTime;
        }
        uint256 previouslyUnlocked = timelock.totalAmount - timelock.remainingAmount;
        uint256 newlyUnlocked = totalUnlocked - previouslyUnlocked;
        User storage user = users[userAddress];
        uint256 vestingUpdate = user.vesting - newlyUnlocked;
        user.vesting = vestingUpdate;
        timelock.remainingAmount -= newlyUnlocked;
        emit VestedTimelock(
            userAddress,
            newlyUnlocked,
            vestingUpdate
            );
    }
}


// File contracts/interfaces/IApi3Pool.sol

pragma solidity 0.8.4;

interface IApi3Pool is ITimelockUtils {
}


// File contracts/Api3Pool.sol

pragma solidity 0.8.4;




/// shares. These shares are exposed to the Aragon-based DAO, giving the user
/// voting power at the DAO. Staking pays out weekly rewards that get unlocked
/// after a year, and staked funds are used to collateralize an insurance
/// product that is outside the scope of this contract.

/// chain of inheritance:
/// (1) Api3Pool.sol
/// (2) TimelockUtils.sol
/// (3) ClaimUtils.sol
/// (4) StakeUtils.sol
/// (5) TransferUtils.sol
/// (6) DelegationUtils.sol
/// (7) RewardUtils.sol
/// (8) GetterUtils.sol
/// (9) StateUtils.sol
contract Api3Pool is TimelockUtils, IApi3Pool {
    
    
    constructor(
        address api3TokenAddress,
        address timelockManagerAddress
        )
        StateUtils(
            api3TokenAddress,
            timelockManagerAddress
            )
    {}
}