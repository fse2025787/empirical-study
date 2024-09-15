pragma experimental ABIEncoderV2;


/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;


contract IOwnable {

    
    
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    
    function transferOwnership(address newOwner)
        public;
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;




contract IAuthorizable is
    IOwnable
{
    // Event logged when a new address is authorized.
    event AuthorizedAddressAdded(
        address indexed target,
        address indexed caller
    );

    // Event logged when a currently authorized address is unauthorized.
    event AuthorizedAddressRemoved(
        address indexed target,
        address indexed caller
    );

    
    
    function addAuthorizedAddress(address target)
        external;

    
    
    function removeAuthorizedAddress(address target)
        external;

    
    
    
    function removeAuthorizedAddressAtIndex(
        address target,
        uint256 index
    )
        external;

    
    
    function getAuthorizedAddresses()
        external
        view
        returns (address[] memory);
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;






contract Ownable is
    IOwnable
{
    
    
    address public owner;

    constructor ()
        public
    {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        _assertSenderIsOwner();
        _;
    }

    
    
    function transferOwnership(address newOwner)
        public
        onlyOwner
    {
        if (newOwner == address(0)) {
            LibRichErrors.rrevert(LibOwnableRichErrors.TransferOwnerToZeroError());
        } else {
            owner = newOwner;
            emit OwnershipTransferred(msg.sender, newOwner);
        }
    }

    function _assertSenderIsOwner()
        internal
        view
    {
        if (msg.sender != owner) {
            LibRichErrors.rrevert(LibOwnableRichErrors.OnlyOwnerError(
                msg.sender,
                owner
            ));
        }
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;







// solhint-disable no-empty-blocks
contract Authorizable is
    Ownable,
    IAuthorizable
{
    
    modifier onlyAuthorized {
        _assertSenderIsAuthorized();
        _;
    }

    
    
    
    mapping (address => bool) public authorized;
    
    
    
    address[] public authorities;

    
    constructor()
        public
        Ownable()
    {}

    
    
    function addAuthorizedAddress(address target)
        external
        onlyOwner
    {
        _addAuthorizedAddress(target);
    }

    
    
    function removeAuthorizedAddress(address target)
        external
        onlyOwner
    {
        if (!authorized[target]) {
            LibRichErrors.rrevert(LibAuthorizableRichErrors.TargetNotAuthorizedError(target));
        }
        for (uint256 i = 0; i < authorities.length; i++) {
            if (authorities[i] == target) {
                _removeAuthorizedAddressAtIndex(target, i);
                break;
            }
        }
    }

    
    
    
    function removeAuthorizedAddressAtIndex(
        address target,
        uint256 index
    )
        external
        onlyOwner
    {
        _removeAuthorizedAddressAtIndex(target, index);
    }

    
    
    function getAuthorizedAddresses()
        external
        view
        returns (address[] memory)
    {
        return authorities;
    }

    
    function _assertSenderIsAuthorized()
        internal
        view
    {
        if (!authorized[msg.sender]) {
            LibRichErrors.rrevert(LibAuthorizableRichErrors.SenderNotAuthorizedError(msg.sender));
        }
    }

    
    
    function _addAuthorizedAddress(address target)
        internal
    {
        // Ensure that the target is not the zero address.
        if (target == address(0)) {
            LibRichErrors.rrevert(LibAuthorizableRichErrors.ZeroCantBeAuthorizedError());
        }

        // Ensure that the target is not already authorized.
        if (authorized[target]) {
            LibRichErrors.rrevert(LibAuthorizableRichErrors.TargetAlreadyAuthorizedError(target));
        }

        authorized[target] = true;
        authorities.push(target);
        emit AuthorizedAddressAdded(target, msg.sender);
    }

    
    
    
    function _removeAuthorizedAddressAtIndex(
        address target,
        uint256 index
    )
        internal
    {
        if (!authorized[target]) {
            LibRichErrors.rrevert(LibAuthorizableRichErrors.TargetNotAuthorizedError(target));
        }
        if (index >= authorities.length) {
            LibRichErrors.rrevert(LibAuthorizableRichErrors.IndexOutOfBoundsError(
                index,
                authorities.length
            ));
        }
        if (authorities[index] != target) {
            LibRichErrors.rrevert(LibAuthorizableRichErrors.AuthorizedAddressMismatchError(
                authorities[index],
                target
            ));
        }

        delete authorized[target];
        authorities[index] = authorities[authorities.length - 1];
        authorities.length -= 1;
        emit AuthorizedAddressRemoved(target, msg.sender);
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;










// solhint-disable max-states-count, no-empty-blocks
contract MixinStorage is
    Authorizable
{
    // address of staking contract
    address public stakingContract;

    // mapping from StakeStatus to global stored balance
    // NOTE: only Status.DELEGATED is used to access this mapping, but this format
    // is used for extensibility
    mapping (uint8 => IStructs.StoredBalance) internal _globalStakeByStatus;

    // mapping from StakeStatus to address of staker to stored balance
    mapping (uint8 => mapping (address => IStructs.StoredBalance)) internal _ownerStakeByStatus;

    // Mapping from Owner to Pool Id to Amount Delegated
    mapping (address => mapping (bytes32 => IStructs.StoredBalance)) internal _delegatedStakeToPoolByOwner;

    // Mapping from Pool Id to Amount Delegated
    mapping (bytes32 => IStructs.StoredBalance) internal _delegatedStakeByPoolId;

    // tracking Pool Id, a unique identifier for each staking pool.
    bytes32 public lastPoolId;

    
    
    
    mapping (address => bytes32) public poolIdByMaker;

    // mapping from Pool Id to Pool
    mapping (bytes32 => IStructs.Pool) internal _poolById;

    
    
    
    mapping (bytes32 => uint256) public rewardsByPoolId;

    // The current epoch.
    uint256 public currentEpoch;

    // The current epoch start time.
    uint256 public currentEpochStartTimeInSeconds;

    // mapping from Pool Id to Epoch to Reward Ratio
    mapping (bytes32 => mapping (uint256 => IStructs.Fraction)) internal _cumulativeRewardsByPool;

    // mapping from Pool Id to Epoch
    mapping (bytes32 => uint256) internal _cumulativeRewardsByPoolLastStored;

    
    
    
    mapping (address => bool) public validExchanges;

    /* Tweakable parameters */

    // Minimum seconds between epochs.
    uint256 public epochDurationInSeconds;

    // How much delegated stake is weighted vs operator stake, in ppm.
    uint32 public rewardDelegatedStakeWeight;

    // Minimum amount of stake required in a pool to collect rewards.
    uint256 public minimumPoolStake;

    // Numerator for cobb douglas alpha factor.
    uint32 public cobbDouglasAlphaNumerator;

    // Denominator for cobb douglas alpha factor.
    uint32 public cobbDouglasAlphaDenominator;

    /* State for finalization */

    
    ///      See `_minimumPoolStake` in `MixinParams`.
    
    
    
    mapping (bytes32 => mapping (uint256 => IStructs.PoolStats)) public poolStatsByEpoch;

    
    ///      See `_minimumPoolStake` in MixinParams.
    
    
    mapping (uint256 => IStructs.AggregatedStats) public aggregatedStatsByEpoch;

    
    uint256 public wethReservedForPoolRewards;
}

pragma solidity ^0.5.9;


interface IStakingEvents {

    
    
    
    event Stake(
        address indexed staker,
        uint256 amount
    );

    
    
    
    event Unstake(
        address indexed staker,
        uint256 amount
    );

    
    
    
    event MoveStake(
        address indexed staker,
        uint256 amount,
        uint8 fromStatus,
        bytes32 indexed fromPool,
        uint8 toStatus,
        bytes32 indexed toPool
    );

    
    
    event ExchangeAdded(
        address exchangeAddress
    );

    
    
    event ExchangeRemoved(
        address exchangeAddress
    );

    
    
    
    event StakingPoolEarnedRewardsInEpoch(
        uint256 indexed epoch,
        bytes32 indexed poolId
    );

    
    
    
    
    
    
    event EpochEnded(
        uint256 indexed epoch,
        uint256 numPoolsToFinalize,
        uint256 rewardsAvailable,
        uint256 totalFeesCollected,
        uint256 totalWeightedStake
    );

    
    
    
    
    event EpochFinalized(
        uint256 indexed epoch,
        uint256 rewardsPaid,
        uint256 rewardsRemaining
    );

    
    
    
    
    
    event RewardsPaid(
        uint256 indexed epoch,
        bytes32 indexed poolId,
        uint256 operatorReward,
        uint256 membersReward
    );

    
    
    
    
    
    
    event ParamsSet(
        uint256 epochDurationInSeconds,
        uint32 rewardDelegatedStakeWeight,
        uint256 minimumPoolStake,
        uint256 cobbDouglasAlphaNumerator,
        uint256 cobbDouglasAlphaDenominator
    );

    
    
    
    
    event StakingPoolCreated(
        bytes32 poolId,
        address operator,
        uint32 operatorShare
    );

    
    
    
    event MakerStakingPoolSet(
        address indexed makerAddress,
        bytes32 indexed poolId
    );

    
    
    
    
    event OperatorShareDecreased(
        bytes32 indexed poolId,
        uint32 oldOperatorShare,
        uint32 newOperatorShare
    );
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;








contract MixinScheduler is
    IStakingEvents,
    MixinStorage
{
    using LibSafeMath for uint256;

    
    ///      The next epoch can begin once this time is reached.
    ///      Epoch period = [startTimeInSeconds..endTimeInSeconds)
    
    function getCurrentEpochEarliestEndTimeInSeconds()
        public
        view
        returns (uint256)
    {
        return currentEpochStartTimeInSeconds.safeAdd(epochDurationInSeconds);
    }

    
    ///      Fails if state was already initialized.
    function _initMixinScheduler()
        internal
    {
        // assert the current values before overwriting them.
        _assertSchedulerNotInitialized();

        // solhint-disable-next-line
        currentEpochStartTimeInSeconds = block.timestamp;
        currentEpoch = 1;
    }

    
    ///      Time intervals that are measured in epochs (like timeLocks) are also incremented, given
    ///      their periods have ended.
    function _goToNextEpoch()
        internal
    {
        // get current timestamp
        // solhint-disable-next-line not-rely-on-time
        uint256 currentBlockTimestamp = block.timestamp;

        // validate that we can increment the current epoch
        uint256 epochEndTime = getCurrentEpochEarliestEndTimeInSeconds();
        if (epochEndTime > currentBlockTimestamp) {
            LibRichErrors.rrevert(LibStakingRichErrors.BlockTimestampTooLowError(
                epochEndTime,
                currentBlockTimestamp
            ));
        }

        // incremment epoch
        uint256 nextEpoch = currentEpoch.safeAdd(1);
        currentEpoch = nextEpoch;
        currentEpochStartTimeInSeconds = currentBlockTimestamp;
    }

    
    /// This must be updated for each migration.
    function _assertSchedulerNotInitialized()
        internal
        view
    {
        if (currentEpochStartTimeInSeconds != 0) {
            LibRichErrors.rrevert(
                LibStakingRichErrors.InitializationError(
                    LibStakingRichErrors.InitializationErrorCodes.MixinSchedulerAlreadyInitialized
                )
            );
        }
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;





// solhint-disable separate-by-one-line-in-contract
contract MixinDeploymentConstants {

    // @TODO SET THESE VALUES FOR DEPLOYMENT

    // Mainnet WETH9 Address
    address constant private WETH_ADDRESS = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    // Kovan WETH9 Address
    // address constant private WETH_ADDRESS = address(0xd0A1E359811322d97991E03f863a0C30C2cF029C);

    // Ropsten & Rinkeby WETH9 Address
    // address constant private WETH_ADDRESS = address(0xc778417E063141139Fce010982780140Aa0cD5Ab);

    // @TODO SET THESE VALUES FOR DEPLOYMENT

    // Mainnet ZrxVault address
    address constant private ZRX_VAULT_ADDRESS = address(0xBa7f8b5fB1b19c1211c5d49550fcD149177A5Eaf);

    // Kovan ZrxVault address
    // address constant private ZRX_VAULT_ADDRESS = address(0xf36eabdFE986B35b62c8FD5a98A7f2aEBB79B291);

    // Ropsten ZrxVault address
    // address constant private ZRX_VAULT_ADDRESS = address(0xffD161026865Ad8B4aB28a76840474935eEc4DfA);

    // Rinkeby ZrxVault address
    // address constant private ZRX_VAULT_ADDRESS = address(0xA5Bf6aC73bC40790FC6Ffc9DBbbCE76c9176e224);

    
    ///      Must be view to allow overrides to access state.
    
    function getWethContract()
        public
        view
        returns (IEtherToken wethContract)
    {
        wethContract = IEtherToken(WETH_ADDRESS);
        return wethContract;
    }

    
    ///      Must be view to allow overrides to access state.
    
    function getZrxVault()
        public
        view
        returns (IZrxVault zrxVault)
    {
        zrxVault = IZrxVault(ZRX_VAULT_ADDRESS);
        return zrxVault;
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;








contract MixinStakeStorage is
    MixinScheduler
{
    using LibSafeMath for uint256;
    using LibSafeDowncast for uint256;

    
    ///      This change comes into effect next epoch.
    
    
    
    function _moveStake(
        IStructs.StoredBalance storage fromPtr,
        IStructs.StoredBalance storage toPtr,
        uint256 amount
    )
        internal
    {
        // do nothing if pointers are equal
        if (_arePointersEqual(fromPtr, toPtr)) {
            return;
        }

        // load current balances from storage
        IStructs.StoredBalance memory from = _loadCurrentBalance(fromPtr);
        IStructs.StoredBalance memory to = _loadCurrentBalance(toPtr);

        // sanity check on balance
        if (amount > from.nextEpochBalance) {
            LibRichErrors.rrevert(
                LibStakingRichErrors.InsufficientBalanceError(
                    amount,
                    from.nextEpochBalance
                )
            );
        }

        // move stake for next epoch
        from.nextEpochBalance = uint256(from.nextEpochBalance).safeSub(amount).downcastToUint96();
        to.nextEpochBalance = uint256(to.nextEpochBalance).safeAdd(amount).downcastToUint96();

        // update state in storage
        _storeBalance(fromPtr, from);
        _storeBalance(toPtr, to);
    }

    
    
    
    function _loadCurrentBalance(IStructs.StoredBalance storage balancePtr)
        internal
        view
        returns (IStructs.StoredBalance memory balance)
    {
        balance = balancePtr;
        uint256 currentEpoch_ = currentEpoch;
        if (currentEpoch_ > balance.currentEpoch) {
            balance.currentEpoch = currentEpoch_.downcastToUint64();
            balance.currentEpochBalance = balance.nextEpochBalance;
        }
        return balance;
    }

    
    
    
    function _increaseCurrentAndNextBalance(IStructs.StoredBalance storage balancePtr, uint256 amount)
        internal
    {
        // Remove stake from balance
        IStructs.StoredBalance memory balance = _loadCurrentBalance(balancePtr);
        balance.nextEpochBalance = uint256(balance.nextEpochBalance).safeAdd(amount).downcastToUint96();
        balance.currentEpochBalance = uint256(balance.currentEpochBalance).safeAdd(amount).downcastToUint96();

        // update state
        _storeBalance(balancePtr, balance);
    }

    
    
    
    function _decreaseCurrentAndNextBalance(IStructs.StoredBalance storage balancePtr, uint256 amount)
        internal
    {
        // Remove stake from balance
        IStructs.StoredBalance memory balance = _loadCurrentBalance(balancePtr);
        balance.nextEpochBalance = uint256(balance.nextEpochBalance).safeSub(amount).downcastToUint96();
        balance.currentEpochBalance = uint256(balance.currentEpochBalance).safeSub(amount).downcastToUint96();

        // update state
        _storeBalance(balancePtr, balance);
    }

    
    
    
    function _increaseNextBalance(IStructs.StoredBalance storage balancePtr, uint256 amount)
        internal
    {
        // Add stake to balance
        IStructs.StoredBalance memory balance = _loadCurrentBalance(balancePtr);
        balance.nextEpochBalance = uint256(balance.nextEpochBalance).safeAdd(amount).downcastToUint96();

        // update state
        _storeBalance(balancePtr, balance);
    }

    
    
    
    function _decreaseNextBalance(IStructs.StoredBalance storage balancePtr, uint256 amount)
        internal
    {
        // Remove stake from balance
        IStructs.StoredBalance memory balance = _loadCurrentBalance(balancePtr);
        balance.nextEpochBalance = uint256(balance.nextEpochBalance).safeSub(amount).downcastToUint96();

        // update state
        _storeBalance(balancePtr, balance);
    }

    
    
    
    function _storeBalance(
        IStructs.StoredBalance storage balancePtr,
        IStructs.StoredBalance memory balance
    )
        private
    {
        // note - this compresses into a single `sstore` when optimizations are enabled,
        // since the StoredBalance struct occupies a single word of storage.
        balancePtr.currentEpoch = balance.currentEpoch;
        balancePtr.nextEpochBalance = balance.nextEpochBalance;
        balancePtr.currentEpochBalance = balance.currentEpochBalance;
    }

    
    
    
    
    function _arePointersEqual(
        // solhint-disable-next-line no-unused-vars
        IStructs.StoredBalance storage balancePtrA,
        // solhint-disable-next-line no-unused-vars
        IStructs.StoredBalance storage balancePtrB
    )
        private
        pure
        returns (bool areEqual)
    {
        assembly {
            areEqual := and(
                eq(balancePtrA_slot, balancePtrB_slot),
                eq(balancePtrA_offset, balancePtrB_offset)
            )
        }
        return areEqual;
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;


contract MixinConstants {

    // 100% in parts-per-million.
    uint32 constant internal PPM_DENOMINATOR = 10**6;

    bytes32 constant internal NIL_POOL_ID = 0x0000000000000000000000000000000000000000000000000000000000000000;

    address constant internal NIL_ADDRESS = 0x0000000000000000000000000000000000000000;

    uint256 constant internal MIN_TOKEN_VALUE = 10**18;
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;








contract MixinStakeBalances is
    MixinStakeStorage,
    MixinDeploymentConstants
{
    using LibSafeMath for uint256;

    
    
    
    function getGlobalStakeByStatus(IStructs.StakeStatus stakeStatus)
        external
        view
        returns (IStructs.StoredBalance memory balance)
    {
        balance = _loadCurrentBalance(
            _globalStakeByStatus[uint8(IStructs.StakeStatus.DELEGATED)]
        );
        if (stakeStatus == IStructs.StakeStatus.UNDELEGATED) {
            // Undelegated stake is the difference between total stake and delegated stake
            // Note that any ZRX erroneously sent to the vault will be counted as undelegated stake
            uint256 totalStake = getZrxVault().balanceOfZrxVault();
            balance.currentEpochBalance = totalStake.safeSub(balance.currentEpochBalance).downcastToUint96();
            balance.nextEpochBalance = totalStake.safeSub(balance.nextEpochBalance).downcastToUint96();
        }
        return balance;
    }

    
    
    
    
    function getOwnerStakeByStatus(
        address staker,
        IStructs.StakeStatus stakeStatus
    )
        external
        view
        returns (IStructs.StoredBalance memory balance)
    {
        balance = _loadCurrentBalance(
            _ownerStakeByStatus[uint8(stakeStatus)][staker]
        );
        return balance;
    }

    
    
    
    function getTotalStake(address staker)
        public
        view
        returns (uint256)
    {
        return getZrxVault().balanceOf(staker);
    }

    
    
    
    
    function getStakeDelegatedToPoolByOwner(address staker, bytes32 poolId)
        public
        view
        returns (IStructs.StoredBalance memory balance)
    {
        balance = _loadCurrentBalance(_delegatedStakeToPoolByOwner[staker][poolId]);
        return balance;
    }

    
    ///      across all members.
    
    
    function getTotalStakeDelegatedToPool(bytes32 poolId)
        public
        view
        returns (IStructs.StoredBalance memory balance)
    {
        balance = _loadCurrentBalance(_delegatedStakeByPoolId[poolId]);
        return balance;
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;








contract MixinCumulativeRewards is
    MixinStakeBalances,
    MixinConstants
{
    using LibSafeMath for uint256;

    
    function _isCumulativeRewardSet(IStructs.Fraction memory cumulativeReward)
        internal
        pure
        returns (bool)
    {
        // We use the denominator as a proxy for whether the cumulative
        // reward is set, as setting the cumulative reward always sets this
        // field to at least 1.
        return cumulativeReward.denominator != 0;
    }

    
    ///      given the rewards earned and stake from the last epoch, which will
    ///      be summed with the previous cumulative rewards for this pool.
    ///      If the last cumulative reward epoch is the current epoch, this is a
    ///      no-op.
    
    
    
    function _addCumulativeReward(
        bytes32 poolId,
        uint256 reward,
        uint256 stake
    )
        internal
    {
        // Fetch the last epoch at which we stored an entry for this pool;
        // this is the most up-to-date cumulative rewards for this pool.
        uint256 lastStoredEpoch = _cumulativeRewardsByPoolLastStored[poolId];
        uint256 currentEpoch_ = currentEpoch;

        // If we already have a record for this epoch, don't overwrite it.
        if (lastStoredEpoch == currentEpoch_) {
            return;
        }

        IStructs.Fraction memory mostRecentCumulativeReward =
            _cumulativeRewardsByPool[poolId][lastStoredEpoch];

        // Compute new cumulative reward
        IStructs.Fraction memory cumulativeReward;
        if (_isCumulativeRewardSet(mostRecentCumulativeReward)) {
            // If we have a prior cumulative reward entry, we sum them as fractions.
            (cumulativeReward.numerator, cumulativeReward.denominator) = LibFractions.add(
                mostRecentCumulativeReward.numerator,
                mostRecentCumulativeReward.denominator,
                reward,
                stake
            );
            // Normalize to prevent overflows in future operations.
            (cumulativeReward.numerator, cumulativeReward.denominator) = LibFractions.normalize(
                cumulativeReward.numerator,
                cumulativeReward.denominator
            );
        } else {
            (cumulativeReward.numerator, cumulativeReward.denominator) = (reward, stake);
        }

        // Store cumulative rewards for this epoch.
        _cumulativeRewardsByPool[poolId][currentEpoch_] = cumulativeReward;
        _cumulativeRewardsByPoolLastStored[poolId] = currentEpoch_;
    }

    
    ///      using the last stored cumulative rewards. If we've already set
    ///      a CR for this epoch, this is a no-op.
    
    function _updateCumulativeReward(bytes32 poolId)
        internal
    {
        // Just add empty rewards for this epoch, which will be added to
        // the previous CR, so we end up with the previous CR being set for
        // this epoch.
        _addCumulativeReward(poolId, 0, 1);
    }

    
    
    
    ///        the interval.
    
    
    
    function _computeMemberRewardOverInterval(
        bytes32 poolId,
        uint256 memberStakeOverInterval,
        uint256 beginEpoch,
        uint256 endEpoch
    )
        internal
        view
        returns (uint256 reward)
    {
        // Sanity check if we can skip computation, as it will result in zero.
        if (memberStakeOverInterval == 0 || beginEpoch == endEpoch) {
            return 0;
        }

        // Sanity check interval
        require(beginEpoch < endEpoch, "CR_INTERVAL_INVALID");

        // Sanity check begin reward
        IStructs.Fraction memory beginReward = _getCumulativeRewardAtEpoch(poolId, beginEpoch);
        IStructs.Fraction memory endReward = _getCumulativeRewardAtEpoch(poolId, endEpoch);

        // Compute reward
        reward = LibFractions.scaleDifference(
            endReward.numerator,
            endReward.denominator,
            beginReward.numerator,
            beginReward.denominator,
            memberStakeOverInterval
        );
    }

    
    
    
    function _getMostRecentCumulativeReward(bytes32 poolId)
        private
        view
        returns (IStructs.Fraction memory cumulativeReward)
    {
        uint256 lastStoredEpoch = _cumulativeRewardsByPoolLastStored[poolId];
        return _cumulativeRewardsByPool[poolId][lastStoredEpoch];
    }

    
    ///      If the corresponding CR does not exist in state, then we backtrack
    ///      to find its value by querying `epoch-1` and then most recent CR.
    
    
    
    
    function _getCumulativeRewardAtEpoch(bytes32 poolId, uint256 epoch)
        private
        view
        returns (IStructs.Fraction memory cumulativeReward)
    {
        // Return CR at `epoch`, given it's set.
        cumulativeReward = _cumulativeRewardsByPool[poolId][epoch];
        if (_isCumulativeRewardSet(cumulativeReward)) {
            return cumulativeReward;
        }

        // Return CR at `epoch-1`, given it's set.
        uint256 lastEpoch = epoch.safeSub(1);
        cumulativeReward = _cumulativeRewardsByPool[poolId][lastEpoch];
        if (_isCumulativeRewardSet(cumulativeReward)) {
            return cumulativeReward;
        }

        // Return the most recent CR, given it's less than `epoch`.
        uint256 mostRecentEpoch = _cumulativeRewardsByPoolLastStored[poolId];
        if (mostRecentEpoch < epoch) {
            cumulativeReward = _cumulativeRewardsByPool[poolId][mostRecentEpoch];
            if (_isCumulativeRewardSet(cumulativeReward)) {
                return cumulativeReward;
            }
        }

        // Otherwise return an empty CR.
        return IStructs.Fraction(0, 1);
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;




///      cyclical dependencies.
contract MixinAbstract {

    
    ///      Does nothing if the pool is already finalized.
    
    
    
    ///         this pool.
    function _getUnfinalizedPoolRewards(bytes32 poolId)
        internal
        view
        returns (
            uint256 totalReward,
            uint256 membersStake
        );

    
    
    function _assertPoolFinalizedLastEpoch(bytes32 poolId)
        internal
        view;
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;








contract MixinStakingPoolRewards is
    MixinAbstract,
    MixinCumulativeRewards
{
    using LibSafeMath for uint256;

    
    ///      until the last epoch.
    
    function withdrawDelegatorRewards(bytes32 poolId)
        external
    {
        _withdrawAndSyncDelegatorRewards(poolId, msg.sender);
    }

    
    
    
    function computeRewardBalanceOfOperator(bytes32 poolId)
        external
        view
        returns (uint256 reward)
    {
        // Because operator rewards are immediately withdrawn as WETH
        // on finalization, the only factor in this function are unfinalized
        // rewards.
        IStructs.Pool memory pool = _poolById[poolId];
        // Get any unfinalized rewards.
        (uint256 unfinalizedTotalRewards, uint256 unfinalizedMembersStake) =
            _getUnfinalizedPoolRewards(poolId);

        // Get the operators' portion.
        (reward,) = _computePoolRewardsSplit(
            pool.operatorShare,
            unfinalizedTotalRewards,
            unfinalizedMembersStake
        );
        return reward;
    }

    
    
    
    
    function computeRewardBalanceOfDelegator(bytes32 poolId, address member)
        external
        view
        returns (uint256 reward)
    {
        IStructs.Pool memory pool = _poolById[poolId];
        // Get any unfinalized rewards.
        (uint256 unfinalizedTotalRewards, uint256 unfinalizedMembersStake) =
            _getUnfinalizedPoolRewards(poolId);

        // Get the members' portion.
        (, uint256 unfinalizedMembersReward) = _computePoolRewardsSplit(
            pool.operatorShare,
            unfinalizedTotalRewards,
            unfinalizedMembersStake
        );
        return _computeDelegatorReward(
            poolId,
            member,
            unfinalizedMembersReward,
            unfinalizedMembersStake
        );
    }

    
    ///      rewards and adding/removing dependencies on cumulative rewards.
    
    
    function _withdrawAndSyncDelegatorRewards(
        bytes32 poolId,
        address member
    )
        internal
    {
        // Ensure the pool is finalized.
        _assertPoolFinalizedLastEpoch(poolId);

        // Compute balance owed to delegator
        uint256 balance = _computeDelegatorReward(
            poolId,
            member,
            // No unfinalized values because we ensured the pool is already
            // finalized.
            0,
            0
        );

        // Sync the delegated stake balance. This will ensure future calls of
        // `_computeDelegatorReward` during this epoch will return 0, 
        // preventing a delegator from withdrawing more than once an epoch.
        _delegatedStakeToPoolByOwner[member][poolId] =
            _loadCurrentBalance(_delegatedStakeToPoolByOwner[member][poolId]);

        // Withdraw non-0 balance
        if (balance != 0) {
            // Decrease the balance of the pool
            _decreasePoolRewards(poolId, balance);

            // Withdraw the member's WETH balance
            getWethContract().transfer(member, balance);
        }

        // Ensure a cumulative reward entry exists for this epoch,
        // copying the previous epoch's CR if one doesn't exist already.
        _updateCumulativeReward(poolId);
    }

    
    ///      This will split the reward between the operator and members,
    ///      depositing them into their respective vaults, and update the
    ///      accounting needed to allow members to withdraw their individual
    ///      rewards.
    
    
    
    ///        will split the  reward.
    
    
    function _syncPoolRewards(
        bytes32 poolId,
        uint256 reward,
        uint256 membersStake
    )
        internal
        returns (uint256 operatorReward, uint256 membersReward)
    {
        IStructs.Pool memory pool = _poolById[poolId];

        // Split the reward between operator and members
        (operatorReward, membersReward) = _computePoolRewardsSplit(
            pool.operatorShare,
            reward,
            membersStake
        );

        if (operatorReward > 0) {
            // Transfer the operator's weth reward to the operator
            getWethContract().transfer(pool.operator, operatorReward);
        }

        if (membersReward > 0) {
            // Increase the balance of the pool
            _increasePoolRewards(poolId, membersReward);
            // Create a cumulative reward entry at the current epoch.
            _addCumulativeReward(poolId, membersReward, membersStake);
        }

        return (operatorReward, membersReward);
    }

    
    ///      based on the `operatorShare` and `membersStake`.
    
    ///        in PPM.
    
    
    ///        to the pool in the epoch the rewards were earned.
    
    
    function _computePoolRewardsSplit(
        uint32 operatorShare,
        uint256 totalReward,
        uint256 membersStake
    )
        internal
        pure
        returns (uint256 operatorReward, uint256 membersReward)
    {
        if (membersStake == 0) {
            operatorReward = totalReward;
        } else {
            operatorReward = LibMath.getPartialAmountCeil(
                uint256(operatorShare),
                PPM_DENOMINATOR,
                totalReward
            );
            membersReward = totalReward.safeSub(operatorReward);
        }
        return (operatorReward, membersReward);
    }

    
    
    
    
    
    
    function _computeDelegatorReward(
        bytes32 poolId,
        address member,
        uint256 unfinalizedMembersReward,
        uint256 unfinalizedMembersStake
    )
        private
        view
        returns (uint256 reward)
    {
        uint256 currentEpoch_ = currentEpoch;
        IStructs.StoredBalance memory delegatedStake = _delegatedStakeToPoolByOwner[member][poolId];

        // There can be no rewards if the last epoch when stake was stored is
        // equal to the current epoch, because all prior rewards, including
        // rewards finalized this epoch have been claimed.
        if (delegatedStake.currentEpoch == currentEpoch_) {
            return 0;
        }

        // We account for rewards over 3 intervals, below.

        // 1/3 Unfinalized rewards earned in `currentEpoch - 1`.
        reward = _computeUnfinalizedDelegatorReward(
            delegatedStake,
            currentEpoch_,
            unfinalizedMembersReward,
            unfinalizedMembersStake
        );

        // 2/3 Finalized rewards earned in epochs [`delegatedStake.currentEpoch + 1` .. `currentEpoch - 1`]
        uint256 delegatedStakeNextEpoch = uint256(delegatedStake.currentEpoch).safeAdd(1);
        reward = reward.safeAdd(
            _computeMemberRewardOverInterval(
                poolId,
                delegatedStake.currentEpochBalance,
                delegatedStake.currentEpoch,
                delegatedStakeNextEpoch
            )
        );

        // 3/3 Finalized rewards earned in epoch `delegatedStake.currentEpoch`.
        reward = reward.safeAdd(
            _computeMemberRewardOverInterval(
                poolId,
                delegatedStake.nextEpochBalance,
                delegatedStakeNextEpoch,
                currentEpoch_
            )
        );

        return reward;
    }

    
    
    
    
    
    
    function _computeUnfinalizedDelegatorReward(
        IStructs.StoredBalance memory delegatedStake,
        uint256 currentEpoch_,
        uint256 unfinalizedMembersReward,
        uint256 unfinalizedMembersStake
    )
        private
        pure
        returns (uint256)
    {
        // If there are unfinalized rewards this epoch, compute the member's
        // share.
        if (unfinalizedMembersReward == 0 || unfinalizedMembersStake == 0) {
            return 0;
        }

        // Unfinalized rewards are always earned from stake in
        // the prior epoch so we want the stake at `currentEpoch_-1`.
        uint256 unfinalizedStakeBalance = delegatedStake.currentEpoch >= currentEpoch_.safeSub(1) ?
            delegatedStake.currentEpochBalance :
            delegatedStake.nextEpochBalance;

        // Sanity check to save gas on computation
        if (unfinalizedStakeBalance == 0) {
            return 0;
        }

        // Compute unfinalized reward
        return LibMath.getPartialAmountFloor(
            unfinalizedMembersReward,
            unfinalizedMembersStake,
            unfinalizedStakeBalance
        );
    }

    
    
    
    function _increasePoolRewards(bytes32 poolId, uint256 amount)
        private
    {
        rewardsByPoolId[poolId] = rewardsByPoolId[poolId].safeAdd(amount);
        wethReservedForPoolRewards = wethReservedForPoolRewards.safeAdd(amount);
    }

    
    
    
    function _decreasePoolRewards(bytes32 poolId, uint256 amount)
        private
    {
        rewardsByPoolId[poolId] = rewardsByPoolId[poolId].safeSub(amount);
        wethReservedForPoolRewards = wethReservedForPoolRewards.safeSub(amount);
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;










contract MixinStakingPool is
    MixinAbstract,
    MixinStakingPoolRewards
{
    using LibSafeMath for uint256;
    using LibSafeDowncast for uint256;

    
    
    modifier onlyStakingPoolOperator(bytes32 poolId) {
        _assertSenderIsPoolOperator(poolId);
        _;
    }

    
    /// Note that an operator must be payable.
    
    
    
    function createStakingPool(uint32 operatorShare, bool addOperatorAsMaker)
        external
        returns (bytes32 poolId)
    {
        // note that an operator must be payable
        address operator = msg.sender;

        // compute unique id for this pool
        poolId = lastPoolId = bytes32(uint256(lastPoolId).safeAdd(1));

        // sanity check on operator share
        _assertNewOperatorShare(
            poolId,
            PPM_DENOMINATOR,    // max operator share
            operatorShare
        );

        // create and store pool
        IStructs.Pool memory pool = IStructs.Pool({
            operator: operator,
            operatorShare: operatorShare
        });
        _poolById[poolId] = pool;

        // Staking pool has been created
        emit StakingPoolCreated(poolId, operator, operatorShare);

        if (addOperatorAsMaker) {
            joinStakingPoolAsMaker(poolId);
        }

        return poolId;
    }

    
    
    
    function decreaseStakingPoolOperatorShare(bytes32 poolId, uint32 newOperatorShare)
        external
        onlyStakingPoolOperator(poolId)
    {
        // load pool and assert that we can decrease
        uint32 currentOperatorShare = _poolById[poolId].operatorShare;
        _assertNewOperatorShare(
            poolId,
            currentOperatorShare,
            newOperatorShare
        );

        // decrease operator share
        _poolById[poolId].operatorShare = newOperatorShare;
        emit OperatorShareDecreased(
            poolId,
            currentOperatorShare,
            newOperatorShare
        );
    }

    
    
    function joinStakingPoolAsMaker(bytes32 poolId)
        public
    {
        address maker = msg.sender;
        poolIdByMaker[maker] = poolId;
        emit MakerStakingPoolSet(
            maker,
            poolId
        );
    }

    
    
    function getStakingPool(bytes32 poolId)
        public
        view
        returns (IStructs.Pool memory)
    {
        return _poolById[poolId];
    }

    
    
    function _assertStakingPoolExists(bytes32 poolId)
        internal
        view
    {
        if (_poolById[poolId].operator == NIL_ADDRESS) {
            // we use the pool's operator as a proxy for its existence
            LibRichErrors.rrevert(
                LibStakingRichErrors.PoolExistenceError(
                    poolId,
                    false
                )
            );
        }
    }

    
    
    
    
    function _assertNewOperatorShare(
        bytes32 poolId,
        uint32 currentOperatorShare,
        uint32 newOperatorShare
    )
        private
        pure
    {
        // sanity checks
        if (newOperatorShare > PPM_DENOMINATOR) {
            // operator share must be a valid fraction
            LibRichErrors.rrevert(LibStakingRichErrors.OperatorShareError(
                LibStakingRichErrors.OperatorShareErrorCodes.OperatorShareTooLarge,
                poolId,
                newOperatorShare
            ));
        } else if (newOperatorShare > currentOperatorShare) {
            // new share must be less than or equal to the current share
            LibRichErrors.rrevert(LibStakingRichErrors.OperatorShareError(
                LibStakingRichErrors.OperatorShareErrorCodes.CanOnlyDecreaseOperatorShare,
                poolId,
                newOperatorShare
            ));
        }
    }

    
    
    function _assertSenderIsPoolOperator(bytes32 poolId)
        private
        view
    {
        address operator = _poolById[poolId].operator;
        if (msg.sender != operator) {
            LibRichErrors.rrevert(
                LibStakingRichErrors.OnlyCallableByPoolOperatorError(
                    msg.sender,
                    poolId
                )
            );
        }
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;










contract MixinFinalizer is
    MixinStakingPoolRewards
{
    using LibSafeMath for uint256;

    
    ///      Throws if not enough time has passed between epochs or if the
    ///      previous epoch was not fully finalized.
    
    function endEpoch()
        external
        returns (uint256)
    {
        uint256 currentEpoch_ = currentEpoch;
        uint256 prevEpoch = currentEpoch_.safeSub(1);

        // Make sure the previous epoch has been fully finalized.
        uint256 numPoolsToFinalizeFromPrevEpoch = aggregatedStatsByEpoch[prevEpoch].numPoolsToFinalize;
        if (numPoolsToFinalizeFromPrevEpoch != 0) {
            LibRichErrors.rrevert(
                LibStakingRichErrors.PreviousEpochNotFinalizedError(
                    prevEpoch,
                    numPoolsToFinalizeFromPrevEpoch
                )
            );
        }

        // Convert all ETH to WETH; the WETH balance of this contract is the total rewards.
        _wrapEth();

        // Load aggregated stats for the epoch we're ending.
        aggregatedStatsByEpoch[currentEpoch_].rewardsAvailable = _getAvailableWethBalance();
        IStructs.AggregatedStats memory aggregatedStats = aggregatedStatsByEpoch[currentEpoch_];

        // Emit an event.
        emit EpochEnded(
            currentEpoch_,
            aggregatedStats.numPoolsToFinalize,
            aggregatedStats.rewardsAvailable,
            aggregatedStats.totalFeesCollected,
            aggregatedStats.totalWeightedStake
        );

        // Advance the epoch. This will revert if not enough time has passed.
        _goToNextEpoch();

        // If there are no pools to finalize then the epoch is finalized.
        if (aggregatedStats.numPoolsToFinalize == 0) {
            emit EpochFinalized(currentEpoch_, 0, aggregatedStats.rewardsAvailable);
        }

        return aggregatedStats.numPoolsToFinalize;
    }

    
    ///      epoch, crediting it rewards for members and withdrawing operator's
    ///      rewards as WETH. This can be called by internal functions that need
    ///      to finalize a pool immediately. Does nothing if the pool is already
    ///      finalized or did not earn rewards in the previous epoch.
    
    function finalizePool(bytes32 poolId)
        external
    {
        // Compute relevant epochs
        uint256 currentEpoch_ = currentEpoch;
        uint256 prevEpoch = currentEpoch_.safeSub(1);

        // Load the aggregated stats into memory; noop if no pools to finalize.
        IStructs.AggregatedStats memory aggregatedStats = aggregatedStatsByEpoch[prevEpoch];
        if (aggregatedStats.numPoolsToFinalize == 0) {
            return;
        }

        // Noop if the pool did not earn rewards or already finalized (has no fees).
        IStructs.PoolStats memory poolStats = poolStatsByEpoch[poolId][prevEpoch];
        if (poolStats.feesCollected == 0) {
            return;
        }

        // Clear the pool stats so we don't finalize it again, and to recoup
        // some gas.
        delete poolStatsByEpoch[poolId][prevEpoch];

        // Compute the rewards.
        uint256 rewards = _getUnfinalizedPoolRewardsFromPoolStats(poolStats, aggregatedStats);

        // Pay the operator and update rewards for the pool.
        // Note that we credit at the CURRENT epoch even though these rewards
        // were earned in the previous epoch.
        (uint256 operatorReward, uint256 membersReward) = _syncPoolRewards(
            poolId,
            rewards,
            poolStats.membersStake
        );

        // Emit an event.
        emit RewardsPaid(
            currentEpoch_,
            poolId,
            operatorReward,
            membersReward
        );

        uint256 totalReward = operatorReward.safeAdd(membersReward);

        // Increase `totalRewardsFinalized`.
        aggregatedStatsByEpoch[prevEpoch].totalRewardsFinalized =
            aggregatedStats.totalRewardsFinalized =
            aggregatedStats.totalRewardsFinalized.safeAdd(totalReward);

        // Decrease the number of unfinalized pools left.
        aggregatedStatsByEpoch[prevEpoch].numPoolsToFinalize =
            aggregatedStats.numPoolsToFinalize =
            aggregatedStats.numPoolsToFinalize.safeSub(1);

        // If there are no more unfinalized pools remaining, the epoch is
        // finalized.
        if (aggregatedStats.numPoolsToFinalize == 0) {
            emit EpochFinalized(
                prevEpoch,
                aggregatedStats.totalRewardsFinalized,
                aggregatedStats.rewardsAvailable.safeSub(aggregatedStats.totalRewardsFinalized)
            );
        }
    }

    
    ///      Does nothing if the pool is already finalized.
    
    
    
    ///         this pool.
    function _getUnfinalizedPoolRewards(bytes32 poolId)
        internal
        view
        returns (
            uint256 reward,
            uint256 membersStake
        )
    {
        uint256 prevEpoch = currentEpoch.safeSub(1);
        IStructs.PoolStats memory poolStats = poolStatsByEpoch[poolId][prevEpoch];
        reward = _getUnfinalizedPoolRewardsFromPoolStats(poolStats, aggregatedStatsByEpoch[prevEpoch]);
        membersStake = poolStats.membersStake;
    }

    
    function _wrapEth()
        internal
    {
        uint256 ethBalance = address(this).balance;
        if (ethBalance != 0) {
            getWethContract().deposit.value(ethBalance)();
        }
    }

    
    ///      any WETH that has already been reserved for rewards.
    function _getAvailableWethBalance()
        internal
        view
        returns (uint256 wethBalance)
    {
        wethBalance = getWethContract().balanceOf(address(this))
            .safeSub(wethReservedForPoolRewards);

        return wethBalance;
    }

    
    
    function _assertPoolFinalizedLastEpoch(bytes32 poolId)
        internal
        view
    {
        uint256 prevEpoch = currentEpoch.safeSub(1);
        IStructs.PoolStats memory poolStats = poolStatsByEpoch[poolId][prevEpoch];

        // A pool that has any fees remaining has not been finalized
        if (poolStats.feesCollected != 0) {
            LibRichErrors.rrevert(
                LibStakingRichErrors.PoolNotFinalizedError(
                    poolId,
                    prevEpoch
                )
            );
        }
    }

    
    
    
    
    function _getUnfinalizedPoolRewardsFromPoolStats(
        IStructs.PoolStats memory poolStats,
        IStructs.AggregatedStats memory aggregatedStats
    )
        private
        view
        returns (uint256 rewards)
    {
        // There can't be any rewards if the pool did not collect any fees.
        if (poolStats.feesCollected == 0) {
            return rewards;
        }

        // Use the cobb-douglas function to compute the total reward.
        rewards = LibCobbDouglas.cobbDouglas(
            aggregatedStats.rewardsAvailable,
            poolStats.feesCollected,
            aggregatedStats.totalFeesCollected,
            poolStats.weightedStake,
            aggregatedStats.totalWeightedStake,
            cobbDouglasAlphaNumerator,
            cobbDouglasAlphaDenominator
        );

        // Clip the reward to always be under
        // `rewardsAvailable - totalRewardsPaid`,
        // in case cobb-douglas overflows, which should be unlikely.
        uint256 rewardsRemaining = aggregatedStats.rewardsAvailable.safeSub(aggregatedStats.totalRewardsFinalized);
        if (rewardsRemaining < rewards) {
            rewards = rewardsRemaining;
        }
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;







contract MixinExchangeManager is
    IStakingEvents,
    MixinStorage
{
    
    modifier onlyExchange() {
        if (!validExchanges[msg.sender]) {
            LibRichErrors.rrevert(LibStakingRichErrors.OnlyCallableByExchangeError(
                msg.sender
            ));
        }
        _;
    }

    
    
    function addExchangeAddress(address addr)
        external
        onlyAuthorized
    {
        if (validExchanges[addr]) {
            LibRichErrors.rrevert(LibStakingRichErrors.ExchangeManagerError(
                LibStakingRichErrors.ExchangeManagerErrorCodes.ExchangeAlreadyRegistered,
                addr
            ));
        }
        validExchanges[addr] = true;
        emit ExchangeAdded(addr);
    }

    
    
    function removeExchangeAddress(address addr)
        external
        onlyAuthorized
    {
        if (!validExchanges[addr]) {
            LibRichErrors.rrevert(LibStakingRichErrors.ExchangeManagerError(
                LibStakingRichErrors.ExchangeManagerErrorCodes.ExchangeNotRegistered,
                addr
            ));
        }
        validExchanges[addr] = false;
        emit ExchangeRemoved(addr);
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;







interface IStaking {

    
    
    function addExchangeAddress(address addr)
        external;

    
    /// Note that an operator must be payable.
    
    
    
    function createStakingPool(uint32 operatorShare, bool addOperatorAsMaker)
        external
        returns (bytes32 poolId);

    
    
    
    function decreaseStakingPoolOperatorShare(bytes32 poolId, uint32 newOperatorShare)
        external;

    
    ///      Throws if not enough time has passed between epochs or if the
    ///      previous epoch was not fully finalized.
    
    function endEpoch()
        external
        returns (uint256);

    
    ///      epoch, crediting it rewards for members and withdrawing operator's
    ///      rewards as WETH. This can be called by internal functions that need
    ///      to finalize a pool immediately. Does nothing if the pool is already
    ///      finalized or did not earn rewards in the previous epoch.
    
    function finalizePool(bytes32 poolId)
        external;

    
    ///      This function should not be called directly.
    ///      The StakingProxy contract will call it in `attachStakingContract()`.
    function init()
        external;

    
    
    function joinStakingPoolAsMaker(bytes32 poolId)
        external;

    
    ///      Delegated stake can also be moved between pools.
    ///      This change comes into effect next epoch.
    
    
    
    function moveStake(
        IStructs.StakeInfo calldata from,
        IStructs.StakeInfo calldata to,
        uint256 amount
    )
        external;

    
    
    
    
    function payProtocolFee(
        address makerAddress,
        address payerAddress,
        uint256 protocolFee
    )
        external
        payable;

    
    
    function removeExchangeAddress(address addr)
        external;

    
    
    
    
    
    
    function setParams(
        uint256 _epochDurationInSeconds,
        uint32 _rewardDelegatedStakeWeight,
        uint256 _minimumPoolStake,
        uint32 _cobbDouglasAlphaNumerator,
        uint32 _cobbDouglasAlphaDenominator
    )
        external;

    
    ///      Unstake to retrieve the ZRX. Stake is in the 'Active' status.
    
    function stake(uint256 amount)
        external;

    
    ///      the staker. Stake must be in the 'undelegated' status in both the
    ///      current and next epoch in order to be unstaked.
    
    function unstake(uint256 amount)
        external;

    
    ///      until the last epoch.
    
    function withdrawDelegatorRewards(bytes32 poolId)
        external;

    
    
    
    
    function computeRewardBalanceOfDelegator(bytes32 poolId, address member)
        external
        view
        returns (uint256 reward);

    
    
    
    function computeRewardBalanceOfOperator(bytes32 poolId)
        external
        view
        returns (uint256 reward);

    
    ///      The next epoch can begin once this time is reached.
    ///      Epoch period = [startTimeInSeconds..endTimeInSeconds)
    
    function getCurrentEpochEarliestEndTimeInSeconds()
        external
        view
        returns (uint256);

    
    
    
    function getGlobalStakeByStatus(IStructs.StakeStatus stakeStatus)
        external
        view
        returns (IStructs.StoredBalance memory balance);

    
    
    
    
    function getOwnerStakeByStatus(
        address staker,
        IStructs.StakeStatus stakeStatus
    )
        external
        view
        returns (IStructs.StoredBalance memory balance);

    
    
    
    
    
    
    function getParams()
        external
        view
        returns (
            uint256 _epochDurationInSeconds,
            uint32 _rewardDelegatedStakeWeight,
            uint256 _minimumPoolStake,
            uint32 _cobbDouglasAlphaNumerator,
            uint32 _cobbDouglasAlphaDenominator
        );

    
    
    
    function getStakeDelegatedToPoolByOwner(address staker, bytes32 poolId)
        external
        view
        returns (IStructs.StoredBalance memory balance);

    
    
    function getStakingPool(bytes32 poolId)
        external
        view
        returns (IStructs.Pool memory);

    
    
    
    function getStakingPoolStatsThisEpoch(bytes32 poolId)
        external
        view
        returns (IStructs.PoolStats memory);

    
    ///      across all members.
    
    
    function getTotalStakeDelegatedToPool(bytes32 poolId)
        external
        view
        returns (IStructs.StoredBalance memory balance);

    
    ///      Must be view to allow overrides to access state.
    
    function getWethContract()
        external
        view
        returns (IEtherToken wethContract);

    
    ///      Must be view to allow overrides to access state.
    
    function getZrxVault()
        external
        view
        returns (IZrxVault zrxVault);
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;









contract MixinParams is
    IStakingEvents,
    MixinStorage,
    MixinConstants
{
    
    
    
    
    
    
    function setParams(
        uint256 _epochDurationInSeconds,
        uint32 _rewardDelegatedStakeWeight,
        uint256 _minimumPoolStake,
        uint32 _cobbDouglasAlphaNumerator,
        uint32 _cobbDouglasAlphaDenominator
    )
        external
        onlyAuthorized
    {
        _setParams(
            _epochDurationInSeconds,
            _rewardDelegatedStakeWeight,
            _minimumPoolStake,
            _cobbDouglasAlphaNumerator,
            _cobbDouglasAlphaDenominator
        );

        // Let the staking proxy enforce that these parameters are within
        // acceptable ranges.
        IStakingProxy(address(this)).assertValidStorageParams();
    }

    
    
    
    
    
    
    function getParams()
        external
        view
        returns (
            uint256 _epochDurationInSeconds,
            uint32 _rewardDelegatedStakeWeight,
            uint256 _minimumPoolStake,
            uint32 _cobbDouglasAlphaNumerator,
            uint32 _cobbDouglasAlphaDenominator
        )
    {
        _epochDurationInSeconds = epochDurationInSeconds;
        _rewardDelegatedStakeWeight = rewardDelegatedStakeWeight;
        _minimumPoolStake = minimumPoolStake;
        _cobbDouglasAlphaNumerator = cobbDouglasAlphaNumerator;
        _cobbDouglasAlphaDenominator = cobbDouglasAlphaDenominator;
    }

    
    function _initMixinParams()
        internal
    {
        // Ensure state is uninitialized.
        _assertParamsNotInitialized();

        // Set up defaults.
        uint256 _epochDurationInSeconds = 10 days;
        uint32 _rewardDelegatedStakeWeight = (90 * PPM_DENOMINATOR) / 100;
        uint256 _minimumPoolStake = 100 * MIN_TOKEN_VALUE;
        uint32 _cobbDouglasAlphaNumerator = 2;
        uint32 _cobbDouglasAlphaDenominator = 3;

        _setParams(
            _epochDurationInSeconds,
            _rewardDelegatedStakeWeight,
            _minimumPoolStake,
            _cobbDouglasAlphaNumerator,
            _cobbDouglasAlphaDenominator
        );
    }

    
    function _assertParamsNotInitialized()
        internal
        view
    {
        if (epochDurationInSeconds != 0 &&
            rewardDelegatedStakeWeight != 0 &&
            minimumPoolStake != 0 &&
            cobbDouglasAlphaNumerator != 0 &&
            cobbDouglasAlphaDenominator != 0
        ) {
            LibRichErrors.rrevert(
                LibStakingRichErrors.InitializationError(
                    LibStakingRichErrors.InitializationErrorCodes.MixinParamsAlreadyInitialized
                )
            );
        }
    }

    
    
    
    
    
    
    function _setParams(
        uint256 _epochDurationInSeconds,
        uint32 _rewardDelegatedStakeWeight,
        uint256 _minimumPoolStake,
        uint32 _cobbDouglasAlphaNumerator,
        uint32 _cobbDouglasAlphaDenominator
    )
        private
    {
        epochDurationInSeconds = _epochDurationInSeconds;
        rewardDelegatedStakeWeight = _rewardDelegatedStakeWeight;
        minimumPoolStake = _minimumPoolStake;
        cobbDouglasAlphaNumerator = _cobbDouglasAlphaNumerator;
        cobbDouglasAlphaDenominator = _cobbDouglasAlphaDenominator;

        emit ParamsSet(
            _epochDurationInSeconds,
            _rewardDelegatedStakeWeight,
            _minimumPoolStake,
            _cobbDouglasAlphaNumerator,
            _cobbDouglasAlphaDenominator
        );
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;







contract MixinStake is
    MixinStakingPool
{
    using LibSafeMath for uint256;

    
    ///      Unstake to retrieve the ZRX. Stake is in the 'Active' status.
    
    function stake(uint256 amount)
        external
    {
        address staker = msg.sender;

        // deposit equivalent amount of ZRX into vault
        getZrxVault().depositFrom(staker, amount);

        // mint stake
        _increaseCurrentAndNextBalance(
            _ownerStakeByStatus[uint8(IStructs.StakeStatus.UNDELEGATED)][staker],
            amount
        );

        // notify
        emit Stake(
            staker,
            amount
        );
    }

    
    ///      the staker. Stake must be in the 'undelegated' status in both the
    ///      current and next epoch in order to be unstaked.
    
    function unstake(uint256 amount)
        external
    {
        address staker = msg.sender;

        IStructs.StoredBalance memory undelegatedBalance =
            _loadCurrentBalance(_ownerStakeByStatus[uint8(IStructs.StakeStatus.UNDELEGATED)][staker]);

        // stake must be undelegated in current and next epoch to be withdrawn
        uint256 currentWithdrawableStake = LibSafeMath.min256(
            undelegatedBalance.currentEpochBalance,
            undelegatedBalance.nextEpochBalance
        );

        if (amount > currentWithdrawableStake) {
            LibRichErrors.rrevert(
                LibStakingRichErrors.InsufficientBalanceError(
                    amount,
                    currentWithdrawableStake
                )
            );
        }

        // burn undelegated stake
        _decreaseCurrentAndNextBalance(
            _ownerStakeByStatus[uint8(IStructs.StakeStatus.UNDELEGATED)][staker],
            amount
        );

        // withdraw equivalent amount of ZRX from vault
        getZrxVault().withdrawFrom(staker, amount);

        // emit stake event
        emit Unstake(
            staker,
            amount
        );
    }

    
    ///      Delegated stake can also be moved between pools.
    ///      This change comes into effect next epoch.
    
    
    
    function moveStake(
        IStructs.StakeInfo calldata from,
        IStructs.StakeInfo calldata to,
        uint256 amount
    )
        external
    {
        address staker = msg.sender;

        // Sanity check: no-op if no stake is being moved.
        if (amount == 0) {
            return;
        }

        // Sanity check: no-op if moving stake from undelegated to undelegated.
        if (from.status == IStructs.StakeStatus.UNDELEGATED &&
            to.status == IStructs.StakeStatus.UNDELEGATED) {
            return;
        }

        // handle delegation
        if (from.status == IStructs.StakeStatus.DELEGATED) {
            _undelegateStake(
                from.poolId,
                staker,
                amount
            );
        }

        if (to.status == IStructs.StakeStatus.DELEGATED) {
            _delegateStake(
                to.poolId,
                staker,
                amount
            );
        }

        // execute move
        IStructs.StoredBalance storage fromPtr = _ownerStakeByStatus[uint8(from.status)][staker];
        IStructs.StoredBalance storage toPtr = _ownerStakeByStatus[uint8(to.status)][staker];
        _moveStake(
            fromPtr,
            toPtr,
            amount
        );

        // notify
        emit MoveStake(
            staker,
            amount,
            uint8(from.status),
            from.poolId,
            uint8(to.status),
            to.poolId
        );
    }

    
    
    
    
    function _delegateStake(
        bytes32 poolId,
        address staker,
        uint256 amount
    )
        private
    {
        // Sanity check the pool we're delegating to exists.
        _assertStakingPoolExists(poolId);

        _withdrawAndSyncDelegatorRewards(
            poolId,
            staker
        );

        // Increase how much stake the staker has delegated to the input pool.
        _increaseNextBalance(
            _delegatedStakeToPoolByOwner[staker][poolId],
            amount
        );

        // Increase how much stake has been delegated to pool.
        _increaseNextBalance(
            _delegatedStakeByPoolId[poolId],
            amount
        );

        // Increase next balance of global delegated stake.
        _increaseNextBalance(
            _globalStakeByStatus[uint8(IStructs.StakeStatus.DELEGATED)],
            amount
        );
    }

    
    
    
    
    function _undelegateStake(
        bytes32 poolId,
        address staker,
        uint256 amount
    )
        private
    {
        // sanity check the pool we're undelegating from exists
        _assertStakingPoolExists(poolId);

        _withdrawAndSyncDelegatorRewards(
            poolId,
            staker
        );

        // Decrease how much stake the staker has delegated to the input pool.
        _decreaseNextBalance(
            _delegatedStakeToPoolByOwner[staker][poolId],
            amount
        );

        // Decrease how much stake has been delegated to pool.
        _decreaseNextBalance(
            _delegatedStakeByPoolId[poolId],
            amount
        );

        // Decrease next balance of global delegated stake (aggregated across all stakers).
        _decreaseNextBalance(
            _globalStakeByStatus[uint8(IStructs.StakeStatus.DELEGATED)],
            amount
        );
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;












contract MixinExchangeFees is
    MixinExchangeManager,
    MixinStakingPool,
    MixinFinalizer
{
    using LibSafeMath for uint256;

    
    ///      Only a known 0x exchange can call this method. See
    ///      (MixinExchangeManager).
    
    
    
    function payProtocolFee(
        address makerAddress,
        address payerAddress,
        uint256 protocolFee
    )
        external
        payable
        onlyExchange
    {
        _assertValidProtocolFee(protocolFee);

        if (protocolFee == 0) {
            return;
        }

        // Transfer the protocol fee to this address if it should be paid in
        // WETH.
        if (msg.value == 0) {
            require(
                getWethContract().transferFrom(
                    payerAddress,
                    address(this),
                    protocolFee
                ),
                "WETH_TRANSFER_FAILED"
            );
        }

        // Get the pool id of the maker address.
        bytes32 poolId = poolIdByMaker[makerAddress];

        // Only attribute the protocol fee payment to a pool if the maker is
        // registered to a pool.
        if (poolId == NIL_POOL_ID) {
            return;
        }

        uint256 poolStake = getTotalStakeDelegatedToPool(poolId).currentEpochBalance;
        // Ignore pools with dust stake.
        if (poolStake < minimumPoolStake) {
            return;
        }

        // Look up the pool stats and aggregated stats for this epoch.
        uint256 currentEpoch_ = currentEpoch;
        IStructs.PoolStats storage poolStatsPtr = poolStatsByEpoch[poolId][currentEpoch_];
        IStructs.AggregatedStats storage aggregatedStatsPtr = aggregatedStatsByEpoch[currentEpoch_];

        // Perform some initialization if this is the pool's first protocol fee in this epoch.
        uint256 feesCollectedByPool = poolStatsPtr.feesCollected;
        if (feesCollectedByPool == 0) {
            // Compute member and total weighted stake.
            (uint256 membersStakeInPool, uint256 weightedStakeInPool) = _computeMembersAndWeightedStake(poolId, poolStake);
            poolStatsPtr.membersStake = membersStakeInPool;
            poolStatsPtr.weightedStake = weightedStakeInPool;

            // Increase the total weighted stake.
            aggregatedStatsPtr.totalWeightedStake = aggregatedStatsPtr.totalWeightedStake.safeAdd(weightedStakeInPool);

            // Increase the number of pools to finalize.
            aggregatedStatsPtr.numPoolsToFinalize = aggregatedStatsPtr.numPoolsToFinalize.safeAdd(1);

            // Emit an event so keepers know what pools earned rewards this epoch.
            emit StakingPoolEarnedRewardsInEpoch(currentEpoch_, poolId);
        }

        // Credit the fees to the pool.
        poolStatsPtr.feesCollected = feesCollectedByPool.safeAdd(protocolFee);

        // Increase the total fees collected this epoch.
        aggregatedStatsPtr.totalFeesCollected = aggregatedStatsPtr.totalFeesCollected.safeAdd(protocolFee);
    }

    
    
    
    function getStakingPoolStatsThisEpoch(bytes32 poolId)
        external
        view
        returns (IStructs.PoolStats memory)
    {
        return poolStatsByEpoch[poolId][currentEpoch];
    }

    
    ///      epoch.
    
    
    
    
    function _computeMembersAndWeightedStake(
        bytes32 poolId,
        uint256 totalStake
    )
        private
        view
        returns (uint256 membersStake, uint256 weightedStake)
    {
        uint256 operatorStake = getStakeDelegatedToPoolByOwner(
            _poolById[poolId].operator,
            poolId
        ).currentEpochBalance;

        membersStake = totalStake.safeSub(operatorStake);
        weightedStake = operatorStake.safeAdd(
            LibMath.getPartialAmountFloor(
                rewardDelegatedStakeWeight,
                PPM_DENOMINATOR,
                membersStake
            )
        );
        return (membersStake, weightedStake);
    }

    
    ///      valid.
    
    ///        `payProtocolFee.`
    function _assertValidProtocolFee(uint256 protocolFee)
        private
        view
    {
        // The protocol fee must equal the value passed to the contract; unless
        // the value is zero, in which case the fee is taken in WETH.
        if (msg.value != protocolFee && msg.value != 0) {
            LibRichErrors.rrevert(
                LibStakingRichErrors.InvalidProtocolFeePaymentError(
                    protocolFee,
                    msg.value
                )
            );
        }
    }
}
/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;








contract Staking is
    IStaking,
    MixinParams,
    MixinStake,
    MixinExchangeFees
{
    
    ///      This function should not be called directly.
    ///      The StakingProxy contract will call it in `attachStakingContract()`.
    function init()
        public
        onlyAuthorized
    {
        uint256 currentEpoch_ = currentEpoch;
        uint256 prevEpoch = currentEpoch_.safeSub(1);

        // Patch corrupted state
        aggregatedStatsByEpoch[prevEpoch].numPoolsToFinalize = 0;
        this.endEpoch();

        uint256 lastPoolId_ = 57;
        for (uint256 i = 1; i <= lastPoolId_; i++) {
            this.finalizePool(bytes32(i));
        }
        // Ensure that current epoch's state is not corrupted
        aggregatedStatsByEpoch[currentEpoch_].numPoolsToFinalize = 0;
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;


contract IERC20Token {

    // solhint-disable no-simple-event-func-name
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    
    
    
    
    function transfer(address _to, uint256 _value)
        external
        returns (bool);

    
    
    
    
    
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        external
        returns (bool);

    
    
    
    
    function approve(address _spender, uint256 _value)
        external
        returns (bool);

    
    
    function totalSupply()
        external
        view
        returns (uint256);

    
    
    function balanceOf(address _owner)
        external
        view
        returns (uint256);

    
    
    
    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256);
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;









contract TestStaking is
    Staking
{
    address public testWethAddress;
    address public testZrxVaultAddress;

    constructor(
        address wethAddress,
        address zrxVaultAddress
    )
        public
    {
        testWethAddress = wethAddress;
        testZrxVaultAddress = zrxVaultAddress;
    }

    
    
    function setWethContract(address wethAddress)
        external
    {
        testWethAddress = wethAddress;
    }

    
    
    function setZrxVault(address zrxVaultAddress)
        external
    {
        testZrxVaultAddress = zrxVaultAddress;
    }

    // @dev Gets the most recent cumulative reward for a pool, and the epoch it was stored.
    function getMostRecentCumulativeReward(bytes32 poolId)
        external
        view
        returns (IStructs.Fraction memory cumulativeRewards, uint256 lastStoredEpoch)
    {
        lastStoredEpoch = _cumulativeRewardsByPoolLastStored[poolId];
        cumulativeRewards = _cumulativeRewardsByPool[poolId][lastStoredEpoch];
    }

    
    function getWethContract()
        public
        view
        returns (IEtherToken)
    {
        // `testWethAddress` will not be set on the proxy this contract is
        // attached to, so we need to access the storage of the deployed
        // instance of this contract.
        address wethAddress = TestStaking(address(uint160(stakingContract))).testWethAddress();
        return IEtherToken(wethAddress);
    }

    function getZrxVault()
        public
        view
        returns (IZrxVault zrxVault)
    {
        address zrxVaultAddress = TestStaking(address(uint160(stakingContract))).testZrxVaultAddress();
        zrxVault = IZrxVault(zrxVaultAddress);
        return zrxVault;
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;





// solhint-disable no-empty-blocks,no-simple-event-func-name

///      overridden to do nothing.
contract TestStakingNoWETH is
    Staking
{
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    function transfer(address to, uint256 amount)
        external
        returns (bool)
    {
        emit Transfer(address(this), to, amount);
        return true;
    }

    function getWethContract()
        public
        view
        returns (IEtherToken)
    {
        return IEtherToken(address(this));
    }

    function _wrapEth()
        internal
    {}

    function _getAvailableWethBalance()
        internal
        view
        returns (uint256)
    {
        return address(this).balance;
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;




contract IEtherToken is
    IERC20Token
{
    function deposit()
        public
        payable;
    
    function withdraw(uint256 amount)
        public;
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;


interface IStructs {

    
    
    
    
    struct PoolStats {
        uint256 feesCollected;
        uint256 weightedStake;
        uint256 membersStake;
    }

    
    
    ///        being finalized (the previous epoch). This is simply the balance
    ///        of the contract at the end of the epoch.
    
    
    
    
    struct AggregatedStats {
        uint256 rewardsAvailable;
        uint256 numPoolsToFinalize;
        uint256 totalFeesCollected;
        uint256 totalWeightedStake;
        uint256 totalRewardsFinalized;
    }

    
    /// Note that these balances may be stale if the current epoch
    /// is greater than `currentEpoch`.
    
    
    
    struct StoredBalance {
        uint64 currentEpoch;
        uint96 currentEpochBalance;
        uint96 nextEpochBalance;
    }

    
    ///      Any stake can be (re)delegated effective at the next epoch
    ///      Undelegated stake can be withdrawn if it is available in both the current and next epoch
    enum StakeStatus {
        UNDELEGATED,
        DELEGATED
    }

    
    
    
    struct StakeInfo {
        StakeStatus status;
        bytes32 poolId;
    }

    
    
    
    struct Fraction {
        uint256 numerator;
        uint256 denominator;
    }

    
    
    
    struct Pool {
        address operator;
        uint32 operatorShare;
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;


interface IZrxVault {

    
    event StakingProxySet(address stakingProxyAddress);

    
    
    event InCatastrophicFailureMode(address sender);

    
    
    
    event Deposit(
        address indexed staker,
        uint256 amount
    );

    
    
    
    event Withdraw(
        address indexed staker,
        uint256 amount
    );

    
    event ZrxProxySet(address zrxProxyAddress);

    
    /// Note that only the contract staker can call this function.
    
    function setStakingProxy(address _stakingProxyAddress)
        external;

    
    /// *** WARNING - ONCE IN CATOSTROPHIC FAILURE MODE, YOU CAN NEVER GO BACK! ***
    /// Note that only the contract staker can call this function.
    function enterCatastrophicFailure()
        external;

    
    /// Note that only the contract staker can call this.
    /// Note that this can only be called when *not* in Catastrophic Failure mode.
    
    function setZrxProxy(address zrxProxyAddress)
        external;

    
    /// Note that only the Staking contract can call this.
    /// Note that this can only be called when *not* in Catastrophic Failure mode.
    
    
    function depositFrom(address staker, uint256 amount)
        external;

    
    /// Note that only the Staking contract can call this.
    /// Note that this can only be called when *not* in Catastrophic Failure mode.
    
    
    function withdrawFrom(address staker, uint256 amount)
        external;

    
    /// Note that this can only be called when *in* Catastrophic Failure mode.
    
    function withdrawAllFrom(address staker)
        external
        returns (uint256);

    
    
    function balanceOf(address staker)
        external
        view
        returns (uint256);

    
    function balanceOfZrxVault()
        external
        view
        returns (uint256);
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;


library LibRichErrors {

    // bytes4(keccak256("Error(string)"))
    bytes4 internal constant STANDARD_ERROR_SELECTOR =
        0x08c379a0;

    // solhint-disable func-name-mixedcase
    
    ///      This is the same payload that would be included by a `revert(string)`
    ///      solidity statement. It has the function signature `Error(string)`.
    
    
    function StandardError(
        string memory message
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            STANDARD_ERROR_SELECTOR,
            bytes(message)
        );
    }
    // solhint-enable func-name-mixedcase

    
    
    function rrevert(bytes memory errorData)
        internal
        pure
    {
        assembly {
            revert(add(errorData, 0x20), mload(errorData))
        }
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;


library LibAuthorizableRichErrors {

    // bytes4(keccak256("AuthorizedAddressMismatchError(address,address)"))
    bytes4 internal constant AUTHORIZED_ADDRESS_MISMATCH_ERROR_SELECTOR =
        0x140a84db;

    // bytes4(keccak256("IndexOutOfBoundsError(uint256,uint256)"))
    bytes4 internal constant INDEX_OUT_OF_BOUNDS_ERROR_SELECTOR =
        0xe9f83771;

    // bytes4(keccak256("SenderNotAuthorizedError(address)"))
    bytes4 internal constant SENDER_NOT_AUTHORIZED_ERROR_SELECTOR =
        0xb65a25b9;

    // bytes4(keccak256("TargetAlreadyAuthorizedError(address)"))
    bytes4 internal constant TARGET_ALREADY_AUTHORIZED_ERROR_SELECTOR =
        0xde16f1a0;

    // bytes4(keccak256("TargetNotAuthorizedError(address)"))
    bytes4 internal constant TARGET_NOT_AUTHORIZED_ERROR_SELECTOR =
        0xeb5108a2;

    // bytes4(keccak256("ZeroCantBeAuthorizedError()"))
    bytes internal constant ZERO_CANT_BE_AUTHORIZED_ERROR_BYTES =
        hex"57654fe4";

    // solhint-disable func-name-mixedcase
    function AuthorizedAddressMismatchError(
        address authorized,
        address target
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            AUTHORIZED_ADDRESS_MISMATCH_ERROR_SELECTOR,
            authorized,
            target
        );
    }

    function IndexOutOfBoundsError(
        uint256 index,
        uint256 length
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            INDEX_OUT_OF_BOUNDS_ERROR_SELECTOR,
            index,
            length
        );
    }

    function SenderNotAuthorizedError(address sender)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            SENDER_NOT_AUTHORIZED_ERROR_SELECTOR,
            sender
        );
    }

    function TargetAlreadyAuthorizedError(address target)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            TARGET_ALREADY_AUTHORIZED_ERROR_SELECTOR,
            target
        );
    }

    function TargetNotAuthorizedError(address target)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            TARGET_NOT_AUTHORIZED_ERROR_SELECTOR,
            target
        );
    }

    function ZeroCantBeAuthorizedError()
        internal
        pure
        returns (bytes memory)
    {
        return ZERO_CANT_BE_AUTHORIZED_ERROR_BYTES;
    }
}

pragma solidity ^0.5.9;


library LibOwnableRichErrors {

    // bytes4(keccak256("OnlyOwnerError(address,address)"))
    bytes4 internal constant ONLY_OWNER_ERROR_SELECTOR =
        0x1de45ad1;

    // bytes4(keccak256("TransferOwnerToZeroError()"))
    bytes internal constant TRANSFER_OWNER_TO_ZERO_ERROR_BYTES =
        hex"e69edc3e";

    // solhint-disable func-name-mixedcase
    function OnlyOwnerError(
        address sender,
        address owner
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            ONLY_OWNER_ERROR_SELECTOR,
            sender,
            owner
        );
    }

    function TransferOwnerToZeroError()
        internal
        pure
        returns (bytes memory)
    {
        return TRANSFER_OWNER_TO_ZERO_ERROR_BYTES;
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;





library LibStakingRichErrors {

    enum OperatorShareErrorCodes {
        OperatorShareTooLarge,
        CanOnlyDecreaseOperatorShare
    }

    enum InitializationErrorCodes {
        MixinSchedulerAlreadyInitialized,
        MixinParamsAlreadyInitialized
    }

    enum InvalidParamValueErrorCodes {
        InvalidCobbDouglasAlpha,
        InvalidRewardDelegatedStakeWeight,
        InvalidMaximumMakersInPool,
        InvalidMinimumPoolStake,
        InvalidEpochDuration
    }

    enum ExchangeManagerErrorCodes {
        ExchangeAlreadyRegistered,
        ExchangeNotRegistered
    }

    // bytes4(keccak256("OnlyCallableByExchangeError(address)"))
    bytes4 internal constant ONLY_CALLABLE_BY_EXCHANGE_ERROR_SELECTOR =
        0xb56d2df0;

    // bytes4(keccak256("ExchangeManagerError(uint8,address)"))
    bytes4 internal constant EXCHANGE_MANAGER_ERROR_SELECTOR =
        0xb9588e43;

    // bytes4(keccak256("InsufficientBalanceError(uint256,uint256)"))
    bytes4 internal constant INSUFFICIENT_BALANCE_ERROR_SELECTOR =
        0x84c8b7c9;

    // bytes4(keccak256("OnlyCallableByPoolOperatorError(address,bytes32)"))
    bytes4 internal constant ONLY_CALLABLE_BY_POOL_OPERATOR_ERROR_SELECTOR =
        0x82ded785;

    // bytes4(keccak256("BlockTimestampTooLowError(uint256,uint256)"))
    bytes4 internal constant BLOCK_TIMESTAMP_TOO_LOW_ERROR_SELECTOR =
        0xa6bcde47;

    // bytes4(keccak256("OnlyCallableByStakingContractError(address)"))
    bytes4 internal constant ONLY_CALLABLE_BY_STAKING_CONTRACT_ERROR_SELECTOR =
        0xca1d07a2;

    // bytes4(keccak256("OnlyCallableIfInCatastrophicFailureError()"))
    bytes internal constant ONLY_CALLABLE_IF_IN_CATASTROPHIC_FAILURE_ERROR =
        hex"3ef081cc";

    // bytes4(keccak256("OnlyCallableIfNotInCatastrophicFailureError()"))
    bytes internal constant ONLY_CALLABLE_IF_NOT_IN_CATASTROPHIC_FAILURE_ERROR =
        hex"7dd020ce";

    // bytes4(keccak256("OperatorShareError(uint8,bytes32,uint32)"))
    bytes4 internal constant OPERATOR_SHARE_ERROR_SELECTOR =
        0x22df9597;

    // bytes4(keccak256("PoolExistenceError(bytes32,bool)"))
    bytes4 internal constant POOL_EXISTENCE_ERROR_SELECTOR =
        0x9ae94f01;

    // bytes4(keccak256("ProxyDestinationCannotBeNilError()"))
    bytes internal constant PROXY_DESTINATION_CANNOT_BE_NIL_ERROR =
        hex"6eff8285";

    // bytes4(keccak256("InitializationError(uint8)"))
    bytes4 internal constant INITIALIZATION_ERROR_SELECTOR =
        0x0b02d773;

    // bytes4(keccak256("InvalidParamValueError(uint8)"))
    bytes4 internal constant INVALID_PARAM_VALUE_ERROR_SELECTOR =
        0xfc45bd11;

    // bytes4(keccak256("InvalidProtocolFeePaymentError(uint256,uint256)"))
    bytes4 internal constant INVALID_PROTOCOL_FEE_PAYMENT_ERROR_SELECTOR =
        0x31d7a505;

    // bytes4(keccak256("PreviousEpochNotFinalizedError(uint256,uint256)"))
    bytes4 internal constant PREVIOUS_EPOCH_NOT_FINALIZED_ERROR_SELECTOR =
        0x614b800a;

    // bytes4(keccak256("PoolNotFinalizedError(bytes32,uint256)"))
    bytes4 internal constant POOL_NOT_FINALIZED_ERROR_SELECTOR =
        0x5caa0b05;

    // solhint-disable func-name-mixedcase
    function OnlyCallableByExchangeError(
        address senderAddress
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            ONLY_CALLABLE_BY_EXCHANGE_ERROR_SELECTOR,
            senderAddress
        );
    }

    function ExchangeManagerError(
        ExchangeManagerErrorCodes errorCodes,
        address exchangeAddress
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            EXCHANGE_MANAGER_ERROR_SELECTOR,
            errorCodes,
            exchangeAddress
        );
    }

    function InsufficientBalanceError(
        uint256 amount,
        uint256 balance
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            INSUFFICIENT_BALANCE_ERROR_SELECTOR,
            amount,
            balance
        );
    }

    function OnlyCallableByPoolOperatorError(
        address senderAddress,
        bytes32 poolId
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            ONLY_CALLABLE_BY_POOL_OPERATOR_ERROR_SELECTOR,
            senderAddress,
            poolId
        );
    }

    function BlockTimestampTooLowError(
        uint256 epochEndTime,
        uint256 currentBlockTimestamp
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            BLOCK_TIMESTAMP_TOO_LOW_ERROR_SELECTOR,
            epochEndTime,
            currentBlockTimestamp
        );
    }

    function OnlyCallableByStakingContractError(
        address senderAddress
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            ONLY_CALLABLE_BY_STAKING_CONTRACT_ERROR_SELECTOR,
            senderAddress
        );
    }

    function OnlyCallableIfInCatastrophicFailureError()
        internal
        pure
        returns (bytes memory)
    {
        return ONLY_CALLABLE_IF_IN_CATASTROPHIC_FAILURE_ERROR;
    }

    function OnlyCallableIfNotInCatastrophicFailureError()
        internal
        pure
        returns (bytes memory)
    {
        return ONLY_CALLABLE_IF_NOT_IN_CATASTROPHIC_FAILURE_ERROR;
    }

    function OperatorShareError(
        OperatorShareErrorCodes errorCodes,
        bytes32 poolId,
        uint32 operatorShare
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            OPERATOR_SHARE_ERROR_SELECTOR,
            errorCodes,
            poolId,
            operatorShare
        );
    }

    function PoolExistenceError(
        bytes32 poolId,
        bool alreadyExists
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            POOL_EXISTENCE_ERROR_SELECTOR,
            poolId,
            alreadyExists
        );
    }

    function InvalidProtocolFeePaymentError(
        uint256 expectedProtocolFeePaid,
        uint256 actualProtocolFeePaid
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            INVALID_PROTOCOL_FEE_PAYMENT_ERROR_SELECTOR,
            expectedProtocolFeePaid,
            actualProtocolFeePaid
        );
    }

    function InitializationError(InitializationErrorCodes code)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            INITIALIZATION_ERROR_SELECTOR,
            uint8(code)
        );
    }

    function InvalidParamValueError(InvalidParamValueErrorCodes code)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            INVALID_PARAM_VALUE_ERROR_SELECTOR,
            uint8(code)
        );
    }

    function ProxyDestinationCannotBeNilError()
        internal
        pure
        returns (bytes memory)
    {
        return PROXY_DESTINATION_CANNOT_BE_NIL_ERROR;
    }

    function PreviousEpochNotFinalizedError(
        uint256 unfinalizedEpoch,
        uint256 unfinalizedPoolsRemaining
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            PREVIOUS_EPOCH_NOT_FINALIZED_ERROR_SELECTOR,
            unfinalizedEpoch,
            unfinalizedPoolsRemaining
        );
    }

    function PoolNotFinalizedError(
        bytes32 poolId,
        uint256 epoch
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            POOL_NOT_FINALIZED_ERROR_SELECTOR,
            poolId,
            epoch
        );
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;





contract IStakingProxy {

    
    
    event StakingContractAttachedToProxy(
        address newStakingContractAddress
    );

    
    event StakingContractDetachedFromProxy();

    
    /// Note that this is callable only by an authorized address.
    
    function attachStakingContract(address _stakingContract)
        external;

    
    /// Note that this is callable only by an authorized address.
    function detachStakingContract()
        external;

    
    //       Asserts that 0 < cobb douglas alpha value <= 1.
    //       Asserts that a stake weight is <= 100%.
    //       Asserts that pools allow >= 1 maker.
    //       Asserts that all addresses are initialized.
    function assertValidStorageParams()
        external
        view;
}

pragma solidity ^0.5.9;





library LibSafeMath {

    function safeMul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        if (c / a != b) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.MULTIPLICATION_OVERFLOW,
                a,
                b
            ));
        }
        return c;
    }

    function safeDiv(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        if (b == 0) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.DIVISION_BY_ZERO,
                a,
                b
            ));
        }
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        if (b > a) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.SUBTRACTION_UNDERFLOW,
                a,
                b
            ));
        }
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = a + b;
        if (c < a) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.ADDITION_OVERFLOW,
                a,
                b
            ));
        }
        return c;
    }

    function max256(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a < b ? a : b;
    }
}

pragma solidity ^0.5.9;


library LibSafeMathRichErrors {

    // bytes4(keccak256("Uint256BinOpError(uint8,uint256,uint256)"))
    bytes4 internal constant UINT256_BINOP_ERROR_SELECTOR =
        0xe946c1bb;

    // bytes4(keccak256("Uint256DowncastError(uint8,uint256)"))
    bytes4 internal constant UINT256_DOWNCAST_ERROR_SELECTOR =
        0xc996af7b;

    enum BinOpErrorCodes {
        ADDITION_OVERFLOW,
        MULTIPLICATION_OVERFLOW,
        SUBTRACTION_UNDERFLOW,
        DIVISION_BY_ZERO
    }

    enum DowncastErrorCodes {
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT32,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT64,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT96
    }

    // solhint-disable func-name-mixedcase
    function Uint256BinOpError(
        BinOpErrorCodes errorCode,
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            UINT256_BINOP_ERROR_SELECTOR,
            errorCode,
            a,
            b
        );
    }

    function Uint256DowncastError(
        DowncastErrorCodes errorCode,
        uint256 a
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            UINT256_DOWNCAST_ERROR_SELECTOR,
            errorCode,
            a
        );
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;






library LibMath {

    using LibSafeMath for uint256;

    
    ///      Reverts if rounding error is >= 0.1%
    
    
    
    
    function safeGetPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {
        if (isRoundingErrorFloor(
                numerator,
                denominator,
                target
        )) {
            LibRichErrors.rrevert(LibMathRichErrors.RoundingError(
                numerator,
                denominator,
                target
            ));
        }

        partialAmount = numerator.safeMul(target).safeDiv(denominator);
        return partialAmount;
    }

    
    ///      Reverts if rounding error is >= 0.1%
    
    
    
    
    function safeGetPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {
        if (isRoundingErrorCeil(
                numerator,
                denominator,
                target
        )) {
            LibRichErrors.rrevert(LibMathRichErrors.RoundingError(
                numerator,
                denominator,
                target
            ));
        }

        // safeDiv computes `floor(a / b)`. We use the identity (a, b integer):
        //       ceil(a / b) = floor((a + b - 1) / b)
        // To implement `ceil(a / b)` using safeDiv.
        partialAmount = numerator.safeMul(target)
            .safeAdd(denominator.safeSub(1))
            .safeDiv(denominator);

        return partialAmount;
    }

    
    
    
    
    
    function getPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {
        partialAmount = numerator.safeMul(target).safeDiv(denominator);
        return partialAmount;
    }

    
    
    
    
    
    function getPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {
        // safeDiv computes `floor(a / b)`. We use the identity (a, b integer):
        //       ceil(a / b) = floor((a + b - 1) / b)
        // To implement `ceil(a / b)` using safeDiv.
        partialAmount = numerator.safeMul(target)
            .safeAdd(denominator.safeSub(1))
            .safeDiv(denominator);

        return partialAmount;
    }

    
    
    
    
    
    function isRoundingErrorFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bool isError)
    {
        if (denominator == 0) {
            LibRichErrors.rrevert(LibMathRichErrors.DivisionByZeroError());
        }

        // The absolute rounding error is the difference between the rounded
        // value and the ideal value. The relative rounding error is the
        // absolute rounding error divided by the absolute value of the
        // ideal value. This is undefined when the ideal value is zero.
        //
        // The ideal value is `numerator * target / denominator`.
        // Let's call `numerator * target % denominator` the remainder.
        // The absolute error is `remainder / denominator`.
        //
        // When the ideal value is zero, we require the absolute error to
        // be zero. Fortunately, this is always the case. The ideal value is
        // zero iff `numerator == 0` and/or `target == 0`. In this case the
        // remainder and absolute error are also zero.
        if (target == 0 || numerator == 0) {
            return false;
        }

        // Otherwise, we want the relative rounding error to be strictly
        // less than 0.1%.
        // The relative error is `remainder / (numerator * target)`.
        // We want the relative error less than 1 / 1000:
        //        remainder / (numerator * denominator)  <  1 / 1000
        // or equivalently:
        //        1000 * remainder  <  numerator * target
        // so we have a rounding error iff:
        //        1000 * remainder  >=  numerator * target
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        isError = remainder.safeMul(1000) >= numerator.safeMul(target);
        return isError;
    }

    
    
    
    
    
    function isRoundingErrorCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bool isError)
    {
        if (denominator == 0) {
            LibRichErrors.rrevert(LibMathRichErrors.DivisionByZeroError());
        }

        // See the comments in `isRoundingError`.
        if (target == 0 || numerator == 0) {
            // When either is zero, the ideal value and rounded value are zero
            // and there is no rounding error. (Although the relative error
            // is undefined.)
            return false;
        }
        // Compute remainder as before
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        remainder = denominator.safeSub(remainder) % denominator;
        isError = remainder.safeMul(1000) >= numerator.safeMul(target);
        return isError;
    }
}

pragma solidity ^0.5.9;


library LibMathRichErrors {

    // bytes4(keccak256("DivisionByZeroError()"))
    bytes internal constant DIVISION_BY_ZERO_ERROR =
        hex"a791837c";

    // bytes4(keccak256("RoundingError(uint256,uint256,uint256)"))
    bytes4 internal constant ROUNDING_ERROR_SELECTOR =
        0x339f3de2;

    // solhint-disable func-name-mixedcase
    function DivisionByZeroError()
        internal
        pure
        returns (bytes memory)
    {
        return DIVISION_BY_ZERO_ERROR;
    }

    function RoundingError(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            ROUNDING_ERROR_SELECTOR,
            numerator,
            denominator,
            target
        );
    }
}

pragma solidity ^0.5.9;




library LibFractions {

    using LibSafeMath for uint256;

    
    
    
    
    
    
    
    function add(
        uint256 n1,
        uint256 d1,
        uint256 n2,
        uint256 d2
    )
        internal
        pure
        returns (
            uint256 numerator,
            uint256 denominator
        )
    {
        if (n1 == 0) {
            return (numerator = n2, denominator = d2);
        }
        if (n2 == 0) {
            return (numerator = n1, denominator = d1);
        }
        numerator = n1
            .safeMul(d2)
            .safeAdd(n2.safeMul(d1));
        denominator = d1.safeMul(d2);
        return (numerator, denominator);
    }

    
    ///      the numerator or the denominator are > `maxValue`.
    
    
    
    ///        denominator.
    
    
    function normalize(
        uint256 numerator,
        uint256 denominator,
        uint256 maxValue
    )
        internal
        pure
        returns (
            uint256 scaledNumerator,
            uint256 scaledDenominator
        )
    {
        // If either the numerator or the denominator are > `maxValue`,
        // re-scale them by `maxValue` to prevent overflows in future operations.
        if (numerator > maxValue || denominator > maxValue) {
            uint256 rescaleBase = numerator >= denominator ? numerator : denominator;
            rescaleBase = rescaleBase.safeDiv(maxValue);
            scaledNumerator = numerator.safeDiv(rescaleBase);
            scaledDenominator = denominator.safeDiv(rescaleBase);
        } else {
            scaledNumerator = numerator;
            scaledDenominator = denominator;
        }
        return (scaledNumerator, scaledDenominator);
    }

    
    ///      the numerator or the denominator are > 2 ** 127.
    
    
    
    
    function normalize(
        uint256 numerator,
        uint256 denominator
    )
        internal
        pure
        returns (
            uint256 scaledNumerator,
            uint256 scaledDenominator
        )
    {
        return normalize(numerator, denominator, 2 ** 127);
    }

    
    
    
    
    
    
    
    function scaleDifference(
        uint256 n1,
        uint256 d1,
        uint256 n2,
        uint256 d2,
        uint256 s
    )
        internal
        pure
        returns (uint256 result)
    {
        if (s == 0) {
            return 0;
        }
        if (n2 == 0) {
            return result = s
                .safeMul(n1)
                .safeDiv(d1);
        }
        uint256 numerator = n1
            .safeMul(d2)
            .safeSub(n2.safeMul(d1));
        uint256 tmp = numerator.safeDiv(d2);
        return s
            .safeMul(tmp)
            .safeDiv(d1);
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;





library LibSafeDowncast {

    
    /// Note that this reverts if the input value is too large.
    function downcastToUint96(uint256 a)
        internal
        pure
        returns (uint96 b)
    {
        b = uint96(a);
        if (uint256(b) != a) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256DowncastError(
                LibSafeMathRichErrors.DowncastErrorCodes.VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT96,
                a
            ));
        }
        return b;
    }

    
    /// Note that this reverts if the input value is too large.
    function downcastToUint64(uint256 a)
        internal
        pure
        returns (uint64 b)
    {
        b = uint64(a);
        if (uint256(b) != a) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256DowncastError(
                LibSafeMathRichErrors.DowncastErrorCodes.VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT64,
                a
            ));
        }
        return b;
    }

    
    /// Note that this reverts if the input value is too large.
    function downcastToUint32(uint256 a)
        internal
        pure
        returns (uint32 b)
    {
        b = uint32(a);
        if (uint256(b) != a) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256DowncastError(
                LibSafeMathRichErrors.DowncastErrorCodes.VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT32,
                a
            ));
        }
        return b;
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;





library LibCobbDouglas {

    
    ///      staking pools in a given epoch. This function does not perform
    ///      bounds checking on the inputs, but the following conditions
    ///      need to be true:
    ///         0 <= fees / totalFees <= 1
    ///         0 <= stake / totalStake <= 1
    ///         0 <= alphaNumerator / alphaDenominator <= 1
    
    
    
    
    
    
    
    ///        function.
    
    function cobbDouglas(
        uint256 totalRewards,
        uint256 fees,
        uint256 totalFees,
        uint256 stake,
        uint256 totalStake,
        uint32 alphaNumerator,
        uint32 alphaDenominator
    )
        internal
        pure
        returns (uint256 rewards)
    {
        int256 feeRatio = LibFixedMath.toFixed(fees, totalFees);
        int256 stakeRatio = LibFixedMath.toFixed(stake, totalStake);
        if (feeRatio == 0 || stakeRatio == 0) {
            return rewards = 0;
        }
        // The cobb-doublas function has the form:
        // `totalRewards * feeRatio ^ alpha * stakeRatio ^ (1-alpha)`
        // This is equivalent to:
        // `totalRewards * stakeRatio * e^(alpha * (ln(feeRatio / stakeRatio)))`
        // However, because `ln(x)` has the domain of `0 < x < 1`
        // and `exp(x)` has the domain of `x < 0`,
        // and fixed-point math easily overflows with multiplication,
        // we will choose the following if `stakeRatio > feeRatio`:
        // `totalRewards * stakeRatio / e^(alpha * (ln(stakeRatio / feeRatio)))`

        // Compute
        // `e^(alpha * ln(feeRatio/stakeRatio))` if feeRatio <= stakeRatio
        // or
        // `e^(alpa * ln(stakeRatio/feeRatio))` if feeRatio > stakeRatio
        int256 n = feeRatio <= stakeRatio ?
            LibFixedMath.div(feeRatio, stakeRatio) :
            LibFixedMath.div(stakeRatio, feeRatio);
        n = LibFixedMath.exp(
            LibFixedMath.mulDiv(
                LibFixedMath.ln(n),
                int256(alphaNumerator),
                int256(alphaDenominator)
            )
        );
        // Compute
        // `totalRewards * n` if feeRatio <= stakeRatio
        // or
        // `totalRewards / n` if stakeRatio > feeRatio
        // depending on the choice we made earlier.
        n = feeRatio <= stakeRatio ?
            LibFixedMath.mul(stakeRatio, n) :
            LibFixedMath.div(stakeRatio, n);
        // Multiply the above with totalRewards.
        rewards = LibFixedMath.uintMul(n, totalRewards);
    }
}

/*

  Copyright 2017 Bprotocol Foundation, 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;




// solhint-disable indent

library LibFixedMath {

    // 1
    int256 private constant FIXED_1 = int256(0x0000000000000000000000000000000080000000000000000000000000000000);
    // 2**255
    int256 private constant MIN_FIXED_VAL = int256(0x8000000000000000000000000000000000000000000000000000000000000000);
    // 1^2 (in fixed-point)
    int256 private constant FIXED_1_SQUARED = int256(0x4000000000000000000000000000000000000000000000000000000000000000);
    // 1
    int256 private constant LN_MAX_VAL = FIXED_1;
    // e ^ -63.875
    int256 private constant LN_MIN_VAL = int256(0x0000000000000000000000000000000000000000000000000000000733048c5a);
    // 0
    int256 private constant EXP_MAX_VAL = 0;
    // -63.875
    int256 private constant EXP_MIN_VAL = -int256(0x0000000000000000000000000000001ff0000000000000000000000000000000);

    
    function one() internal pure returns (int256 f) {
        f = FIXED_1;
    }

    
    function add(int256 a, int256 b) internal pure returns (int256 c) {
        c = _add(a, b);
    }

    
    function sub(int256 a, int256 b) internal pure returns (int256 c) {
        if (b == MIN_FIXED_VAL) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.SignedValueError(
                LibFixedMathRichErrors.ValueErrorCodes.TOO_SMALL,
                b
            ));
        }
        c = _add(a, -b);
    }

    
    function mul(int256 a, int256 b) internal pure returns (int256 c) {
        c = _mul(a, b) / FIXED_1;
    }

    
    function div(int256 a, int256 b) internal pure returns (int256 c) {
        c = _div(_mul(a, FIXED_1), b);
    }

    
    function mulDiv(int256 a, int256 n, int256 d) internal pure returns (int256 c) {
        c = _div(_mul(a, n), d);
    }

    
    ///      number with an integer, reverting if the multiplication overflows.
    ///      Negative results are clamped to zero.
    function uintMul(int256 f, uint256 u) internal pure returns (uint256) {
        if (int256(u) < int256(0)) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.UnsignedValueError(
                LibFixedMathRichErrors.ValueErrorCodes.TOO_LARGE,
                u
            ));
        }
        int256 c = _mul(f, int256(u));
        if (c <= 0) {
            return 0;
        }
        return uint256(uint256(c) >> 127);
    }

    
    function abs(int256 f) internal pure returns (int256 c) {
        if (f == MIN_FIXED_VAL) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.SignedValueError(
                LibFixedMathRichErrors.ValueErrorCodes.TOO_SMALL,
                f
            ));
        }
        if (f >= 0) {
            c = f;
        } else {
            c = -f;
        }
    }

    
    function invert(int256 f) internal pure returns (int256 c) {
        c = _div(FIXED_1_SQUARED, f);
    }

    
    function toFixed(int256 n) internal pure returns (int256 f) {
        f = _mul(n, FIXED_1);
    }

    
    function toFixed(int256 n, int256 d) internal pure returns (int256 f) {
        f = _div(_mul(n, FIXED_1), d);
    }

    
    ///      Reverts if `n` is too large to fit in a fixed-point number.
    function toFixed(uint256 n) internal pure returns (int256 f) {
        if (int256(n) < int256(0)) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.UnsignedValueError(
                LibFixedMathRichErrors.ValueErrorCodes.TOO_LARGE,
                n
            ));
        }
        f = _mul(int256(n), FIXED_1);
    }

    
    ///      Reverts if `n` / `d` is too large to fit in a fixed-point number.
    function toFixed(uint256 n, uint256 d) internal pure returns (int256 f) {
        if (int256(n) < int256(0)) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.UnsignedValueError(
                LibFixedMathRichErrors.ValueErrorCodes.TOO_LARGE,
                n
            ));
        }
        if (int256(d) < int256(0)) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.UnsignedValueError(
                LibFixedMathRichErrors.ValueErrorCodes.TOO_LARGE,
                d
            ));
        }
        f = _div(_mul(int256(n), FIXED_1), int256(d));
    }

    
    function toInteger(int256 f) internal pure returns (int256 n) {
        return f / FIXED_1;
    }

    
    function ln(int256 x) internal pure returns (int256 r) {
        if (x > LN_MAX_VAL) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.SignedValueError(
                LibFixedMathRichErrors.ValueErrorCodes.TOO_LARGE,
                x
            ));
        }
        if (x <= 0) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.SignedValueError(
                LibFixedMathRichErrors.ValueErrorCodes.TOO_SMALL,
                x
            ));
        }
        if (x == FIXED_1) {
            return 0;
        }
        if (x <= LN_MIN_VAL) {
            return EXP_MIN_VAL;
        }

        int256 y;
        int256 z;
        int256 w;

        // Rewrite the input as a quotient of negative natural exponents and a single residual q, such that 1 < q < 2
        // For example: log(0.3) = log(e^-1 * e^-0.25 * 1.0471028872385522)
        //              = 1 - 0.25 - log(1 + 0.0471028872385522)
        // e ^ -32
        if (x <= int256(0x00000000000000000000000000000000000000000001c8464f76164760000000)) {
            r -= int256(0x0000000000000000000000000000001000000000000000000000000000000000); // - 32
            x = x * FIXED_1 / int256(0x00000000000000000000000000000000000000000001c8464f76164760000000); // / e ^ -32
        }
        // e ^ -16
        if (x <= int256(0x00000000000000000000000000000000000000f1aaddd7742e90000000000000)) {
            r -= int256(0x0000000000000000000000000000000800000000000000000000000000000000); // - 16
            x = x * FIXED_1 / int256(0x00000000000000000000000000000000000000f1aaddd7742e90000000000000); // / e ^ -16
        }
        // e ^ -8
        if (x <= int256(0x00000000000000000000000000000000000afe10820813d78000000000000000)) {
            r -= int256(0x0000000000000000000000000000000400000000000000000000000000000000); // - 8
            x = x * FIXED_1 / int256(0x00000000000000000000000000000000000afe10820813d78000000000000000); // / e ^ -8
        }
        // e ^ -4
        if (x <= int256(0x0000000000000000000000000000000002582ab704279ec00000000000000000)) {
            r -= int256(0x0000000000000000000000000000000200000000000000000000000000000000); // - 4
            x = x * FIXED_1 / int256(0x0000000000000000000000000000000002582ab704279ec00000000000000000); // / e ^ -4
        }
        // e ^ -2
        if (x <= int256(0x000000000000000000000000000000001152aaa3bf81cc000000000000000000)) {
            r -= int256(0x0000000000000000000000000000000100000000000000000000000000000000); // - 2
            x = x * FIXED_1 / int256(0x000000000000000000000000000000001152aaa3bf81cc000000000000000000); // / e ^ -2
        }
        // e ^ -1
        if (x <= int256(0x000000000000000000000000000000002f16ac6c59de70000000000000000000)) {
            r -= int256(0x0000000000000000000000000000000080000000000000000000000000000000); // - 1
            x = x * FIXED_1 / int256(0x000000000000000000000000000000002f16ac6c59de70000000000000000000); // / e ^ -1
        }
        // e ^ -0.5
        if (x <= int256(0x000000000000000000000000000000004da2cbf1be5828000000000000000000)) {
            r -= int256(0x0000000000000000000000000000000040000000000000000000000000000000); // - 0.5
            x = x * FIXED_1 / int256(0x000000000000000000000000000000004da2cbf1be5828000000000000000000); // / e ^ -0.5
        }
        // e ^ -0.25
        if (x <= int256(0x0000000000000000000000000000000063afbe7ab2082c000000000000000000)) {
            r -= int256(0x0000000000000000000000000000000020000000000000000000000000000000); // - 0.25
            x = x * FIXED_1 / int256(0x0000000000000000000000000000000063afbe7ab2082c000000000000000000); // / e ^ -0.25
        }
        // e ^ -0.125
        if (x <= int256(0x0000000000000000000000000000000070f5a893b608861e1f58934f97aea57d)) {
            r -= int256(0x0000000000000000000000000000000010000000000000000000000000000000); // - 0.125
            x = x * FIXED_1 / int256(0x0000000000000000000000000000000070f5a893b608861e1f58934f97aea57d); // / e ^ -0.125
        }
        // `x` is now our residual in the range of 1 <= x <= 2 (or close enough).

        // Add the taylor series for log(1 + z), where z = x - 1
        z = y = x - FIXED_1;
        w = y * y / FIXED_1;
        r += z * (0x100000000000000000000000000000000 - y) / 0x100000000000000000000000000000000; z = z * w / FIXED_1; // add y^01 / 01 - y^02 / 02
        r += z * (0x0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa - y) / 0x200000000000000000000000000000000; z = z * w / FIXED_1; // add y^03 / 03 - y^04 / 04
        r += z * (0x099999999999999999999999999999999 - y) / 0x300000000000000000000000000000000; z = z * w / FIXED_1; // add y^05 / 05 - y^06 / 06
        r += z * (0x092492492492492492492492492492492 - y) / 0x400000000000000000000000000000000; z = z * w / FIXED_1; // add y^07 / 07 - y^08 / 08
        r += z * (0x08e38e38e38e38e38e38e38e38e38e38e - y) / 0x500000000000000000000000000000000; z = z * w / FIXED_1; // add y^09 / 09 - y^10 / 10
        r += z * (0x08ba2e8ba2e8ba2e8ba2e8ba2e8ba2e8b - y) / 0x600000000000000000000000000000000; z = z * w / FIXED_1; // add y^11 / 11 - y^12 / 12
        r += z * (0x089d89d89d89d89d89d89d89d89d89d89 - y) / 0x700000000000000000000000000000000; z = z * w / FIXED_1; // add y^13 / 13 - y^14 / 14
        r += z * (0x088888888888888888888888888888888 - y) / 0x800000000000000000000000000000000;                      // add y^15 / 15 - y^16 / 16
    }

    
    function exp(int256 x) internal pure returns (int256 r) {
        if (x < EXP_MIN_VAL) {
            // Saturate to zero below EXP_MIN_VAL.
            return 0;
        }
        if (x == 0) {
            return FIXED_1;
        }
        if (x > EXP_MAX_VAL) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.SignedValueError(
                LibFixedMathRichErrors.ValueErrorCodes.TOO_LARGE,
                x
            ));
        }

        // Rewrite the input as a product of natural exponents and a
        // single residual q, where q is a number of small magnitude.
        // For example: e^-34.419 = e^(-32 - 2 - 0.25 - 0.125 - 0.044)
        //              = e^-32 * e^-2 * e^-0.25 * e^-0.125 * e^-0.044
        //              -> q = -0.044

        // Multiply with the taylor series for e^q
        int256 y;
        int256 z;
        // q = x % 0.125 (the residual)
        z = y = x % 0x0000000000000000000000000000000010000000000000000000000000000000;
        z = z * y / FIXED_1; r += z * 0x10e1b3be415a0000; // add y^02 * (20! / 02!)
        z = z * y / FIXED_1; r += z * 0x05a0913f6b1e0000; // add y^03 * (20! / 03!)
        z = z * y / FIXED_1; r += z * 0x0168244fdac78000; // add y^04 * (20! / 04!)
        z = z * y / FIXED_1; r += z * 0x004807432bc18000; // add y^05 * (20! / 05!)
        z = z * y / FIXED_1; r += z * 0x000c0135dca04000; // add y^06 * (20! / 06!)
        z = z * y / FIXED_1; r += z * 0x0001b707b1cdc000; // add y^07 * (20! / 07!)
        z = z * y / FIXED_1; r += z * 0x000036e0f639b800; // add y^08 * (20! / 08!)
        z = z * y / FIXED_1; r += z * 0x00000618fee9f800; // add y^09 * (20! / 09!)
        z = z * y / FIXED_1; r += z * 0x0000009c197dcc00; // add y^10 * (20! / 10!)
        z = z * y / FIXED_1; r += z * 0x0000000e30dce400; // add y^11 * (20! / 11!)
        z = z * y / FIXED_1; r += z * 0x000000012ebd1300; // add y^12 * (20! / 12!)
        z = z * y / FIXED_1; r += z * 0x0000000017499f00; // add y^13 * (20! / 13!)
        z = z * y / FIXED_1; r += z * 0x0000000001a9d480; // add y^14 * (20! / 14!)
        z = z * y / FIXED_1; r += z * 0x00000000001c6380; // add y^15 * (20! / 15!)
        z = z * y / FIXED_1; r += z * 0x000000000001c638; // add y^16 * (20! / 16!)
        z = z * y / FIXED_1; r += z * 0x0000000000001ab8; // add y^17 * (20! / 17!)
        z = z * y / FIXED_1; r += z * 0x000000000000017c; // add y^18 * (20! / 18!)
        z = z * y / FIXED_1; r += z * 0x0000000000000014; // add y^19 * (20! / 19!)
        z = z * y / FIXED_1; r += z * 0x0000000000000001; // add y^20 * (20! / 20!)
        r = r / 0x21c3677c82b40000 + y + FIXED_1; // divide by 20! and then add y^1 / 1! + y^0 / 0!

        // Multiply with the non-residual terms.
        x = -x;
        // e ^ -32
        if ((x & int256(0x0000000000000000000000000000001000000000000000000000000000000000)) != 0) {
            r = r * int256(0x00000000000000000000000000000000000000f1aaddd7742e56d32fb9f99744)
                / int256(0x0000000000000000000000000043cbaf42a000812488fc5c220ad7b97bf6e99e); // * e ^ -32
        }
        // e ^ -16
        if ((x & int256(0x0000000000000000000000000000000800000000000000000000000000000000)) != 0) {
            r = r * int256(0x00000000000000000000000000000000000afe10820813d65dfe6a33c07f738f)
                / int256(0x000000000000000000000000000005d27a9f51c31b7c2f8038212a0574779991); // * e ^ -16
        }
        // e ^ -8
        if ((x & int256(0x0000000000000000000000000000000400000000000000000000000000000000)) != 0) {
            r = r * int256(0x0000000000000000000000000000000002582ab704279e8efd15e0265855c47a)
                / int256(0x0000000000000000000000000000001b4c902e273a58678d6d3bfdb93db96d02); // * e ^ -8
        }
        // e ^ -4
        if ((x & int256(0x0000000000000000000000000000000200000000000000000000000000000000)) != 0) {
            r = r * int256(0x000000000000000000000000000000001152aaa3bf81cb9fdb76eae12d029571)
                / int256(0x00000000000000000000000000000003b1cc971a9bb5b9867477440d6d157750); // * e ^ -4
        }
        // e ^ -2
        if ((x & int256(0x0000000000000000000000000000000100000000000000000000000000000000)) != 0) {
            r = r * int256(0x000000000000000000000000000000002f16ac6c59de6f8d5d6f63c1482a7c86)
                / int256(0x000000000000000000000000000000015bf0a8b1457695355fb8ac404e7a79e3); // * e ^ -2
        }
        // e ^ -1
        if ((x & int256(0x0000000000000000000000000000000080000000000000000000000000000000)) != 0) {
            r = r * int256(0x000000000000000000000000000000004da2cbf1be5827f9eb3ad1aa9866ebb3)
                / int256(0x00000000000000000000000000000000d3094c70f034de4b96ff7d5b6f99fcd8); // * e ^ -1
        }
        // e ^ -0.5
        if ((x & int256(0x0000000000000000000000000000000040000000000000000000000000000000)) != 0) {
            r = r * int256(0x0000000000000000000000000000000063afbe7ab2082ba1a0ae5e4eb1b479dc)
                / int256(0x00000000000000000000000000000000a45af1e1f40c333b3de1db4dd55f29a7); // * e ^ -0.5
        }
        // e ^ -0.25
        if ((x & int256(0x0000000000000000000000000000000020000000000000000000000000000000)) != 0) {
            r = r * int256(0x0000000000000000000000000000000070f5a893b608861e1f58934f97aea57d)
                / int256(0x00000000000000000000000000000000910b022db7ae67ce76b441c27035c6a1); // * e ^ -0.25
        }
        // e ^ -0.125
        if ((x & int256(0x0000000000000000000000000000000010000000000000000000000000000000)) != 0) {
            r = r * int256(0x00000000000000000000000000000000783eafef1c0a8f3978c7f81824d62ebf)
                / int256(0x0000000000000000000000000000000088415abbe9a76bead8d00cf112e4d4a8); // * e ^ -0.125
        }
    }

    
    function _mul(int256 a, int256 b) private pure returns (int256 c) {
        if (a == 0 || b == 0) {
            return 0;
        }
        c = a * b;
        if (c / a != b || c / b != a) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.BinOpError(
                LibFixedMathRichErrors.BinOpErrorCodes.MULTIPLICATION_OVERFLOW,
                a,
                b
            ));
        }
    }

    
    function _div(int256 a, int256 b) private pure returns (int256 c) {
        if (b == 0) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.BinOpError(
                LibFixedMathRichErrors.BinOpErrorCodes.DIVISION_BY_ZERO,
                a,
                b
            ));
        }
        if (a == MIN_FIXED_VAL && b == -1) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.BinOpError(
                LibFixedMathRichErrors.BinOpErrorCodes.DIVISION_OVERFLOW,
                a,
                b
            ));
        }
        c = a / b;
    }

    
    function _add(int256 a, int256 b) private pure returns (int256 c) {
        c = a + b;
        if ((a < 0 && b < 0 && c > a) || (a > 0 && b > 0 && c < a)) {
            LibRichErrors.rrevert(LibFixedMathRichErrors.BinOpError(
                LibFixedMathRichErrors.BinOpErrorCodes.ADDITION_OVERFLOW,
                a,
                b
            ));
        }
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;




library LibFixedMathRichErrors {

    enum ValueErrorCodes {
        TOO_SMALL,
        TOO_LARGE
    }

    enum BinOpErrorCodes {
        ADDITION_OVERFLOW,
        MULTIPLICATION_OVERFLOW,
        DIVISION_BY_ZERO,
        DIVISION_OVERFLOW
    }

    // bytes4(keccak256("SignedValueError(uint8,int256)"))
    bytes4 internal constant SIGNED_VALUE_ERROR_SELECTOR =
        0xed2f26a1;

    // bytes4(keccak256("UnsignedValueError(uint8,uint256)"))
    bytes4 internal constant UNSIGNED_VALUE_ERROR_SELECTOR =
        0xbd79545f;

    // bytes4(keccak256("BinOpError(uint8,int256,int256)"))
    bytes4 internal constant BIN_OP_ERROR_SELECTOR =
        0x8c12dfe7;

    // solhint-disable func-name-mixedcase
    function SignedValueError(
        ValueErrorCodes error,
        int256 n
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            SIGNED_VALUE_ERROR_SELECTOR,
            uint8(error),
            n
        );
    }

    function UnsignedValueError(
        ValueErrorCodes error,
        uint256 n
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            UNSIGNED_VALUE_ERROR_SELECTOR,
            uint8(error),
            n
        );
    }

    function BinOpError(
        BinOpErrorCodes error,
        int256 a,
        int256 b
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            BIN_OP_ERROR_SELECTOR,
            uint8(error),
            a,
            b
        );
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/
pragma solidity ^0.5.9;





// solhint-disable no-empty-blocks
contract TestCumulativeRewardTracking is
    TestStaking
{
    event SetCumulativeReward(
        bytes32 poolId,
        uint256 epoch
    );

    constructor(
        address wethAddress,
        address zrxVaultAddress
    )
        public
        TestStaking(
            wethAddress,
            zrxVaultAddress
        )
    {}

    function init() public {}

    function _addCumulativeReward(
        bytes32 poolId,
        uint256 reward,
        uint256 stake
    )
        internal
    {
        uint256 lastStoredEpoch = _cumulativeRewardsByPoolLastStored[poolId];
        MixinCumulativeRewards._addCumulativeReward(
            poolId,
            reward,
            stake
        );
        uint256 newLastStoredEpoch = _cumulativeRewardsByPoolLastStored[poolId];
        if (newLastStoredEpoch != lastStoredEpoch) {
            emit SetCumulativeReward(poolId, currentEpoch);
        }
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

// solhint-disable
pragma solidity ^0.5.9;



// @dev Interface of the asset proxy's assetData.
// The asset proxies take an ABI encoded `bytes assetData` as argument.
// This argument is ABI encoded as one of the methods of this interface.
interface IAssetData {

    
    
    function ERC20Token(address tokenAddress)
        external;

    
    
    
    function ERC721Token(
        address tokenAddress,
        uint256 tokenId
    )
        external;

    
    
    
    
    ///        Note that each value will be multiplied by the amount being filled in the order before transferring.
    
    function ERC1155Assets(
        address tokenAddress,
        uint256[] calldata tokenIds,
        uint256[] calldata values,
        bytes calldata callbackData
    )
        external;

    
    
    ///        Note that each value will be multiplied by the amount being filled in the order before transferring.
    
    function MultiAsset(
        uint256[] calldata values,
        bytes[] calldata nestedAssetData
    )
        external;

    
    
    
    
    function StaticCall(
        address staticCallTargetAddress,
        bytes calldata staticCallData,
        bytes32 expectedReturnDataHash
    )
        external;

    
    
    
    
    function ERC20Bridge(
        address tokenAddress,
        address bridgeAddress,
        bytes calldata bridgeData
    )
        external;
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;






contract TestDelegatorRewards is
    TestStakingNoWETH
{
    event FinalizePool(
        bytes32 poolId,
        uint256 operatorReward,
        uint256 membersReward,
        uint256 membersStake
    );

    struct UnfinalizedPoolReward {
        uint256 operatorReward;
        uint256 membersReward;
        uint256 membersStake;
    }

    constructor() public {
        _addAuthorizedAddress(msg.sender);
        init();
        _removeAuthorizedAddressAtIndex(msg.sender, 0);
    }

    mapping (uint256 => mapping (bytes32 => UnfinalizedPoolReward)) private
        unfinalizedPoolRewardsByEpoch;

    
    function setUnfinalizedPoolReward(
        bytes32 poolId,
        address payable operatorAddress,
        uint256 operatorReward,
        uint256 membersReward,
        uint256 membersStake
    )
        external
    {
        unfinalizedPoolRewardsByEpoch[currentEpoch][poolId] = UnfinalizedPoolReward({
            operatorReward: operatorReward,
            membersReward: membersReward,
            membersStake: membersStake
        });
        // Lazily initialize this pool.
        _poolById[poolId].operator = operatorAddress;
        _setOperatorShare(poolId, operatorReward, membersReward);
    }

    
    function syncPoolRewards(
        bytes32 poolId,
        address payable operatorAddress,
        uint256 operatorReward,
        uint256 membersReward,
        uint256 membersStake
    )
        external
    {
        // Lazily initialize this pool.
        _poolById[poolId].operator = operatorAddress;
        _setOperatorShare(poolId, operatorReward, membersReward);

        _syncPoolRewards(
            poolId,
            operatorReward + membersReward,
            membersStake
        );
    }

    
    function advanceEpoch() external {
        currentEpoch += 1;
    }

    
    ///      Only used to test purportedly unreachable states.
    ///      Also withdraws pending rewards.
    function delegateStakeNow(
        address delegator,
        bytes32 poolId,
        uint256 stake
    )
        external
    {
        _withdrawAndSyncDelegatorRewards(
            poolId,
            delegator
        );
        IStructs.StoredBalance storage _stake = _delegatedStakeToPoolByOwner[delegator][poolId];
        _stake.currentEpochBalance += uint96(stake);
        _stake.nextEpochBalance += uint96(stake);
        _stake.currentEpoch = uint32(currentEpoch);
        _withdrawAndSyncDelegatorRewards(
            poolId,
            delegator
        );
    }

    
    ///      (normal behavior).
    ///      Also withdraws pending rewards.
    function delegateStake(
        address delegator,
        bytes32 poolId,
        uint256 stake
    )
        external
    {
        _withdrawAndSyncDelegatorRewards(
            poolId,
            delegator
        );
        IStructs.StoredBalance storage _stake = _delegatedStakeToPoolByOwner[delegator][poolId];
        if (_stake.currentEpoch < currentEpoch) {
            _stake.currentEpochBalance = _stake.nextEpochBalance;
        }
        _stake.nextEpochBalance += uint96(stake);
        _stake.currentEpoch = uint32(currentEpoch);
    }

    
    ///      (normal behavior).
    ///      Also withdraws pending rewards.
    function undelegateStake(
        address delegator,
        bytes32 poolId,
        uint256 stake
    )
        external
    {
        _withdrawAndSyncDelegatorRewards(
            poolId,
            delegator
        );
        IStructs.StoredBalance storage _stake = _delegatedStakeToPoolByOwner[delegator][poolId];
        if (_stake.currentEpoch < currentEpoch) {
            _stake.currentEpochBalance = _stake.nextEpochBalance;
        }
        _stake.nextEpochBalance -= uint96(stake);
        _stake.currentEpoch = uint32(currentEpoch);
    }

    // solhint-disable no-simple-event-func-name
    
    ///      the current epoch and emit a event,
    function finalizePool(bytes32 poolId)
        external
    {
        UnfinalizedPoolReward memory reward = unfinalizedPoolRewardsByEpoch[currentEpoch][poolId];
        delete unfinalizedPoolRewardsByEpoch[currentEpoch][poolId];

        _setOperatorShare(poolId, reward.operatorReward, reward.membersReward);

        uint256 totalRewards = reward.operatorReward + reward.membersReward;
        uint256 membersStake = reward.membersStake;
        (uint256 operatorReward, uint256 membersReward) =
            _syncPoolRewards(poolId, totalRewards, membersStake);
        emit FinalizePool(poolId, operatorReward, membersReward, membersStake);
    }

    
    function _getUnfinalizedPoolRewards(bytes32 poolId)
        internal
        view
        returns (
            uint256 totalReward,
            uint256 membersStake
        )
    {
        UnfinalizedPoolReward storage reward = unfinalizedPoolRewardsByEpoch[currentEpoch][poolId];
        totalReward = reward.operatorReward + reward.membersReward;
        membersStake = reward.membersStake;
    }

    
    function _setOperatorShare(
        bytes32 poolId,
        uint256 operatorReward,
        uint256 membersReward
    )
        private
    {
        uint32 operatorShare = 0;
        uint256 totalReward = operatorReward + membersReward;
        if (totalReward != 0) {
            operatorShare = uint32(
                operatorReward * PPM_DENOMINATOR / totalReward
            );
        }
        _poolById[poolId].operatorShare = operatorShare;
    }

}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;





contract TestExchangeManager is
    Staking
{
    function setValidExchange(address exchange)
        external
    {
        validExchanges[exchange] = true;
    }

    function onlyExchangeFunction()
        external
        view
        onlyExchange
        returns (bool)
    {
        return true;
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;







contract TestFinalizer is
    TestStakingNoWETH
{
    event DepositStakingPoolRewards(
        bytes32 poolId,
        uint256 reward,
        uint256 membersStake
    );

    struct UnfinalizedPoolReward {
        uint256 totalReward;
        uint256 membersStake;
    }

    struct FinalizedPoolRewards {
        uint256 operatorReward;
        uint256 membersReward;
        uint256 membersStake;
    }

    address payable private _operatorRewardsReceiver;
    address payable private _membersRewardsReceiver;
    mapping (bytes32 => uint32) private _operatorSharesByPool;

    
    ///        a pool is finalized.
    constructor(
        address payable operatorRewardsReceiver,
        address payable membersRewardsReceiver
    )
        public
    {
        _addAuthorizedAddress(msg.sender);
        init();
        _operatorRewardsReceiver = operatorRewardsReceiver;
        _membersRewardsReceiver = membersRewardsReceiver;
        _removeAuthorizedAddressAtIndex(msg.sender, 0);
    }

    // this contract can receive ETH
    // solhint-disable no-empty-blocks
    function ()
        external
        payable
    {}

    
    function addActivePool(
        bytes32 poolId,
        uint32 operatorShare,
        uint256 feesCollected,
        uint256 membersStake,
        uint256 weightedStake
    )
        external
    {
        require(feesCollected > 0, "FEES_MUST_BE_NONZERO");
        uint256 currentEpoch_ = currentEpoch;
        IStructs.PoolStats memory poolStats = poolStatsByEpoch[poolId][currentEpoch_];
        require(poolStats.feesCollected == 0, "POOL_ALREADY_ADDED");
        _operatorSharesByPool[poolId] = operatorShare;
        poolStatsByEpoch[poolId][currentEpoch_] = IStructs.PoolStats({
            feesCollected: feesCollected,
            membersStake: membersStake,
            weightedStake: weightedStake
        });

        aggregatedStatsByEpoch[currentEpoch_].totalFeesCollected += feesCollected;
        aggregatedStatsByEpoch[currentEpoch_].totalWeightedStake += weightedStake;
        aggregatedStatsByEpoch[currentEpoch_].numPoolsToFinalize += 1;
    }

    
    function drainBalance()
        external
    {
        address(0).transfer(address(this).balance);
    }

    
    function cobbDouglas(
        uint256 totalRewards,
        uint256 ownerFees,
        uint256 totalFees,
        uint256 ownerStake,
        uint256 totalStake
    )
        external
        view
        returns (uint256 ownerRewards)
    {
        ownerRewards = LibCobbDouglas.cobbDouglas(
            totalRewards,
            ownerFees,
            totalFees,
            ownerStake,
            totalStake,
            cobbDouglasAlphaNumerator,
            cobbDouglasAlphaDenominator
        );
    }

    
    function getUnfinalizedPoolRewards(bytes32 poolId)
        external
        view
        returns (UnfinalizedPoolReward memory reward)
    {
        (reward.totalReward, reward.membersStake) = _getUnfinalizedPoolRewards(
            poolId
        );
    }

    
    function getPoolStatsFromEpoch(uint256 epoch, bytes32 poolId)
        external
        view
        returns (IStructs.PoolStats memory)
    {
        return poolStatsByEpoch[poolId][epoch];
    }

    function getAggregatedStatsForPreviousEpoch()
        external
        view
        returns (IStructs.AggregatedStats memory)
    {
        return aggregatedStatsByEpoch[currentEpoch - 1];
    }

    
    function _syncPoolRewards(
        bytes32 poolId,
        uint256 reward,
        uint256 membersStake
    )
        internal
        returns (uint256 operatorReward, uint256 membersReward)
    {
        uint32 operatorShare = _operatorSharesByPool[poolId];
        (operatorReward, membersReward) = _computePoolRewardsSplit(
            operatorShare,
            reward,
            membersStake
        );
        address(_operatorRewardsReceiver).transfer(operatorReward);
        address(_membersRewardsReceiver).transfer(membersReward);
        emit DepositStakingPoolRewards(poolId, reward, membersStake);
    }

    
    function _goToNextEpoch() internal {
        currentEpoch += 1;
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;





contract TestMixinCumulativeRewards is
    TestStaking
{

    constructor(
        address wethAddress,
        address zrxVaultAddress
    )
        public
        TestStaking(
            wethAddress,
            zrxVaultAddress
        )
    {
        _addAuthorizedAddress(msg.sender);
        init();
        _removeAuthorizedAddressAtIndex(msg.sender, 0);
    }

    
    function isCumulativeRewardSet(IStructs.Fraction memory cumulativeReward)
        public
        pure
        returns (bool)
    {
        return _isCumulativeRewardSet(cumulativeReward);
    }

    
    function addCumulativeReward(
        bytes32 poolId,
        uint256 reward,
        uint256 stake
    )
        public
    {
        _addCumulativeReward(poolId, reward, stake);
    }

    
    function updateCumulativeReward(bytes32 poolId)
        public
    {
        _updateCumulativeReward(poolId);
    }

    
    function computeMemberRewardOverInterval(
        bytes32 poolId,
        uint256 memberStakeOverInterval,
        uint256 beginEpoch,
        uint256 endEpoch
    )
        public
        view
        returns (uint256 reward)
    {
        return _computeMemberRewardOverInterval(poolId, memberStakeOverInterval, beginEpoch, endEpoch);
    }

    
    function incrementEpoch()
        public
    {
        currentEpoch += 1;
    }

    
    ///      Also sets the `_cumulativeRewardsByPoolLastStored` to the input epoch.
    function storeCumulativeReward(
        bytes32 poolId,
        IStructs.Fraction memory cumulativeReward,
        uint256 epoch
    )
        public
    {
        _cumulativeRewardsByPool[poolId][epoch] = cumulativeReward;
        _cumulativeRewardsByPoolLastStored[poolId] = epoch;
    }

    
    ///      This is considered "raw" because the internal implementation
    ///      (_getCumulativeRewardAtEpochRaw) will query other state variables
    ///      to determine the most accurate cumulative reward for a given epoch.
    function getCumulativeRewardAtEpochRaw(bytes32 poolId, uint256 epoch)
        public
        returns (IStructs.Fraction memory)
    {
        return  _cumulativeRewardsByPool[poolId][epoch];
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;





contract TestMixinScheduler is
    TestStaking
{
    uint256 public testDeployedTimestamp;

    event GoToNextEpochTestInfo(
        uint256 oldEpoch,
        uint256 blockTimestamp
    );

    constructor(
        address wethAddress,
        address zrxVaultAddress
    )
        public
        TestStaking(
            wethAddress,
            zrxVaultAddress
        )
    {
        _addAuthorizedAddress(msg.sender);
        init();
        _removeAuthorizedAddressAtIndex(msg.sender, 0);

        // Record time of deployment
        // solhint-disable-next-line not-rely-on-time
        testDeployedTimestamp = block.timestamp;
    }

    
    ///      Configures internal variables such taht `epochEndTime` will be
    ///      less-than, equal-to, or greater-than the block timestamp.
    
    function goToNextEpochTest(int256 epochEndTimeDelta)
        public
    {
        // solhint-disable-next-line not-rely-on-time
        uint256 blockTimestamp = block.timestamp;

        // Emit info used by client-side test code
        emit GoToNextEpochTestInfo(
            currentEpoch,
            blockTimestamp
        );

        // (i) In `_goToNextEpoch` we compute:
        //     `epochEndTime = currentEpochStartTimeInSeconds + epochDurationInSeconds`
        // (ii) We want adjust internal state such that:
        //      `epochEndTime - block.timestamp = epochEndTimeDelta`, or
        //      `currentEpochStartTimeInSeconds + epochDurationInSeconds - block.timestamp = epochEndTimeDelta`
        //
        // To do this, we:
        //  (i) Set `epochDurationInSeconds` to a constant value of 1, and
        //  (ii) Rearrange the eqn above to get:
        //      `currentEpochStartTimeInSeconds = epochEndTimeDelta + block.timestamp - epochDurationInSeconds`
        epochDurationInSeconds = 1;
        currentEpochStartTimeInSeconds =
            uint256(epochEndTimeDelta + int256(blockTimestamp) - int256(epochDurationInSeconds));

        // Test internal function
        _goToNextEpoch();
    }

    
    
    function initMixinSchedulerTest(uint256 _currentEpochStartTimeInSeconds)
        public
    {
        currentEpochStartTimeInSeconds = _currentEpochStartTimeInSeconds;
        _initMixinScheduler();
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;






contract TestMixinStake is
    TestStakingNoWETH
{
    event ZrxVaultDepositFrom(
        address staker,
        uint256 amount
    );

    event ZrxVaultWithdrawFrom(
        address staker,
        uint256 amount
    );

    event MoveStakeStorage(
        bytes32 fromBalanceSlot,
        bytes32 toBalanceSlot,
        uint256 amount
    );

    event IncreaseCurrentAndNextBalance(
        bytes32 balanceSlot,
        uint256 amount
    );

    event DecreaseCurrentAndNextBalance(
        bytes32 balanceSlot,
        uint256 amount
    );

    event IncreaseNextBalance(
        bytes32 balanceSlot,
        uint256 amount
    );

    event DecreaseNextBalance(
        bytes32 balanceSlot,
        uint256 amount
    );

    event WithdrawAndSyncDelegatorRewards(
        bytes32 poolId,
        address delegator
    );

    
    function advanceEpoch() external {
        currentEpoch += 1;
    }

    
    function depositFrom(address staker, uint256 amount) external {
        emit ZrxVaultDepositFrom(staker, amount);
    }

    
    function withdrawFrom(address staker, uint256 amount) external {
        emit ZrxVaultWithdrawFrom(staker, amount);
    }

    function getDelegatedStakeByPoolIdSlot(bytes32 poolId)
        external
        view
        returns (bytes32 slot)
    {
        return _getPtrSlot(_delegatedStakeByPoolId[poolId]);
    }

    function getDelegatedStakeToPoolByOwnerSlot(bytes32 poolId, address staker)
        external
        view
        returns (bytes32 slot)
    {
        return _getPtrSlot(_delegatedStakeToPoolByOwner[staker][poolId]);
    }

    function getGlobalStakeByStatusSlot(IStructs.StakeStatus status)
        external
        view
        returns (bytes32 slot)
    {
        return _getPtrSlot(_globalStakeByStatus[uint8(status)]);
    }

    function getOwnerStakeByStatusSlot(address owner, IStructs.StakeStatus status)
        external
        view
        returns (bytes32 slot)
    {
        return _getPtrSlot(_ownerStakeByStatus[uint8(status)][owner]);
    }

    
    function setOwnerStakeByStatus(
        address owner,
        IStructs.StakeStatus status,
        IStructs.StoredBalance memory stake
    )
        public
    {
        _ownerStakeByStatus[uint8(status)][owner] = stake;
    }

    
    function getZrxVault()
        public
        view
        returns (IZrxVault zrxVault)
    {
        return IZrxVault(address(this));
    }

    
    function _withdrawAndSyncDelegatorRewards(
        bytes32 poolId,
        address member
    )
        internal
    {
        emit WithdrawAndSyncDelegatorRewards(poolId, member);
    }

    
    function _moveStake(
        IStructs.StoredBalance storage fromPtr,
        IStructs.StoredBalance storage toPtr,
        uint256 amount
    )
        internal
    {
        emit MoveStakeStorage(
            _getPtrSlot(fromPtr),
            _getPtrSlot(toPtr),
            amount
        );
    }

    
    function _increaseCurrentAndNextBalance(
        IStructs.StoredBalance storage balancePtr,
        uint256 amount
    )
        internal
    {
        emit IncreaseCurrentAndNextBalance(
            _getPtrSlot(balancePtr),
            amount
        );
    }

    
    function _decreaseCurrentAndNextBalance(
        IStructs.StoredBalance storage balancePtr,
        uint256 amount
    )
        internal
    {
        emit DecreaseCurrentAndNextBalance(
            _getPtrSlot(balancePtr),
            amount
        );
    }

    
    function _increaseNextBalance(
        IStructs.StoredBalance storage balancePtr,
        uint256 amount
    )
        internal
    {
        emit IncreaseNextBalance(
            _getPtrSlot(balancePtr),
            amount
        );
    }

    
    function _decreaseNextBalance(
        IStructs.StoredBalance storage balancePtr,
        uint256 amount
    )
        internal
    {
        emit DecreaseNextBalance(
            _getPtrSlot(balancePtr),
            amount
        );
    }

    
    function _loadCurrentBalance(IStructs.StoredBalance storage balancePtr)
        internal
        view
        returns (IStructs.StoredBalance memory balance)
    {
        balance = balancePtr;
    }

    
    function _assertStakingPoolExists(bytes32 poolId)
        internal
        view
    {
        require(poolId != bytes32(0), "INVALID_POOL");
    }

    // solhint-disable-next-line
    function _getPtrSlot(IStructs.StoredBalance storage ptr)
        private
        pure
        returns (bytes32 offset)
    {
        assembly {
            offset := ptr_slot
        }
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;






contract TestMixinStakeBalances is
    TestStakingNoWETH
{
    uint256 private _balanceOfZrxVault;
    mapping (address => uint256) private _zrxBalanceOf;

    function setBalanceOfZrxVault(uint256 balance)
        external
    {
        _balanceOfZrxVault = balance;
    }

    function setZrxBalanceOf(address staker, uint256 balance)
        external
    {
        _zrxBalanceOf[staker] = balance;
    }

    
    function balanceOfZrxVault()
        external
        view
        returns (uint256)
    {
        return _balanceOfZrxVault;
    }

    
    function balanceOf(address staker)
        external
        view
        returns (uint256)
    {
        return _zrxBalanceOf[staker];
    }

    
    function setOwnerStakeByStatus(
        address owner,
        IStructs.StakeStatus status,
        IStructs.StoredBalance memory stake
    )
        public
    {
        _ownerStakeByStatus[uint8(status)][owner] = stake;
    }

    
    function setDelegatedStakeToPoolByOwner(
        address owner,
        bytes32 poolId,
        IStructs.StoredBalance memory stake
    )
        public
    {
        _delegatedStakeToPoolByOwner[owner][poolId] = stake;
    }

    
    function setDelegatedStakeByPoolId(
        bytes32 poolId,
        IStructs.StoredBalance memory stake
    )
        public
    {
        _delegatedStakeByPoolId[poolId] = stake;
    }

    
    function setGlobalStakeByStatus(
        IStructs.StakeStatus status,
        IStructs.StoredBalance memory stake
    )
        public
    {
        _globalStakeByStatus[uint8(status)] = stake;
    }

    
    function getZrxVault()
        public
        view
        returns (IZrxVault zrxVault)
    {
        return IZrxVault(address(this));
    }

    
    function _loadCurrentBalance(IStructs.StoredBalance storage balancePtr)
        internal
        view
        returns (IStructs.StoredBalance memory balance)
    {
        balance = balancePtr;
        balance.currentEpoch += 1;
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;






contract TestMixinStakingPool is
    TestStakingNoWETH
{
    function setLastPoolId(bytes32 poolId)
        external
    {
        lastPoolId = poolId;
    }

    function setPoolIdByMaker(bytes32 poolId, address maker)
        external
    {
        poolIdByMaker[maker] = poolId;
    }

    // solhint-disable no-empty-blocks
    function testOnlyStakingPoolOperatorModifier(bytes32 poolId)
        external
        view
        onlyStakingPoolOperator(poolId)
    {}

    function setPoolById(bytes32 poolId, IStructs.Pool memory pool)
        public
    {
        _poolById[poolId] = pool;
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;






contract TestMixinStakingPoolRewards is
    TestStakingNoWETH
{
    // solhint-disable no-simple-event-func-name
    event UpdateCumulativeReward(
        bytes32 poolId
    );

    event WithdrawAndSyncDelegatorRewards(
        bytes32 poolId,
        address delegator
    );

    struct UnfinalizedPoolReward {
        uint256 reward;
        uint256 membersStake;
    }

    constructor() public {
        _addAuthorizedAddress(msg.sender);
        init();
        _removeAuthorizedAddressAtIndex(msg.sender, 0);
    }

    // Rewards returned by `_computeMemberRewardOverInterval()`, indexed
    // by `_getMemberRewardOverIntervalHash()`.
    mapping (bytes32 => uint256) private _memberRewardsOverInterval;
    // Rewards returned by `_getUnfinalizedPoolRewards()`, indexed by pool ID.
    mapping (bytes32 => UnfinalizedPoolReward) private _unfinalizedPoolRewards;

    // Set pool `rewardsByPoolId`.
    function setPoolRewards(
        bytes32 poolId,
        uint256 _rewardsByPoolId
    )
        external
    {
        rewardsByPoolId[poolId] = _rewardsByPoolId;
    }

    // Set `wethReservedForPoolRewards`.
    function setWethReservedForPoolRewards(
        uint256 _wethReservedForPoolRewards
    )
        external
    {
        wethReservedForPoolRewards = _wethReservedForPoolRewards;
    }

    // Set the rewards returned by a call to `_computeMemberRewardOverInterval()`.
    function setMemberRewardsOverInterval(
        bytes32 poolId,
        uint256 memberStakeOverInterval,
        uint256 beginEpoch,
        uint256 endEpoch,
        uint256 reward
    )
        external
    {
        bytes32 rewardHash = _getMemberRewardOverIntervalHash(
            poolId,
            memberStakeOverInterval,
            beginEpoch,
            endEpoch
        );
        _memberRewardsOverInterval[rewardHash] = reward;
    }

    // Set the rewards returned by `_getUnfinalizedPoolRewards()`.
    function setUnfinalizedPoolRewards(
        bytes32 poolId,
        uint256 reward,
        uint256 membersStake
    )
        external
    {
        _unfinalizedPoolRewards[poolId] = UnfinalizedPoolReward(
            reward,
            membersStake
        );
    }

    // Set `currentEpoch`.
    function setCurrentEpoch(uint256 epoch) external {
        currentEpoch = epoch;
    }

    // Expose `_syncPoolRewards()` for testing.
    function syncPoolRewards(
        bytes32 poolId,
        uint256 reward,
        uint256 membersStake
    )
        external
        returns (uint256 operatorReward, uint256 membersReward)
    {
        return _syncPoolRewards(poolId, reward, membersStake);
    }

    // Expose `_withdrawAndSyncDelegatorRewards()` for testing.
    function withdrawAndSyncDelegatorRewards(
        bytes32 poolId,
        address member
    )
        external
    {
        return _withdrawAndSyncDelegatorRewards(
            poolId,
            member
        );
    }

    // Expose `_computePoolRewardsSplit()` for testing.
    function computePoolRewardsSplit(
        uint32 operatorShare,
        uint256 totalReward,
        uint256 membersStake
    )
        external
        pure
        returns (uint256 operatorReward, uint256 membersReward)
    {
        return _computePoolRewardsSplit(
            operatorShare,
            totalReward,
            membersStake
        );
    }

    // Access `_delegatedStakeToPoolByOwner`
    function delegatedStakeToPoolByOwner(address member, bytes32 poolId)
        external
        view
        returns (IStructs.StoredBalance memory balance)
    {
        return _delegatedStakeToPoolByOwner[member][poolId];
    }

    // Set `_delegatedStakeToPoolByOwner`
    function setDelegatedStakeToPoolByOwner(
        address member,
        bytes32 poolId,
        IStructs.StoredBalance memory balance
    )
        public
    {
        _delegatedStakeToPoolByOwner[member][poolId] = balance;
    }

    // Set `_poolById`.
    function setPool(
        bytes32 poolId,
        IStructs.Pool memory pool
    )
        public
    {
        _poolById[poolId] = pool;
    }

    // Overridden to emit an event.
    function _withdrawAndSyncDelegatorRewards(
        bytes32 poolId,
        address member
    )
        internal
    {
        emit WithdrawAndSyncDelegatorRewards(poolId, member);
        return MixinStakingPoolRewards._withdrawAndSyncDelegatorRewards(
            poolId,
            member
        );
    }

    // Overridden to use `_memberRewardsOverInterval`
    function _computeMemberRewardOverInterval(
        bytes32 poolId,
        uint256 memberStakeOverInterval,
        uint256 beginEpoch,
        uint256 endEpoch
    )
        internal
        view
        returns (uint256 reward)
    {
        bytes32 rewardHash = _getMemberRewardOverIntervalHash(
            poolId,
            memberStakeOverInterval,
            beginEpoch,
            endEpoch
        );
        return _memberRewardsOverInterval[rewardHash];
    }

    // Overridden to use `_unfinalizedPoolRewards`
    function _getUnfinalizedPoolRewards(
        bytes32 poolId
    )
        internal
        view
        returns (uint256 reward, uint256 membersStake)
    {
        (reward, membersStake) = (
            _unfinalizedPoolRewards[poolId].reward,
            _unfinalizedPoolRewards[poolId].membersStake
        );
    }

    // Overridden to just increase `currentEpoch`.
    function _loadCurrentBalance(IStructs.StoredBalance storage balancePtr)
        internal
        view
        returns (IStructs.StoredBalance memory balance)
    {
        balance = balancePtr;
        balance.currentEpoch += 1;
    }

    // Overridden to revert if a pool has unfinalized rewards.
    function _assertPoolFinalizedLastEpoch(bytes32 poolId)
        internal
        view
    {
        require(
            _unfinalizedPoolRewards[poolId].membersStake == 0,
            "POOL_NOT_FINALIZED"
        );
    }

    // Overridden to just emit an event.
    function _updateCumulativeReward(bytes32 poolId)
        internal
    {
        emit UpdateCumulativeReward(poolId);
    }

    // Compute a hash to index `_memberRewardsOverInterval`
    function _getMemberRewardOverIntervalHash(
        bytes32 poolId,
        uint256 memberStakeOverInterval,
        uint256 beginEpoch,
        uint256 endEpoch
    )
        private
        pure
        returns (bytes32 rewardHash)
    {
        return keccak256(
            abi.encode(
                poolId,
                memberStakeOverInterval,
                beginEpoch,
                endEpoch
            )
        );
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;






contract TestProtocolFees is
    TestStakingNoWETH
{
    struct TestPool {
        uint96 operatorStake;
        uint96 membersStake;
        mapping(address => bool) isMaker;
    }

    event ERC20ProxyTransferFrom(
        address from,
        address to,
        uint256 amount
    );

    mapping(bytes32 => TestPool) private _testPools;
    mapping(address => bytes32) private _makersToTestPoolIds;

    constructor(address exchangeAddress) public {
        _addAuthorizedAddress(msg.sender);
        init();
        validExchanges[exchangeAddress] = true;
        _removeAuthorizedAddressAtIndex(msg.sender, 0);
    }

    function advanceEpoch()
        external
    {
        currentEpoch += 1;
    }

    
    function createTestPool(
        bytes32 poolId,
        uint96 operatorStake,
        uint96 membersStake,
        address[] calldata makerAddresses
    )
        external
    {
        TestPool storage pool = _testPools[poolId];
        pool.operatorStake = operatorStake;
        pool.membersStake = membersStake;
        for (uint256 i = 0; i < makerAddresses.length; ++i) {
            pool.isMaker[makerAddresses[i]] = true;
            _makersToTestPoolIds[makerAddresses[i]] = poolId;
            poolIdByMaker[makerAddresses[i]] = poolId;
        }
    }

    
    function transferFrom(
        address from,
        address to,
        uint256 amount
    )
        external
        returns (bool)
    {
        emit ERC20ProxyTransferFrom(from, to, amount);
        return true;
    }

    function getAggregatedStatsForCurrentEpoch()
        external
        view
        returns (IStructs.AggregatedStats memory)
    {
        return aggregatedStatsByEpoch[currentEpoch];
    }

    
    function getStakingPoolIdOfMaker(address makerAddress)
        public
        view
        returns (bytes32)
    {
        return _makersToTestPoolIds[makerAddress];
    }

    
    function getTotalStakeDelegatedToPool(bytes32 poolId)
        public
        view
        returns (IStructs.StoredBalance memory balance)
    {
        TestPool memory pool = _testPools[poolId];
        uint96 stake = pool.operatorStake + pool.membersStake;
        return IStructs.StoredBalance({
            currentEpoch: currentEpoch.downcastToUint64(),
            currentEpochBalance: stake,
            nextEpochBalance: stake
        });
    }

    
    function getStakeDelegatedToPoolByOwner(address, bytes32 poolId)
        public
        view
        returns (IStructs.StoredBalance memory balance)
    {
        TestPool memory pool = _testPools[poolId];
        return IStructs.StoredBalance({
            currentEpoch: currentEpoch.downcastToUint64(),
            currentEpochBalance: pool.operatorStake,
            nextEpochBalance: pool.operatorStake
        });
    }

    function getWethContract()
        public
        view
        returns (IEtherToken wethContract)
    {
        return IEtherToken(address(this));
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;





contract TestProxyDestination is
    Staking
{
    // Init will revert if this flag is set to `true`
    bool public initFailFlag;

    
    event InitCalled(
        bool initCalled
    );

    
    function echo(string calldata val)
        external
        returns (string memory)
    {
        return val;
    }

    
    function doMath(uint256 a, uint256 b)
        external
        returns (uint256 sum, uint256 difference)
    {
        return (
            a + b,
            a - b
        );
    }

    
    function die()
        external
    {
        revert("Goodbye, World!");
    }

    
    ///      Reverts if `initFailFlag` is set, otherwise
    ///      sets storage params and emits `InitCalled`.
    function init()
        public
    {
        if (initFailFlag) {
            revert("INIT_FAIL_FLAG_SET");
        }

        // Set params such that they'll pass `StakingProxy.assertValidStorageParams`
        epochDurationInSeconds = 5 days;
        cobbDouglasAlphaNumerator = 1;
        cobbDouglasAlphaDenominator = 1;
        rewardDelegatedStakeWeight = PPM_DENOMINATOR;
        minimumPoolStake = 100;

        // Emit event to notify that `init` was called
        emit InitCalled(true);
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;







contract TestStorageLayoutAndConstants is
    Staking
{
    using LibBytes for bytes;

    
    ///      with the V1 staking proxy.
    constructor() public {
        _assertDeploymentConstants();
        _assertStorageLayout();
    }

    
    ///      are considered "invalid".
    function _assertDeploymentConstants()
        internal
        view
    {
        require(
            address(getWethContract()) != address(0),
            "WETH_MUST_BE_SET"
        );

        require(
            address(getZrxVault()) != address(0),
            "ZRX_VAULT_MUST_BE_SET"
        );
    }

    
    ///      the original staking contract's storage. The use of this function provides assurance
    ///      that regressions from the original storage layout will not occur.
    function _assertStorageLayout()
        internal
        pure
    {
        assembly {
            let slot := 0x0
            let offset := 0x0

            /// Ownable

            assertSlotAndOffset(
                owner_slot,
                owner_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)

            /// Authorizable

            assertSlotAndOffset(
                authorized_slot,
                authorized_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)

            assertSlotAndOffset(
                authorities_slot,
                authorities_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)

            /// MixinStorage

            assertSlotAndOffset(
                stakingContract_slot,
                stakingContract_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)

            assertSlotAndOffset(
                _globalStakeByStatus_slot,
                _globalStakeByStatus_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)

            assertSlotAndOffset(
                _ownerStakeByStatus_slot,
                _ownerStakeByStatus_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)

            assertSlotAndOffset(
                _delegatedStakeToPoolByOwner_slot,
                _delegatedStakeToPoolByOwner_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)

            assertSlotAndOffset(
                _delegatedStakeByPoolId_slot,
                _delegatedStakeByPoolId_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)

            assertSlotAndOffset(
                lastPoolId_slot,
                lastPoolId_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)

            assertSlotAndOffset(
                poolIdByMaker_slot,
                poolIdByMaker_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)

            assertSlotAndOffset(
                _poolById_slot,
                _poolById_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)

            assertSlotAndOffset(
                rewardsByPoolId_slot,
                rewardsByPoolId_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)

            assertSlotAndOffset(
                currentEpoch_slot,
                currentEpoch_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)

            assertSlotAndOffset(
                currentEpochStartTimeInSeconds_slot,
                currentEpochStartTimeInSeconds_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)

            assertSlotAndOffset(
                _cumulativeRewardsByPool_slot,
                _cumulativeRewardsByPool_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)

            assertSlotAndOffset(
                _cumulativeRewardsByPoolLastStored_slot,
                _cumulativeRewardsByPoolLastStored_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)

            assertSlotAndOffset(
                validExchanges_slot,
                validExchanges_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)

            assertSlotAndOffset(
                epochDurationInSeconds_slot,
                epochDurationInSeconds_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)

            assertSlotAndOffset(
                rewardDelegatedStakeWeight_slot,
                rewardDelegatedStakeWeight_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)

            assertSlotAndOffset(
                minimumPoolStake_slot,
                minimumPoolStake_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)

            assertSlotAndOffset(
                cobbDouglasAlphaNumerator_slot,
                cobbDouglasAlphaNumerator_offset,
                slot,
                offset
            )
            offset := add(offset, 0x4)

            // This number will be tightly packed into the previous values storage slot since
            // they are both `uint32`. Because of this tight packing, the offset of this value
            // must be 4, since the previous value is a 4 byte number.
            assertSlotAndOffset(
                cobbDouglasAlphaDenominator_slot,
                cobbDouglasAlphaDenominator_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)
            offset := 0x0

            assertSlotAndOffset(
                poolStatsByEpoch_slot,
                poolStatsByEpoch_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)

            assertSlotAndOffset(
                aggregatedStatsByEpoch_slot,
                aggregatedStatsByEpoch_offset,
                slot,
                offset
            )
            slot := add(slot, 0x1)

            assertSlotAndOffset(
                wethReservedForPoolRewards_slot,
                wethReservedForPoolRewards_offset,
                slot,
                offset
            )

            // This assembly function will assert that the actual values for `_slot` and `_offset` are
            // correct and will revert with a rich error if they are different than the expected values.
            function assertSlotAndOffset(
                actual_slot,
                actual_offset,
                expected_slot,
                expected_offset
            ) {
                // If expected_slot is not equal to actual_slot, revert with a rich error.
                if iszero(eq(expected_slot, actual_slot)) {
                    mstore(0x0, 0x213eb13400000000000000000000000000000000000000000000000000000000) // Rich error selector
                    mstore(0x4, 0x0)                                                                // Unexpected slot error code
                    mstore(0x24, expected_slot)                                                     // Expected slot
                    mstore(0x44, actual_slot)                                                       // Actual slot
                    revert(0x0, 0x64)
                }

                // If expected_offset is not equal to actual_offset, revert with a rich error.
                if iszero(eq(expected_offset, actual_offset)) {
                    mstore(0x0, 0x213eb13400000000000000000000000000000000000000000000000000000000) // Rich error selector
                    mstore(0x4, 0x1)                                                                // Unexpected offset error code
                    mstore(0x24, expected_offset)                                                   // Expected offset
                    mstore(0x44, actual_offset)                                                     // Actual offset
                    revert(0x0, 0x64)
                }
            }
        }
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;





library LibBytes {

    using LibBytes for bytes;

    
    
    
    ///         points to the header of the byte array which contains
    ///         the length.
    function rawAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := input
        }
        return memoryAddress;
    }

    
    
    
    function contentAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := add(input, 32)
        }
        return memoryAddress;
    }

    
    
    
    
    function memCopy(
        uint256 dest,
        uint256 source,
        uint256 length
    )
        internal
        pure
    {
        if (length < 32) {
            // Handle a partial word by reading destination and masking
            // off the bits we are interested in.
            // This correctly handles overlap, zero lengths and source == dest
            assembly {
                let mask := sub(exp(256, sub(32, length)), 1)
                let s := and(mload(source), not(mask))
                let d := and(mload(dest), mask)
                mstore(dest, or(s, d))
            }
        } else {
            // Skip the O(length) loop when source == dest.
            if (source == dest) {
                return;
            }

            // For large copies we copy whole words at a time. The final
            // word is aligned to the end of the range (instead of after the
            // previous) to handle partial words. So a copy will look like this:
            //
            //  ####
            //      ####
            //          ####
            //            ####
            //
            // We handle overlap in the source and destination range by
            // changing the copying direction. This prevents us from
            // overwriting parts of source that we still need to copy.
            //
            // This correctly handles source == dest
            //
            if (source > dest) {
                assembly {
                    // We subtract 32 from `sEnd` and `dEnd` because it
                    // is easier to compare with in the loop, and these
                    // are also the addresses we need for copying the
                    // last bytes.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    // Remember the last 32 bytes of source
                    // This needs to be done here and not after the loop
                    // because we may have overwritten the last bytes in
                    // source already due to overlap.
                    let last := mload(sEnd)

                    // Copy whole words front to back
                    // Note: the first check is always true,
                    // this could have been a do-while loop.
                    // solhint-disable-next-line no-empty-blocks
                    for {} lt(source, sEnd) {} {
                        mstore(dest, mload(source))
                        source := add(source, 32)
                        dest := add(dest, 32)
                    }

                    // Write the last 32 bytes
                    mstore(dEnd, last)
                }
            } else {
                assembly {
                    // We subtract 32 from `sEnd` and `dEnd` because those
                    // are the starting points when copying a word at the end.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    // Remember the first 32 bytes of source
                    // This needs to be done here and not after the loop
                    // because we may have overwritten the first bytes in
                    // source already due to overlap.
                    let first := mload(source)

                    // Copy whole words back to front
                    // We use a signed comparisson here to allow dEnd to become
                    // negative (happens when source and dest < 32). Valid
                    // addresses in local memory will never be larger than
                    // 2**255, so they can be safely re-interpreted as signed.
                    // Note: the first check is always true,
                    // this could have been a do-while loop.
                    // solhint-disable-next-line no-empty-blocks
                    for {} slt(dest, dEnd) {} {
                        mstore(dEnd, mload(sEnd))
                        sEnd := sub(sEnd, 32)
                        dEnd := sub(dEnd, 32)
                    }

                    // Write the first 32 bytes
                    mstore(dest, first)
                }
            }
        }
    }

    
    
    
    
    
    function slice(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        // Ensure that the from and to positions are valid positions for a slice within
        // the byte array that is being used.
        if (from > to) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                from,
                to
            ));
        }
        if (to > b.length) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                to,
                b.length
            ));
        }

        // Create a new bytes structure and copy contents
        result = new bytes(to - from);
        memCopy(
            result.contentAddress(),
            b.contentAddress() + from,
            result.length
        );
        return result;
    }

    
    
    
    
    
    
    function sliceDestructive(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        // Ensure that the from and to positions are valid positions for a slice within
        // the byte array that is being used.
        if (from > to) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                from,
                to
            ));
        }
        if (to > b.length) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                to,
                b.length
            ));
        }

        // Create a new bytes structure around [from, to) in-place.
        assembly {
            result := add(b, from)
            mstore(result, sub(to, from))
        }
        return result;
    }

    
    
    
    function popLastByte(bytes memory b)
        internal
        pure
        returns (bytes1 result)
    {
        if (b.length == 0) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanZeroRequired,
                b.length,
                0
            ));
        }

        // Store last byte.
        result = b[b.length - 1];

        assembly {
            // Decrement length of byte array.
            let newLen := sub(mload(b), 1)
            mstore(b, newLen)
        }
        return result;
    }

    
    
    
    
    function equals(
        bytes memory lhs,
        bytes memory rhs
    )
        internal
        pure
        returns (bool equal)
    {
        // Keccak gas cost is 30 + numWords * 6. This is a cheap way to compare.
        // We early exit on unequal lengths, but keccak would also correctly
        // handle this.
        return lhs.length == rhs.length && keccak256(lhs) == keccak256(rhs);
    }

    
    
    
    
    function readAddress(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (address result)
    {
        if (b.length < index + 20) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                b.length,
                index + 20 // 20 is length of address
            ));
        }

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Read address from array memory
        assembly {
            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 20-byte mask to obtain address
            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    
    
    
    
    function writeAddress(
        bytes memory b,
        uint256 index,
        address input
    )
        internal
        pure
    {
        if (b.length < index + 20) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                b.length,
                index + 20 // 20 is length of address
            ));
        }

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Store address into array memory
        assembly {
            // The address occupies 20 bytes and mstore stores 32 bytes.
            // First fetch the 32-byte word where we'll be storing the address, then
            // apply a mask so we have only the bytes in the word that the address will not occupy.
            // Then combine these bytes with the address and store the 32 bytes back to memory with mstore.

            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 12-byte mask to obtain extra bytes occupying word of memory where we'll store the address
            let neighbors := and(
                mload(add(b, index)),
                0xffffffffffffffffffffffff0000000000000000000000000000000000000000
            )

            // Make sure input address is clean.
            // (Solidity does not guarantee this)
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffff)

            // Store the neighbors and address into memory
            mstore(add(b, index), xor(input, neighbors))
        }
    }

    
    
    
    
    function readBytes32(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes32 result)
    {
        if (b.length < index + 32) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                b.length,
                index + 32
            ));
        }

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

    
    
    
    
    function writeBytes32(
        bytes memory b,
        uint256 index,
        bytes32 input
    )
        internal
        pure
    {
        if (b.length < index + 32) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                b.length,
                index + 32
            ));
        }

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            mstore(add(b, index), input)
        }
    }

    
    
    
    
    function readUint256(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (uint256 result)
    {
        result = uint256(readBytes32(b, index));
        return result;
    }

    
    
    
    
    function writeUint256(
        bytes memory b,
        uint256 index,
        uint256 input
    )
        internal
        pure
    {
        writeBytes32(b, index, bytes32(input));
    }

    
    
    
    
    function readBytes4(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes4 result)
    {
        if (b.length < index + 4) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsFourRequired,
                b.length,
                index + 4
            ));
        }

        // Arrays are prefixed by a 32 byte length field
        index += 32;

        // Read the bytes4 from array memory
        assembly {
            result := mload(add(b, index))
            // Solidity does not require us to clean the trailing bytes.
            // We do it anyway
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }

    
    ///      Decreasing length will lead to removing the corresponding lower order bytes from the byte array.
    ///      Increasing length may lead to appending adjacent in-memory bytes to the end of the byte array.
    
    
    function writeLength(bytes memory b, uint256 length)
        internal
        pure
    {
        assembly {
            mstore(b, length)
        }
    }
}

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;


library LibBytesRichErrors {

    enum InvalidByteOperationErrorCodes {
        FromLessThanOrEqualsToRequired,
        ToLessThanOrEqualsLengthRequired,
        LengthGreaterThanZeroRequired,
        LengthGreaterThanOrEqualsFourRequired,
        LengthGreaterThanOrEqualsTwentyRequired,
        LengthGreaterThanOrEqualsThirtyTwoRequired,
        LengthGreaterThanOrEqualsNestedBytesLengthRequired,
        DestinationLengthGreaterThanOrEqualSourceLengthRequired
    }

    // bytes4(keccak256("InvalidByteOperationError(uint8,uint256,uint256)"))
    bytes4 internal constant INVALID_BYTE_OPERATION_ERROR_SELECTOR =
        0x28006595;

    // solhint-disable func-name-mixedcase
    function InvalidByteOperationError(
        InvalidByteOperationErrorCodes errorCode,
        uint256 offset,
        uint256 required
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            INVALID_BYTE_OPERATION_ERROR_SELECTOR,
            errorCode,
            offset,
            required
        );
    }
}
