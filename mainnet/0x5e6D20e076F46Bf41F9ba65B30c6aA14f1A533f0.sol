// SPDX-License-Identifier: Apache-2.0

/**
 *Submitted for verification at Etherscan.io on 2022-10-19
*/

// 
// File: https://github.com/overlay-market/council/blob/main/contracts/interfaces/IVotingVault.sol


pragma solidity ^0.8.3;

interface IVotingVault {
    
    
    
    
    
    function queryVotePower(
        address user,
        uint256 blockNumber,
        bytes calldata extraData
    ) external returns (uint256);
}

// File: https://github.com/overlay-market/council/blob/main/contracts/libraries/VestingVaultStorage.sol


pragma solidity ^0.8.3;

// Copy of `Storage` with modified scope to match the VestingVault requirements
// This library allows for secure storage pointers across proxy implementations
// It will return storage pointers based on a hashed name and type string.
library VestingVaultStorage {
    // This library follows a pattern which if solidity had higher level
    // type or macro support would condense quite a bit.

    // Each basic type which does not support storage locations is encoded as
    // a struct of the same name capitalized and has functions 'load' and 'set'
    // which load the data and set the data respectively.

    // All types will have a function of the form 'typename'Ptr('name') -> storage ptr
    // which will return a storage version of the type with slot which is the hash of
    // the variable name and type string. This pointer allows easy state management between
    // upgrades and overrides the default solidity storage slot system.

    // A struct which represents 1 packed storage location (Grant)
    struct Grant {
        uint128 allocation;
        uint128 withdrawn;
        uint128 created;
        uint128 expiration;
        uint128 cliff;
        uint128 latestVotingPower;
        address delegatee;
        uint256[2] range;
    }

    
    
    
    function mappingAddressToGrantPtr(string memory name)
        internal
        pure
        returns (mapping(address => Grant) storage data)
    {
        bytes32 typehash = keccak256("mapping(address => Grant)");
        bytes32 offset = keccak256(abi.encodePacked(typehash, name));
        assembly {
            data.slot := offset
        }
    }
}

// File: https://github.com/overlay-market/council/blob/main/contracts/libraries/Storage.sol


pragma solidity ^0.8.3;

// This library allows for secure storage pointers across proxy implementations
// It will return storage pointers based on a hashed name and type string.
library Storage {
    // This library follows a pattern which if solidity had higher level
    // type or macro support would condense quite a bit.

    // Each basic type which does not support storage locations is encoded as
    // a struct of the same name capitalized and has functions 'load' and 'set'
    // which load the data and set the data respectively.

    // All types will have a function of the form 'typename'Ptr('name') -> storage ptr
    // which will return a storage version of the type with slot which is the hash of
    // the variable name and type string. This pointer allows easy state management between
    // upgrades and overrides the default solidity storage slot system.

    
    struct Address {
        address data;
    }

    
    ///         pointer for its container.
    
    
    function addressPtr(string memory name)
        internal
        pure
        returns (Address storage data)
    {
        bytes32 typehash = keccak256("address");
        bytes32 offset = keccak256(abi.encodePacked(typehash, name));
        assembly {
            data.slot := offset
        }
    }

    
    
    
    function load(Address storage input) internal view returns (address) {
        return input.data;
    }

    
    
    
    function set(Address storage input, address to) internal {
        input.data = to;
    }

    
    struct Uint256 {
        uint256 data;
    }

    
    ///         pointer for its container.
    
    
    function uint256Ptr(string memory name)
        internal
        pure
        returns (Uint256 storage data)
    {
        bytes32 typehash = keccak256("uint256");
        bytes32 offset = keccak256(abi.encodePacked(typehash, name));
        assembly {
            data.slot := offset
        }
    }

    
    
    
    function load(Uint256 storage input) internal view returns (uint256) {
        return input.data;
    }

    
    
    
    function set(Uint256 storage input, uint256 to) internal {
        input.data = to;
    }

    
    
    
    function mappingAddressToUnit256Ptr(string memory name)
        internal
        pure
        returns (mapping(address => uint256) storage data)
    {
        bytes32 typehash = keccak256("mapping(address => uint256)");
        bytes32 offset = keccak256(abi.encodePacked(typehash, name));
        assembly {
            data.slot := offset
        }
    }

    
    
    
    function mappingAddressToUnit256ArrayPtr(string memory name)
        internal
        pure
        returns (mapping(address => uint256[]) storage data)
    {
        bytes32 typehash = keccak256("mapping(address => uint256[])");
        bytes32 offset = keccak256(abi.encodePacked(typehash, name));
        assembly {
            data.slot := offset
        }
    }

    
    
    
    
    function getPtr(string memory typeString, string memory name)
        external
        pure
        returns (uint256)
    {
        bytes32 typehash = keccak256(abi.encodePacked(typeString));
        bytes32 offset = keccak256(abi.encodePacked(typehash, name));
        return (uint256)(offset);
    }

    // A struct which represents 1 packed storage location with a compressed
    // address and uint96 pair
    struct AddressUint {
        address who;
        uint96 amount;
    }

    
    
    
    function mappingAddressToPackedAddressUint(string memory name)
        internal
        pure
        returns (mapping(address => AddressUint) storage data)
    {
        bytes32 typehash = keccak256("mapping(address => AddressUint)");
        bytes32 offset = keccak256(abi.encodePacked(typehash, name));
        assembly {
            data.slot := offset
        }
    }
}

// File: https://github.com/overlay-market/council/blob/main/contracts/libraries/History.sol


pragma solidity ^0.8.3;


// This library is an assembly optimized storage library which is designed
// to track timestamp history in a struct which uses hash derived pointers.
// WARNING - Developers using it should not access the underlying storage
// directly since we break some assumptions of high level solidity. Please
// note this library also increases the risk profile of memory manipulation
// please be cautious in your usage of uninitialized memory structs and other
// anti patterns.
library History {
    // The storage layout of the historical array looks like this
    // [(128 bit min index)(128 bit length)] [0][0] ... [(64 bit block num)(192 bit data)] .... [(64 bit block num)(192 bit data)]
    // We give the option to the invoker of the search function the ability to clear
    // stale storage. To find data we binary search for the block number we need
    // This library expects the blocknumber indexed data to be pushed in ascending block number
    // order and if data is pushed with the same blocknumber it only retains the most recent.
    // This ensures each blocknumber is unique and contains the most recent data at the end
    // of whatever block it indexes [as long as that block is not the current one].

    // A struct which wraps a memory pointer to a string and the pointer to storage
    // derived from that name string by the storage library
    // WARNING - For security purposes never directly construct this object always use load
    struct HistoricalBalances {
        string name;
        // Note - We use bytes32 to reduce how easy this is to manipulate in high level sol
        bytes32 cachedPointer;
    }

    
    
    ///             with the same name work on the same storage.
    
    function load(string memory name)
        internal
        pure
        returns (HistoricalBalances memory)
    {
        mapping(address => uint256[]) storage storageData =
            Storage.mappingAddressToUnit256ArrayPtr(name);
        bytes32 pointer;
        assembly {
            pointer := storageData.slot
        }
        return HistoricalBalances(name, pointer);
    }

    
    
    
    
    //       ARBITRARY DATA THEY MAY BE ABLE TO OVERWRITE ANY STORAGE IN THE CONTRACT.
    function _getMapping(bytes32 pointer)
        private
        pure
        returns (mapping(address => uint256[]) storage storageData)
    {
        assembly {
            storageData.slot := pointer
        }
    }

    
    ///         To prevent duplicate entries if the top of the array has the same blocknumber
    ///         the value is updated instead
    
    
    
    function push(
        HistoricalBalances memory wrapper,
        address who,
        uint256 data
    ) internal {
        // Check preconditions
        // OoB = Out of Bounds, short for contract bytecode size reduction
        require(data <= type(uint192).max, "OoB");
        // Get the storage this is referencing
        mapping(address => uint256[]) storage storageMapping =
            _getMapping(wrapper.cachedPointer);
        // Get the array we need to push to
        uint256[] storage storageData = storageMapping[who];
        // We load the block number and then shift it to be in the top 64 bits
        uint256 blockNumber = block.number << 192;
        // We combine it with the data, because of our require this will have a clean
        // top 64 bits
        uint256 packedData = blockNumber | data;
        // Load the array length
        (uint256 minIndex, uint256 length) = _loadBounds(storageData);
        // On the first push we don't try to load
        uint256 loadedBlockNumber = 0;
        if (length != 0) {
            (loadedBlockNumber, ) = _loadAndUnpack(storageData, length - 1);
        }
        // The index we push to, note - we use this pattern to not branch the assembly
        uint256 index = length;
        // If the caller is changing data in the same block we change the entry for this block
        // instead of adding a new one. This ensures each block numb is unique in the array.
        if (loadedBlockNumber == block.number) {
            index = length - 1;
        }
        // We use assembly to write our data to the index
        assembly {
            // Stores packed data in the equivalent of storageData[length]
            sstore(
                add(
                    // The start of the data slots
                    add(storageData.slot, 1),
                    // index where we store
                    index
                ),
                packedData
            )
        }
        // Reset the boundaries if they changed
        if (loadedBlockNumber != block.number) {
            _setBounds(storageData, minIndex, length + 1);
        }
    }

    
    
    
    
    function loadTop(HistoricalBalances memory wrapper, address who)
        internal
        view
        returns (uint256)
    {
        // Load the storage pointer
        uint256[] storage userData = _getMapping(wrapper.cachedPointer)[who];
        // Load the length
        (, uint256 length) = _loadBounds(userData);
        // If it's zero no data has ever been pushed so we return zero
        if (length == 0) {
            return 0;
        }
        // Load the current top
        (, uint256 storedData) = _loadAndUnpack(userData, length - 1);
        // and return it
        return (storedData);
    }

    
    ///         blocknumber.
    
    
    
    
    function find(
        HistoricalBalances memory wrapper,
        address who,
        uint256 blocknumber
    ) internal view returns (uint256) {
        // Get the storage this is referencing
        mapping(address => uint256[]) storage storageMapping =
            _getMapping(wrapper.cachedPointer);
        // Get the array we need to push to
        uint256[] storage storageData = storageMapping[who];
        // Pre load the bounds
        (uint256 minIndex, uint256 length) = _loadBounds(storageData);
        // Search for the blocknumber
        (, uint256 loadedData) =
            _find(storageData, blocknumber, 0, minIndex, length);
        // In this function we don't have to change the stored length data
        return (loadedData);
    }

    
    ///         Opportunistically clears any data older than staleBlock which is possible to clear.
    
    
    
    
    
    function findAndClear(
        HistoricalBalances memory wrapper,
        address who,
        uint256 blocknumber,
        uint256 staleBlock
    ) internal returns (uint256) {
        // Get the storage this is referencing
        mapping(address => uint256[]) storage storageMapping =
            _getMapping(wrapper.cachedPointer);
        // Get the array we need to push to
        uint256[] storage storageData = storageMapping[who];
        // Pre load the bounds
        (uint256 minIndex, uint256 length) = _loadBounds(storageData);
        // Search for the blocknumber
        (uint256 staleIndex, uint256 loadedData) =
            _find(storageData, blocknumber, staleBlock, minIndex, length);
        // We clear any data in the stale region
        // Note - Since find returns 0 if no stale data is found and we use > instead of >=
        //        this won't trigger if no stale data is found. Plus it won't trigger on minIndex == staleIndex
        //        == maxIndex and clear the whole array.
        if (staleIndex > minIndex) {
            // Delete the outdated stored info
            _clear(minIndex, staleIndex, storageData);
            // Reset the array info with stale index as the new minIndex
            _setBounds(storageData, staleIndex, length);
        }
        return (loadedData);
    }

    
    ///         Allows specification of a expiration stamp and returns the greatest examined index which is
    ///         found to be older than that stamp.
    
    
    
    
    
    
    function _find(
        uint256[] storage data,
        uint256 blocknumber,
        uint256 staleBlock,
        uint256 startingMinIndex,
        uint256 length
    ) private view returns (uint256, uint256) {
        // We explicitly revert on the reading of memory which is uninitialized
        require(length != 0, "uninitialized");
        // Do some correctness checks
        require(staleBlock <= blocknumber);
        require(startingMinIndex < length);
        // Load the bounds of our binary search
        uint256 maxIndex = length - 1;
        uint256 minIndex = startingMinIndex;
        uint256 staleIndex = 0;

        // We run a binary search on the block number fields in the array between
        // the minIndex and maxIndex. If we find indexes with blocknumber < staleBlock
        // we set staleIndex to them and return that data for an optional clearing step
        // in the calling function.
        while (minIndex != maxIndex) {
            // We use the ceil instead of the floor because this guarantees that
            // we pick the highest blocknumber less than or equal the requested one
            uint256 mid = (minIndex + maxIndex + 1) / 2;
            // Load and unpack the data in the midpoint index
            (uint256 pastBlock, uint256 loadedData) = _loadAndUnpack(data, mid);

            //  If we've found the exact block we are looking for
            if (pastBlock == blocknumber) {
                // Then we just return the data
                return (staleIndex, loadedData);

                // Otherwise if the loaded block is smaller than the block number
            } else if (pastBlock < blocknumber) {
                // Then we first check if this is possibly a stale block
                if (pastBlock < staleBlock) {
                    // If it is we mark it for clearing
                    staleIndex = mid;
                }
                // We then repeat the search logic on the indices greater than the midpoint
                minIndex = mid;

                // In this case the pastBlock > blocknumber
            } else {
                // We then repeat the search on the indices below the midpoint
                maxIndex = mid - 1;
            }
        }

        // We load at the final index of the search
        (uint256 _pastBlock, uint256 _loadedData) =
            _loadAndUnpack(data, minIndex);
        // This will only be hit if a user has misconfigured the stale index and then
        // tried to load father into the past than has been preserved
        require(_pastBlock <= blocknumber, "Search Failure");
        return (staleIndex, _loadedData);
    }

    
    
    
    
    function _clear(
        uint256 oldMin,
        uint256 newMin,
        uint256[] storage data
    ) private {
        // Correctness checks on this call
        require(oldMin <= newMin);
        // This function is private and trusted and should be only called by functions which ensure
        // that oldMin < newMin < length
        assembly {
            // The layout of arrays in solidity is [length][data]....[data] so this pointer is the
            // slot to write to data
            let dataLocation := add(data.slot, 1)
            // Loop through each index which is below new min and clear the storage
            // Note - Uses strict min so if given an input like oldMin = 5 newMin = 5 will be a no op
            for {
                let i := oldMin
            } lt(i, newMin) {
                i := add(i, 1)
            } {
                // store at the starting data pointer + i 256 bits of zero
                sstore(add(dataLocation, i), 0)
            }
        }
    }

    
    
    
    
    function _loadAndUnpack(uint256[] storage data, uint256 i)
        private
        view
        returns (uint256, uint256)
    {
        // This function is trusted and should only be called after checking data lengths
        // we use assembly for the sload to avoid reloading length.
        uint256 loaded;
        assembly {
            loaded := sload(add(add(data.slot, 1), i))
        }
        // Unpack the packed 64 bit block number and 192 bit data field
        return (
            loaded >> 192,
            loaded &
                0x0000000000000000ffffffffffffffffffffffffffffffffffffffffffffffff
        );
    }

    
    ///         would have length
    
    
    
    function _setBounds(
        uint256[] storage data,
        uint256 minIndex,
        uint256 length
    ) private {
        // Correctness check
        require(minIndex < length);

        assembly {
            // Ensure data cleanliness
            let clearedLength := and(
                length,
                0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff
            )
            // We move the min index into the top 128 bits by shifting it left by 128 bits
            let minInd := shl(128, minIndex)
            // We pack the data using binary or
            let packed := or(minInd, clearedLength)
            // We store in the packed data in the length field of this storage array
            sstore(data.slot, packed)
        }
    }

    
    
    
    
    function _loadBounds(uint256[] storage data)
        private
        view
        returns (uint256 minInd, uint256 length)
    {
        // Use assembly to manually load the length storage field
        uint256 packedData;
        assembly {
            packedData := sload(data.slot)
        }
        // We use a shift right to clear out the low order bits of the data field
        minInd = packedData >> 128;
        // We use a binary and to extract only the bottom 128 bits
        length =
            packedData &
            0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: github/overlay-market/council/contracts/vaults/VestingVault.sol


pragma solidity ^0.8.3;






abstract contract AbstractVestingVault is IVotingVault {
    // Bring our libraries into scope

    // NOTE: There is no emergency withdrawal, any funds not sent via deposit() are
    // unrecoverable by this version of the VestingVault

    // This contract has a privileged grant manager who can add grants or remove grants
    // It will not transfer in on each grant but rather check for solvency via state variables.

    // Immutables are in bytecode so don't need special storage treatment
    IERC20 public immutable token;

    // A constant which is how far back stale blocks are
    uint256 public immutable staleBlockLag;

    event VoteChange(address indexed to, address indexed from, int256 amount);

    
    
    
    constructor(IERC20 _token, uint256 _stale) {
        token = _token;
        staleBlockLag = _stale;
    }

    
    
    
    
    function initialize(address manager_, address timelock_) public {
        require(Storage.uint256Ptr("initialized").data == 0, "initialized");
        Storage.set(Storage.uint256Ptr("initialized"), 1);
        Storage.set(Storage.addressPtr("manager"), manager_);
        Storage.set(Storage.addressPtr("timelock"), timelock_);
        Storage.set(Storage.uint256Ptr("unvestedMultiplier"), 100);
    }

    // deposits mapping(address => Grant)
    
    
    /// be modified.
    
    function _grants()
        internal
        pure
        returns (mapping(address => VestingVaultStorage.Grant) storage)
    {
        // This call returns a storage mapping with a unique non overwrite-able storage location
        // which can be persisted through upgrades, even if they change storage layout
        return (VestingVaultStorage.mappingAddressToGrantPtr("grants"));
    }

    
    /// point of the range for each accepted grant
    
    
    function _loadBound() internal pure returns (Storage.Uint256 memory) {
        // This call returns a storage mapping with a unique non overwrite-able storage location
        // which can be persisted through upgrades, even if they change storage layout
        return Storage.uint256Ptr("bound");
    }

    
    
    /// for a future grant or withdrawn by the manager.
    
    function _unassigned() internal pure returns (Storage.Uint256 storage) {
        return Storage.uint256Ptr("unassigned");
    }

    
    
    
    function _manager() internal pure returns (Storage.Address memory) {
        return Storage.addressPtr("manager");
    }

    
    
    
    function _timelock() internal pure returns (Storage.Address memory) {
        return Storage.addressPtr("timelock");
    }

    
    
    /// unvested token as a percentage of a vested token. For example if
    /// unvested tokens have 50% voting power compared to vested ones, this value would be 50.
    /// This can be changed by governance in the future.
    
    function _unvestedMultiplier()
        internal
        pure
        returns (Storage.Uint256 memory)
    {
        return Storage.uint256Ptr("unvestedMultiplier");
    }

    modifier onlyManager() {
        require(msg.sender == _manager().data, "!manager");
        _;
    }

    modifier onlyTimelock() {
        require(msg.sender == _timelock().data, "!timelock");
        _;
    }

    
    
    
    function getGrant(address _who)
        external
        view
        returns (VestingVaultStorage.Grant memory)
    {
        return _grants()[_who];
    }

    
    
    /// while assigning a numerical range to the unwithdrawn granted tokens.
    function acceptGrant() public {
        // load the grant
        VestingVaultStorage.Grant storage grant = _grants()[msg.sender];
        uint256 availableTokens = grant.allocation - grant.withdrawn;

        // check that grant has unwithdrawn tokens
        require(availableTokens > 0, "no grant available");

        // transfer the token to the user
        token.transfer(msg.sender, availableTokens);
        // transfer from the user back to the contract
        token.transferFrom(msg.sender, address(this), availableTokens);

        uint256 bound = _loadBound().data;
        grant.range = [bound, bound + availableTokens];
        Storage.set(Storage.uint256Ptr("bound"), bound + availableTokens);
    }

    
    
    /// This potentially avoids the need for a delegation transaction by the grant recipient.
    
    
    
    ///                   will be made the block this is executed in.
    
    
    /// timestamp is reached.
    
    /// associated with this grant to
    function addGrantAndDelegate(
        address _who,
        uint128 _amount,
        uint128 _startTime,
        uint128 _expiration,
        uint128 _cliff,
        address _delegatee
    ) public onlyManager {
        // Consistency check
        require(
            _cliff <= _expiration && _startTime <= _expiration,
            "Invalid configuration"
        );
        // If no custom start time is needed we use this block.
        if (_startTime == 0) {
            _startTime = uint128(block.number);
        }

        Storage.Uint256 storage unassigned = _unassigned();
        Storage.Uint256 memory unvestedMultiplier = _unvestedMultiplier();

        require(unassigned.data >= _amount, "Insufficient balance");
        // load the grant.
        VestingVaultStorage.Grant storage grant = _grants()[_who];

        // If this address already has a grant, a different address must be provided
        // topping up or editing active grants is not supported.
        require(grant.allocation == 0, "Has Grant");

        // load the delegate. Defaults to the grant owner
        _delegatee = _delegatee == address(0) ? _who : _delegatee;

        // calculate the voting power. Assumes all voting power is initially locked.
        // Come back to this assumption.
        uint128 newVotingPower = (_amount * uint128(unvestedMultiplier.data)) /
            100;

        // set the new grant
        _grants()[_who] = VestingVaultStorage.Grant(
            _amount,
            0,
            _startTime,
            _expiration,
            _cliff,
            newVotingPower,
            _delegatee,
            [uint256(0), uint256(0)]
        );

        // update the amount of unassigned tokens
        unassigned.data -= _amount;

        // update the delegatee's voting power
        History.HistoricalBalances memory votingPower = _votingPower();
        uint256 delegateeVotes = History.loadTop(votingPower, grant.delegatee);
        History.push(
            votingPower,
            grant.delegatee,
            delegateeVotes + newVotingPower
        );

        emit VoteChange(grant.delegatee, _who, int256(uint256(newVotingPower)));
    }

    
    
    /// sent to the grant owner.
    
    function removeGrant(address _who) public virtual onlyManager {
        // load the grant
        VestingVaultStorage.Grant storage grant = _grants()[_who];
        // get the amount of withdrawable tokens
        uint256 withdrawable = _getWithdrawableAmount(grant);
        // it is simpler to just transfer withdrawable tokens instead of modifying the struct storage
        // to allow withdrawal through claim()
        token.transfer(_who, withdrawable);

        Storage.Uint256 storage unassigned = _unassigned();
        uint256 locked = grant.allocation - (grant.withdrawn + withdrawable);

        // return the unused tokens so they can be used for a different grant
        unassigned.data += locked;

        // update the delegatee's voting power
        History.HistoricalBalances memory votingPower = _votingPower();
        uint256 delegateeVotes = History.loadTop(votingPower, grant.delegatee);
        History.push(
            votingPower,
            grant.delegatee,
            delegateeVotes - grant.latestVotingPower
        );

        // Emit the vote change event
        emit VoteChange(
            grant.delegatee,
            _who,
            -1 * int256(uint256(grant.latestVotingPower))
        );

        // delete the grant
        delete _grants()[_who];
    }

    
    
    /// total voting power associated with the caller's grant.
    function claim() public virtual {
        // load the grant
        VestingVaultStorage.Grant storage grant = _grants()[msg.sender];
        // get the withdrawable amount
        uint256 withdrawable = _getWithdrawableAmount(grant);

        // transfer the available amount
        token.transfer(msg.sender, withdrawable);
        grant.withdrawn += uint128(withdrawable);

        // only move range bound if grant was accepted
        if (grant.range[1] > 0) {
            grant.range[1] -= withdrawable;
        }

        // update the user's voting power
        _syncVotingPower(msg.sender, grant);
    }

    
    
    /// the unvested token multiplier can be updated at any time.
    
    function delegate(address _to) public {
        VestingVaultStorage.Grant storage grant = _grants()[msg.sender];
        // If the delegation has already happened we don't want the tx to send
        require(_to != grant.delegatee, "Already delegated");
        History.HistoricalBalances memory votingPower = _votingPower();

        uint256 oldDelegateeVotes = History.loadTop(
            votingPower,
            grant.delegatee
        );
        uint256 newVotingPower = _currentVotingPower(grant);

        // Remove old delegatee's voting power and emit event
        History.push(
            votingPower,
            grant.delegatee,
            oldDelegateeVotes - grant.latestVotingPower
        );
        emit VoteChange(
            grant.delegatee,
            msg.sender,
            -1 * int256(uint256(grant.latestVotingPower))
        );

        // Note - It is important that this is loaded here and not before the previous state change because if
        // _to == grant.delegatee and re-delegation was allowed we could be working with out of date state.
        uint256 newDelegateeVotes = History.loadTop(votingPower, _to);

        // add voting power to the target delegatee and emit event
        emit VoteChange(_to, msg.sender, int256(newVotingPower));
        History.push(votingPower, _to, newDelegateeVotes + newVotingPower);

        // update grant info
        grant.latestVotingPower = uint128(newVotingPower);
        grant.delegatee = _to;
    }

    
    
    /// WARNING: This is the only way to deposit tokens into the contract. Any tokens sent
    /// via other means are not recoverable by this contract.
    
    function deposit(uint256 _amount) public onlyManager {
        Storage.Uint256 storage unassigned = _unassigned();
        // update unassigned value
        unassigned.data += _amount;
        token.transferFrom(msg.sender, address(this), _amount);
    }

    
    
    /// This function cannot be used to recover tokens that were sent to this contract
    /// by any means other than `deposit()`
    
    
    function withdraw(uint256 _amount, address _recipient)
        public
        virtual
        onlyManager
    {
        Storage.Uint256 storage unassigned = _unassigned();
        require(unassigned.data >= _amount, "Insufficient balance");
        // update unassigned value
        unassigned.data -= _amount;
        token.transfer(_recipient, _amount);
    }

    
    
    /// see `History` for more on how voting power is tracked and queried.
    /// Anybody can update a grant's voting power.
    
    function updateVotingPower(address _who) public {
        VestingVaultStorage.Grant storage grant = _grants()[_who];
        _syncVotingPower(_who, grant);
    }

    
    
    
    function _syncVotingPower(
        address _who,
        VestingVaultStorage.Grant storage _grant
    ) internal {
        History.HistoricalBalances memory votingPower = _votingPower();

        uint256 delegateeVotes = History.loadTop(votingPower, _grant.delegatee);

        uint256 newVotingPower = _currentVotingPower(_grant);
        // get the change in voting power. Negative if the voting power is reduced
        int256 change = int256(newVotingPower) -
            int256(uint256(_grant.latestVotingPower));
        // do nothing if there is no change
        if (change == 0) return;
        if (change > 0) {
            History.push(
                votingPower,
                _grant.delegatee,
                delegateeVotes + uint256(change)
            );
        } else {
            // if the change is negative, we multiply by -1 to avoid underflow when casting
            History.push(
                votingPower,
                _grant.delegatee,
                delegateeVotes - uint256(change * -1)
            );
        }
        emit VoteChange(_grant.delegatee, _who, change);
        _grant.latestVotingPower = uint128(newVotingPower);
    }

    
    
    
    // @param calldata the extra calldata is unused in this contract
    
    function queryVotePower(
        address user,
        uint256 blockNumber,
        bytes calldata
    ) external override returns (uint256) {
        // Get our reference to historical data
        History.HistoricalBalances memory votingPower = _votingPower();
        // Find the historical data and clear everything more than 'staleBlockLag' into the past
        return
            History.findAndClear(
                votingPower,
                user,
                blockNumber,
                block.number - staleBlockLag
            );
    }

    
    
    
    
    function queryVotePowerView(address user, uint256 blockNumber)
        external
        view
        returns (uint256)
    {
        // Get our reference to historical data
        History.HistoricalBalances memory votingPower = _votingPower();
        // Find the historical data
        return History.find(votingPower, user, blockNumber);
    }

    
    
    
    function _getWithdrawableAmount(VestingVaultStorage.Grant memory _grant)
        internal
        view
        returns (uint256)
    {
        if (block.number < _grant.cliff || block.number < _grant.created) {
            return 0;
        }
        if (block.number >= _grant.expiration) {
            return (_grant.allocation - _grant.withdrawn);
        }
        uint256 unlocked = (_grant.allocation *
            (block.number - _grant.created)) /
            (_grant.expiration - _grant.created);
        return (unlocked - _grant.withdrawn);
    }

    
    
    function _votingPower()
        internal
        pure
        returns (History.HistoricalBalances memory)
    {
        // This call returns a storage mapping with a unique non overwrite-able storage location
        // which can be persisted through upgrades, even if they change storage layout.
        return (History.load("votingPower"));
    }

    
    
    /// _unvestedMultiplier.
    
    
    function _currentVotingPower(VestingVaultStorage.Grant memory _grant)
        internal
        view
        returns (uint256)
    {
        uint256 withdrawable = _getWithdrawableAmount(_grant);
        uint256 locked = _grant.allocation - (withdrawable + _grant.withdrawn);
        return (withdrawable + (locked * _unvestedMultiplier().data) / 100);
    }

    
    
    
    function changeUnvestedMultiplier(uint256 _multiplier) public onlyTimelock {
        require(_multiplier <= 100, "Above 100%");
        Storage.set(Storage.uint256Ptr("unvestedMultiplier"), _multiplier);
    }

    
    
    
    function setTimelock(address timelock_) public onlyTimelock {
        Storage.set(Storage.addressPtr("timelock"), timelock_);
    }

    
    
    
    function setManager(address manager_) public onlyTimelock {
        Storage.set(Storage.addressPtr("manager"), manager_);
    }

    
    
    
    function timelock() public pure returns (address) {
        return _timelock().data;
    }

    
    
    function unvestedMultiplier() external pure returns (uint256) {
        return _unvestedMultiplier().data;
    }

    
    
    
    function manager() public pure returns (address) {
        return _manager().data;
    }
}

// Deployable version of the abstract contract
contract VestingVault is AbstractVestingVault {
    
    
    
    constructor(IERC20 _token, uint256 _stale)
        AbstractVestingVault(_token, _stale)
    {}
}