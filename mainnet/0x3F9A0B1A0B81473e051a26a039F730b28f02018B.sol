// SPDX-License-Identifier: MIT


// 

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// 

pragma solidity ^0.8.0;


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// 

pragma solidity ^0.8.0;




/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// 

pragma solidity ^0.8.0;




/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}

// 

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// 

pragma solidity ^0.8.0;



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// Copyright 2021 Cartesi Pte. Ltd.

// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy of the
// License at http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

pragma solidity ^0.8.0;








contract StakingPoolData is
    Initializable,
    PausableUpgradeable,
    OwnableUpgradeable
{
    using WadRayMath for uint256;
    uint256 public shares; // total number of shares
    uint256 public amount; // amount of staked tokens (no matter where it is)
    uint256 public requiredLiquidity; // amount of required tokens for withdraw requests

    IPoS public pos;

    struct UserBalance {
        uint256 balance; // amount of free tokens belonging to this user
        uint256 shares; // amount of shares belonging to this user
        uint256 depositTimestamp; // timestamp of when user deposited for the last time
    }
    mapping(address => UserBalance) public userBalance;

    function amountToShares(uint256 _amount) public view returns (uint256) {
        if (amount == 0) {
            // no shares yet, return 1 to 1 ratio
            return _amount.wad2ray();
        }
        return _amount.wmul(shares).wdiv(amount);
    }

    function sharesToAmount(uint256 _shares) public view returns (uint256) {
        if (shares == 0) {
            // no shares yet, return 1 to 1 ratio
            return _shares.ray2wad();
        }
        return _shares.rmul(amount).rdiv(shares);
    }
}

// Copyright 2021 Cartesi Pte. Ltd.

// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy of the
// License at http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

pragma solidity >=0.7.0;

interface StakingPoolManagement {
    
    function setName(string memory name) external;

    
    function pause() external;

    
    function unpause() external;

    
    event StakingPoolRenamed(string name);
}

// Copyright 2021 Cartesi Pte. Ltd.

// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy of the
// License at http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

pragma solidity >=0.7.0;




/// after a block is produced.
/// A commission is taken from the block reward, and the remaining stays in the pool,
/// raising the pool share value, and being further staked.
interface StakingPoolProducer {
    
    /// updates internal states of the pool
    
    function produceBlock(uint256 _index) external returns (bool);

    
    /// reward is the block reward
    /// commission is how much CTSI is directed to the pool owner
    event BlockProduced(uint256 reward, uint256 commission);
}

// Copyright 2021 Cartesi Pte. Ltd.

// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy of the
// License at http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

pragma solidity >=0.7.0;




/// including staking, unstaking and withdrawing.
/// Tokens staked by pool users will stay at the pool until the pool owner decides to
/// stake them in the staking contract. On the other hand, tokens unstaked by pool users
/// are added to a required liquidity accumulator, and must be unstaked and withdrawn from
/// the staking contract.
interface StakingPoolStaking {
    
    /// If the pool has more liquidity then necessary, it stakes tokens.
    /// If the pool has less liquidity then necessary, and has not started an unstake, it unstakes.
    /// If the pool has less liquity than necessary, and has started an unstake, it withdraws if possible.
    function rebalance() external;

    
    /// staking operation on the main Staking contract
    
    
    
    function amounts()
        external
        view
        returns (
            uint256 stake,
            uint256 unstake,
            uint256 withdraw
        );
}

// Copyright 2021 Cartesi Pte. Ltd.

// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy of the
// License at http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

pragma solidity >=0.7.0;




/// including staking, unstaking and withdrawing. A pool user always holds pool shares.
/// When a user stakes tokens, he immediately receive shares. When he unstakes shares
/// he is asking to release tokens. Those tokens need to be withdrawn by an additional
/// call to withdraw()
interface StakingPoolUser {
    
    
    function deposit(uint256 amount) external;

    
    
    function stake(uint256 amount) external;

    
    
    function unstake(uint256 shares) external;

    
    
    function withdraw(uint256 amount) external;

    
    
    
    function getWithdrawBalance() external returns (uint256);

    
    
    
    
    event Deposit(address indexed user, uint256 amount, uint256 stakeTimestamp);

    
    
    
    
    event Stake(address indexed user, uint256 amount, uint256 shares);

    
    
    
    
    event Unstake(address indexed user, uint256 amount, uint256 shares);

    
    
    
    event Withdraw(address indexed user, uint256 amount);
}

// Copyright 2021 Cartesi Pte. Ltd.

// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy of the
// License at http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

pragma solidity >=0.7.0;

interface StakingPoolWorker {
    
    function selfhire() external payable;

    
    
    function hire(address payable workerAddress) external payable;

    
    
    function cancelHire(address workerAddress) external;

    
    
    
    function retire(address payable workerAddress) external;
}

pragma solidity ^0.8.4;



contract Controllable is Ownable {
    mapping(address => bool) public controllers;

    event ControllerChanged(address indexed controller, bool enabled);

    modifier onlyController {
        require(
            controllers[msg.sender],
            "Controllable: Caller is not a controller"
        );
        _;
    }

    function setController(address controller, bool enabled) public onlyOwner {
        controllers[controller] = enabled;
        emit ControllerChanged(controller, enabled);
    }
}

// Copyright 2021 Cartesi Pte. Ltd.

// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy of the
// License at http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

pragma solidity ^0.8.0;








contract StakingPoolManagementImpl is StakingPoolManagement, StakingPoolData {
    bytes32 private constant ADDR_REVERSE_NODE =
        0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;

    ENS public immutable ens;
    StakingPoolFactory public factory;

    // all immutable variables can stay at the constructor
    constructor(address _ens) initializer {
        require(_ens != address(0), "parameter can not be zero address");
        ens = ENS(_ens);

        // make sure reference code is pause so no one stake to it
        _pause();
    }

    function __StakingPoolManagementImpl_init() internal {
        factory = StakingPoolFactory(msg.sender);
    }

    
    function setName(string memory name) external override onlyOwner {
        ReverseRegistrar ensReverseRegistrar = ReverseRegistrar(
            ens.owner(ADDR_REVERSE_NODE)
        );

        // call the ENS reverse registrar resolving pool address to name
        ensReverseRegistrar.setName(name);

        // emit event, for subgraph processing
        emit StakingPoolRenamed(name);
    }

    
    function pause() external override onlyOwner {
        _pause();
    }

    
    function unpause() external override onlyOwner {
        _unpause();
    }
}

// Copyright 2021 Cartesi Pte. Ltd.

// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy of the
// License at http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

pragma solidity ^0.8.0;








contract StakingPoolProducerImpl is StakingPoolProducer, StakingPoolData {
    IERC20 public immutable ctsi;
    Fee public fee;

    constructor(address _ctsi) {
        ctsi = IERC20(_ctsi);
    }

    function __StakingPoolProducer_init(address _fee, address _pos) internal {
        fee = Fee(_fee);
        pos = IPoS(_pos);
    }

    
    /// updates internal states of the pool
    
    function produceBlock(uint256 _index) external override returns (bool) {
        IRewardManager rewardManager = IRewardManager(
            pos.getRewardManagerAddress(_index)
        );

        // get block reward
        uint256 reward = rewardManager.getCurrentReward();

        // produce block in the PoS
        require(
            pos.produceBlock(_index),
            "StakingPoolProducerImpl: failed to produce block"
        );

        // calculate pool commission
        uint256 commission = fee.getCommission(_index, reward);
        require(
            commission <= reward,
            "StakingPoolProducerImpl: commission is greater than block reward"
        );

        uint256 remainingReward = reward - commission; // this is a safety check
        // if commission is over the reward amount, it will underflow

        // increase pool amount, this will change the pool exchange rate
        amount += remainingReward;

        // send commission directly to pool owner
        if (commission > 0) {
            require(
                ctsi.transfer(owner(), commission),
                "StakingPoolProducerImpl: failed to transfer commission"
            );
        }

        // remainingReward is part of the balance, so it will automatically be staked by StakingPoolStakingImpl
        emit BlockProduced(reward, commission);

        return true;
    }
}

// Copyright 2021 Cartesi Pte. Ltd.

// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy of the
// License at http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

pragma solidity ^0.8.0;







/// It makes sure that there is enough liquidity in the pool to fullfil all unstake request from
/// users, by requesting to withdraw or unstake from Staking contract.
/// The remaining balance is staked.
contract StakingPoolStakingImpl is StakingPoolStaking, StakingPoolData {
    IERC20 private immutable ctsi;
    IStaking private immutable staking;

    constructor(address _ctsi, address _staking) {
        ctsi = IERC20(_ctsi);
        staking = IStaking(_staking);
    }

    function __StakingPoolStaking_init() internal {
        require(
            ctsi.approve(address(staking), type(uint256).max),
            "Failed to approve CTSI for staking contract"
        );
    }

    function rebalance() external override {
        // get amounts
        (uint256 _stake, uint256 _unstake, uint256 _withdraw) = amounts();

        if (_stake > 0) {
            // we can stake
            staking.stake(_stake);
        }

        if (_unstake > 0) {
            // we need to provide liquidity
            staking.unstake(_unstake);
        }

        if (_withdraw > 0) {
            // we need to provide liquidity
            staking.withdraw(_withdraw);
        }
    }

    function amounts()
        public
        view
        override
        returns (
            uint256 stake,
            uint256 unstake,
            uint256 withdraw
        )
    {
        // get this contract balance first
        uint256 balance = ctsi.balanceOf(address(this));

        if (balance > requiredLiquidity) {
            // we have spare tokens we can stake
            // check if there is anything already maturing, to avoid reset the maturation clock
            uint256 maturing = staking.getMaturingBalance(address(this));
            if (maturing == 0) {
                // nothing is maturing, we can stake the balance, preserving the liquidity
                stake = balance - requiredLiquidity;
            }
        } else if (requiredLiquidity > balance) {
            // we don't have enough tokens to provide liquidity
            uint256 missingLiquidity = requiredLiquidity - balance;

            // let's first check releasing balance
            uint256 releasing = staking.getReleasingBalance(address(this));
            if (releasing > 0) {
                // some is already releasing

                // let's check timestamp to see if we can withdrawn it
                uint256 timestamp = staking.getReleasingTimestamp(
                    address(this)
                );
                if (timestamp < block.timestamp) {
                    // there it is, let's grab it
                    withdraw = releasing;
                }

                // requiredLiquidity may be more than what is already releasing
                // but we won't unstake more to not reset the clock
            } else {
                // no unstake maturing, let's queue some
                unstake = missingLiquidity;
            }
        } else {
            // balance is exactly required liquidity, we can't move any tokens around
        }
    }
}

// Copyright 2021 Cartesi Pte. Ltd.

// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy of the
// License at http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

pragma solidity ^0.8.0;





contract StakingPoolUserImpl is StakingPoolUser, StakingPoolData {
    IERC20 private immutable ctsi;
    uint256 public immutable lockTime;

    
    
    
    constructor(address _ctsi, uint256 _lockTime) {
        ctsi = IERC20(_ctsi);
        lockTime = _lockTime;
    }

    function deposit(uint256 _amount) external override whenNotPaused {
        // transfer tokens from caller to this contract
        // user must have approved the transfer a priori
        // tokens will be lying around, until actually staked by pool owner at a later time
        require(
            _amount > 0,
            "StakingPoolUserImpl: amount must be greater than 0"
        );

        // add tokens to user's balance
        UserBalance storage user = userBalance[msg.sender];
        user.balance += _amount;

        // reset deposit timestamp
        user.depositTimestamp = block.timestamp;

        // reserve the balance as required liquidity (don't stake to Staking)
        requiredLiquidity += _amount;

        require(
            ctsi.transferFrom(msg.sender, address(this), _amount),
            "StakingPoolUserImpl: failed to transfer tokens"
        );

        // emit event containing user and amount
        emit Deposit(msg.sender, _amount, block.timestamp + lockTime);
    }

    
    
    function stake(uint256 _amount) external override whenNotPaused {
        // get user balance
        UserBalance storage user = userBalance[msg.sender];

        // transfer tokens from caller to this contract
        // user must have approved the transfer a priori
        // tokens will be lying around, until actually staked by pool owner at a later time
        require(
            _amount > 0,
            "StakingPoolUserImpl: amount must be greater than 0"
        );
        require(
            _amount <= user.balance,
            "StakingPoolUserImpl: not enough tokens available for staking"
        );

        // check if user can already stake or if it's too early
        require(
            block.timestamp >= user.depositTimestamp + lockTime,
            "StakingPoolUserImpl: not enough time has passed since last deposit"
        );

        // calculate amount of shares as of now
        uint256 _shares = amountToShares(_amount);

        // make sure he get at least one share (rounding errors)
        require(
            _shares > 0,
            "StakingPoolUserImpl: stake not enough to emit 1 share"
        );

        // allocate new shares to user, immediately
        user.shares += _shares;
        user.balance -= _amount;

        // increase total shares and amount (not changing share value)
        amount += _amount;
        shares += _shares;

        // remove from required liquidity, as it's moving to Staking
        requiredLiquidity -= _amount;

        // emit event containing user, amount, shares and unlock time
        emit Stake(msg.sender, _amount, _shares);
    }

    
    /// want to unstake. Estimated value is then emitted on Unstake event
    function unstake(uint256 _shares) external override {
        UserBalance storage user = userBalance[msg.sender];

        // check if shares is valid value
        require(_shares > 0, "StakingPoolUserImpl: invalid amount of shares");

        // check if user has enough shares to unstake
        require(
            user.shares >= _shares,
            "StakingPoolUserImpl: insufficient shares"
        );

        // reduce user number of shares
        user.shares -= _shares;

        // calculate amount of tokens from shares
        uint256 _amount = sharesToAmount(_shares);

        // reduce total shares and amount
        shares -= _shares;
        amount -= _amount;

        // add amount user can withdraw (if available)
        user.balance += _amount;

        // increase required liquidity
        requiredLiquidity += _amount;

        // emit event containing user, amount and shares
        emit Unstake(msg.sender, _amount, _shares);
    }

    
    
    function withdraw(uint256 _amount) external override {
        UserBalance storage user = userBalance[msg.sender];

        // check user released value
        require(
            user.balance > 0,
            "StakingPoolUserImpl: no balance to withdraw"
        );

        // clear user released value
        user.balance -= _amount; // if _amount >  user.balance this will revert

        // decrease required liquidity
        requiredLiquidity -= _amount; // if _amount >  requiredLiquidity this will revert

        // transfer token back to user
        require(
            ctsi.transfer(msg.sender, _amount),
            "StakingPoolUserImpl: failed to transfer tokens"
        );

        // emit event containing user and token amount
        emit Withdraw(msg.sender, _amount);
    }

    function getWithdrawBalance() external view override returns (uint256) {
        UserBalance storage user = userBalance[msg.sender];

        // get maximum amount user can withdraw (his balance)
        uint256 _amount = user.balance;

        // check contract balance
        uint256 balance = ctsi.balanceOf(address(this));

        // he can withdraw whatever is available at the contract, up to his balance
        return balance >= _amount ? _amount : balance;
    }
}

// Copyright 2021 Cartesi Pte. Ltd.

// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy of the
// License at http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

pragma solidity ^0.8.0;





contract StakingPoolWorkerImpl is StakingPoolWorker, StakingPoolData {
    IWorkerManagerAuthManager immutable workerManager;

    // all immutable variables can stay at the constructor
    constructor(address _workerManager) {
        require(
            _workerManager != address(0),
            "parameter can not be zero address"
        );
        workerManager = IWorkerManagerAuthManager(_workerManager);
    }

    receive() external payable {}

    function __StakingPoolWorkerImpl_update(address _pos) internal {
        workerManager.authorize(address(this), _pos);
        pos = IPoS(_pos);
    }

    
    function selfhire() external payable override {
        // pool needs to be both user and worker
        workerManager.hire{value: msg.value}(payable(address(this)));
        workerManager.authorize(address(this), address(pos));
        workerManager.acceptJob();
        payable(msg.sender).transfer(msg.value);
    }

    
    
    function hire(address payable workerAddress)
        external
        payable
        override
        onlyOwner
    {
        workerManager.hire{value: msg.value}(workerAddress);
        workerManager.authorize(workerAddress, address(pos));
    }

    
    
    function cancelHire(address workerAddress) external override onlyOwner {
        workerManager.cancelHire(workerAddress);
    }

    
    
    
    function retire(address payable workerAddress) external override onlyOwner {
        workerManager.retire(workerAddress);
    }
}

// Copyright 2021 Cartesi Pte. Ltd.

// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy of the
// License at http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

pragma solidity >=0.7.0;










/// It is broken down into the following sub-interfaces:
/// - StakingPoolManagement: management operations on the pool, called by the owner
/// - StakingPoolProducer: operations related to block production
/// - StakingPoolStaking: interaction between the pool and the staking contract
/// - StakingPoolUser: interaction between the pool users and the pool
/// - StakingPoolWorker: interaction between the pool and the worker node
interface StakingPool is
    StakingPoolManagement,
    StakingPoolProducer,
    StakingPoolStaking,
    StakingPoolUser,
    StakingPoolWorker
{
    
    function initialize(address fee, address _pos) external;

    
    function transferOwnership(address newOwner) external;

    
    function update() external;
}
// Copyright 2021 Cartesi Pte. Ltd.

// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy of the
// License at http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


pragma solidity >=0.7.0 <0.9.0;

interface IPoS {
    
    
    
    function produceBlock(uint256 _index) external returns (bool);

    
    
    
    function getRewardManagerAddress(uint256 _index)
        external
        view
        returns (address);

    
    
    
    function getBlockSelectorAddress(uint256 _index)
        external
        view
        returns (address);

    
    
    
    function getBlockSelectorIndex(uint256 _index)
        external
        view
        returns (uint256);

    
    
    
    function getStakingAddress(uint256 _index) external view returns (address);

    
    
    
    
    
    
    function getState(uint256 _index, address _user)
        external
        view
        returns (
            bool,
            address,
            uint256
        );

    function terminate(uint256 _index) external;
}

// Copyright 2021 Cartesi Pte. Ltd.

// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy of the
// License at http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


pragma solidity >=0.7.0 <0.9.0;

interface IRewardManager {
    
    
    
    
    function reward(address _address, uint256 _amount) external;

    
    function getBalance() external view returns (uint256);

    
    function getCurrentReward() external view returns (uint256);
}

// Copyright 2021 Cartesi Pte. Ltd.

// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy of the
// License at http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


pragma solidity >=0.7.0 <0.9.0;

interface IStaking {
    
    
    
    function getStakedBalance(address _userAddress)
        external
        view
        returns (uint256);

    
    
    function getMaturingTimestamp(address _userAddress)
        external
        view
        returns (uint256);

    
    
    function getReleasingTimestamp(address _userAddress)
        external
        view
        returns (uint256);

    
    
    function getMaturingBalance(address _userAddress)
        external
        view
        returns (uint256);

    
    
    function getReleasingBalance(address _userAddress)
        external
        view
        returns (uint256);

    
    ///         balance after timeToStake days
    
    function stake(uint256 _amount) external;

    
    ///         be released after timeToRelease seconds, if the
    ///         function withdraw is called.
    
    function unstake(uint256 _amount) external;

    
    
    function withdraw(uint256 _amount) external;

    // events
    
    
    
    
    event Stake(address indexed user, uint256 amount, uint256 maturationDate);

    
    
    
    
    event Unstake(address indexed user, uint256 amount, uint256 maturationDate);

    
    
    
    event Withdraw(address indexed user, uint256 amount);
}

// Copyright 2021 Cartesi Pte. Ltd.

// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy of the
// License at http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.



pragma solidity >=0.7.0 <0.9.0;

interface IWorkerManagerAuthManager {
    
    
    function hire(address payable workerAddress) external payable;

    
    
    function cancelHire(address workerAddress) external;

    
    
    
    function retire(address payable workerAddress) external;

    
    
    
    function authorize(address _workerAddress, address _dappAddress) external;

    
    function acceptJob() external;

    
    function rejectJob() external payable;
}

pragma solidity >=0.8.4;

interface ENS {

    // Logged when the owner of a node assigns a new owner to a subnode.
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    // Logged when the owner of a node transfers ownership to a new account.
    event Transfer(bytes32 indexed node, address owner);

    // Logged when the resolver for a node changes.
    event NewResolver(bytes32 indexed node, address resolver);

    // Logged when the TTL of a node changes
    event NewTTL(bytes32 indexed node, uint64 ttl);

    // Logged when an operator is added or removed.
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function setRecord(bytes32 node, address owner, address resolver, uint64 ttl) external virtual;
    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external virtual;
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external virtual returns(bytes32);
    function setResolver(bytes32 node, address resolver) external virtual;
    function setOwner(bytes32 node, address owner) external virtual;
    function setTTL(bytes32 node, uint64 ttl) external virtual;
    function setApprovalForAll(address operator, bool approved) external virtual;
    function owner(bytes32 node) external virtual view returns (address);
    function resolver(bytes32 node) external virtual view returns (address);
    function ttl(bytes32 node) external virtual view returns (uint64);
    function recordExists(bytes32 node) external virtual view returns (bool);
    function isApprovedForAll(address owner, address operator) external virtual view returns (bool);
}

pragma solidity >=0.8.4;





abstract contract NameResolver {
    function setName(bytes32 node, string memory name) public virtual;
}

bytes32 constant lookup = 0x3031323334353637383961626364656600000000000000000000000000000000;

bytes32 constant ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;

// namehash('addr.reverse')

contract ReverseRegistrar is Ownable, Controllable {
    ENS public ens;
    NameResolver public defaultResolver;

    event ReverseClaimed(address indexed addr, bytes32 indexed node);

    /**
     * @dev Constructor
     * @param ensAddr The address of the ENS registry.
     * @param resolverAddr The address of the default reverse resolver.
     */
    constructor(ENS ensAddr, NameResolver resolverAddr) {
        ens = ensAddr;
        defaultResolver = resolverAddr;

        // Assign ownership of the reverse record to our deployer
        ReverseRegistrar oldRegistrar = ReverseRegistrar(
            ens.owner(ADDR_REVERSE_NODE)
        );
        if (address(oldRegistrar) != address(0x0)) {
            oldRegistrar.claim(msg.sender);
        }
    }

    modifier authorised(address addr) {
        require(
            addr == msg.sender ||
                controllers[msg.sender] ||
                ens.isApprovedForAll(addr, msg.sender) ||
                ownsContract(addr),
            "Caller is not a controller or authorised by address or the address itself"
        );
        _;
    }

    /**
     * @dev Transfers ownership of the reverse ENS record associated with the
     *      calling account.
     * @param owner The address to set as the owner of the reverse record in ENS.
     * @return The ENS node hash of the reverse record.
     */
    function claim(address owner) public returns (bytes32) {
        return _claimWithResolver(msg.sender, owner, address(0x0));
    }

    /**
     * @dev Transfers ownership of the reverse ENS record associated with the
     *      calling account.
     * @param addr The reverse record to set
     * @param owner The address to set as the owner of the reverse record in ENS.
     * @return The ENS node hash of the reverse record.
     */
    function claimForAddr(address addr, address owner)
        public
        authorised(addr)
        returns (bytes32)
    {
        return _claimWithResolver(addr, owner, address(0x0));
    }

    /**
     * @dev Transfers ownership of the reverse ENS record associated with the
     *      calling account.
     * @param owner The address to set as the owner of the reverse record in ENS.
     * @param resolver The address of the resolver to set; 0 to leave unchanged.
     * @return The ENS node hash of the reverse record.
     */
    function claimWithResolver(address owner, address resolver)
        public
        returns (bytes32)
    {
        return _claimWithResolver(msg.sender, owner, resolver);
    }

    /**
     * @dev Transfers ownership of the reverse ENS record specified with the
     *      address provided
     * @param addr The reverse record to set
     * @param owner The address to set as the owner of the reverse record in ENS.
     * @param resolver The address of the resolver to set; 0 to leave unchanged.
     * @return The ENS node hash of the reverse record.
     */
    function claimWithResolverForAddr(
        address addr,
        address owner,
        address resolver
    ) public authorised(addr) returns (bytes32) {
        return _claimWithResolver(addr, owner, resolver);
    }

    /**
     * @dev Sets the `name()` record for the reverse ENS record associated with
     * the calling account. First updates the resolver to the default reverse
     * resolver if necessary.
     * @param name The name to set for this address.
     * @return The ENS node hash of the reverse record.
     */
    function setName(string memory name) public returns (bytes32) {
        bytes32 node = _claimWithResolver(
            msg.sender,
            address(this),
            address(defaultResolver)
        );
        defaultResolver.setName(node, name);
        return node;
    }

    /**
     * @dev Sets the `name()` record for the reverse ENS record associated with
     * the account provided. First updates the resolver to the default reverse
     * resolver if necessary.
     * Only callable by controllers and authorised users
     * @param addr The reverse record to set
     * @param owner The owner of the reverse node
     * @param name The name to set for this address.
     * @return The ENS node hash of the reverse record.
     */
    function setNameForAddr(
        address addr,
        address owner,
        string memory name
    ) public authorised(addr) returns (bytes32) {
        bytes32 node = _claimWithResolver(
            addr,
            address(this),
            address(defaultResolver)
        );
        defaultResolver.setName(node, name);
        ens.setSubnodeOwner(ADDR_REVERSE_NODE, sha3HexAddress(addr), owner);
        return node;
    }

    /**
     * @dev Returns the node hash for a given account's reverse records.
     * @param addr The address to hash
     * @return The ENS node hash.
     */
    function node(address addr) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(ADDR_REVERSE_NODE, sha3HexAddress(addr))
            );
    }

    /**
     * @dev An optimised function to compute the sha3 of the lower-case
     *      hexadecimal representation of an Ethereum address.
     * @param addr The address to hash
     * @return ret The SHA3 hash of the lower-case hexadecimal encoding of the
     *         input address.
     */
    function sha3HexAddress(address addr) private pure returns (bytes32 ret) {
        assembly {
            for {
                let i := 40
            } gt(i, 0) {

            } {
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
            }

            ret := keccak256(0, 40)
        }
    }

    /* Internal functions */

    function _claimWithResolver(
        address addr,
        address owner,
        address resolver
    ) internal returns (bytes32) {
        bytes32 label = sha3HexAddress(addr);
        bytes32 node = keccak256(abi.encodePacked(ADDR_REVERSE_NODE, label));
        address currentResolver = ens.resolver(node);
        bool shouldUpdateResolver = (resolver != address(0x0) &&
            resolver != currentResolver);
        address newResolver = shouldUpdateResolver ? resolver : currentResolver;

        ens.setSubnodeRecord(ADDR_REVERSE_NODE, label, owner, newResolver, 0);

        emit ReverseClaimed(addr, node);

        return node;
    }

    function ownsContract(address addr) internal view returns (bool) {
        try Ownable(addr).owner() returns (address owner) {
            return owner == msg.sender;
        } catch {
            return false;
        }
    }
}

// 

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

// Copyright 2021 Cartesi Pte. Ltd.

// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy of the
// License at http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

pragma solidity ^0.8.0;









contract StakingPoolImpl is
    StakingPool,
    StakingPoolData,
    StakingPoolManagementImpl,
    StakingPoolProducerImpl,
    StakingPoolStakingImpl,
    StakingPoolUserImpl,
    StakingPoolWorkerImpl
{
    constructor(
        address _ctsi,
        address _staking,
        address _workerManager,
        address _ens,
        uint256 _stakeLock
    )
        StakingPoolManagementImpl(_ens)
        StakingPoolProducerImpl(_ctsi)
        StakingPoolStakingImpl(_ctsi, _staking)
        StakingPoolUserImpl(_ctsi, _stakeLock)
        StakingPoolWorkerImpl(_workerManager)
    {}

    function initialize(address _fee, address _pos)
        external
        override
        initializer
    {
        __Pausable_init();
        __Ownable_init();
        __StakingPoolProducer_init(_fee, _pos);
        __StakingPoolStaking_init();
        __StakingPoolManagementImpl_init();
    }

    
    function update() external override onlyOwner {
        address _pos = factory.getPoS();
        __StakingPoolWorkerImpl_update(_pos);
    }

    function transferOwnership(address newOwner)
        public
        override(StakingPool, OwnableUpgradeable)
    {
        OwnableUpgradeable.transferOwnership(newOwner);
    }
}

// Copyright 2021 Cartesi Pte. Ltd.

// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy of the
// License at http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

pragma solidity >=0.7.0 <0.9.0;




interface Fee {
    
    
    function getCommission(uint256 posIndex, uint256 rewardAmount)
        external
        view
        returns (uint256);
}

// Copyright 2021 Cartesi Pte. Ltd.

// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy of the
// License at http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

pragma solidity >=0.7.0;

interface StakingPoolFactory {
    
    /// emits NewFlatRateCommissionStakingPool with the parameters of the new pool
    
    function createFlatRateCommission(uint256 commission)
        external
        payable
        returns (address);

    
    /// emits NewGasTaxCommissionStakingPool with the parameters of the new pool
    
    function createGasTaxCommission(uint256 gas)
        external
        payable
        returns (address);

    
    
    function getPoS() external view returns (address _pos);

    
    
    
    event NewFlatRateCommissionStakingPool(address indexed pool, address fee);

    
    
    
    event NewGasTaxCommissionStakingPool(address indexed pool, address fee);
}

// Copyright 2021 Cartesi Pte. Ltd.

// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy of the
// License at http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.



pragma solidity ^0.8.0;

library WadRayMath {
    uint256 internal constant WAD = 1e18;
    uint256 internal constant RAY = 1e27;
    uint256 internal constant RATIO = 1e9;

    function wmul(uint256 a, uint256 b) internal pure returns (uint256) {
        return ((WAD / 2) + (a * b)) / WAD;
    }

    function wdiv(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 halfB = b / 2;
        return (halfB + (a * WAD)) / b;
    }

    function rmul(uint256 a, uint256 b) internal pure returns (uint256) {
        return ((RAY / 2) + (a * b)) / RAY;
    }

    function rdiv(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 halfB = b / 2;
        return (halfB + (a * RAY)) / b;
    }

    function ray2wad(uint256 a) internal pure returns (uint256) {
        uint256 halfRatio = RATIO / 2;
        return (halfRatio + a) / RATIO;
    }

    function wad2ray(uint256 a) internal pure returns (uint256) {
        return a * RATIO;
    }
}
