// SPDX-License-Identifier: Apache-2.0


// 
pragma solidity ^0.8.3;

interface IVotingVault {
    
    
    
    
    
    function queryVotePower(
        address user,
        uint256 blockNumber,
        bytes calldata extraData
    ) external returns (uint256);
}

// 
pragma solidity ^0.8.3;



interface ILockingVault {
    
    
    
    
    function deposit(
        address fundedAccount,
        uint256 amount,
        address firstDelegation
    ) external;

    
    
    function withdraw(uint256 amount) external;

    
    function token() external returns (IERC20);
}
// 
pragma solidity ^0.8.3;







abstract contract AbstractLockingVault is IVotingVault, ILockingVault {
    // Bring our libraries into scope
    using History for *;
    using Storage for *;

    // Immutables are in bytecode so don't need special storage treatment
    IERC20 public immutable override token;
    // A constant which is how far back stale blocks are
    uint256 public immutable staleBlockLag;

    // Event to track delegation data
    event VoteChange(address indexed from, address indexed to, int256 amount);

    
    
    
    constructor(IERC20 _token, uint256 _staleBlockLag) {
        token = _token;
        staleBlockLag = _staleBlockLag;
    }

    // This contract is a proxy so we use the custom state management system from
    // storage and return the following as methods to isolate that call.

    // deposits mapping(address => (address, uint96))
    
    
    function _deposits()
        internal
        pure
        returns (mapping(address => Storage.AddressUint) storage)
    {
        // This call returns a storage mapping with a unique non overwrite-able storage location
        // which can be persisted through upgrades, even if they change storage layout
        return (Storage.mappingAddressToPackedAddressUint("deposits"));
    }

    /// Getter for the deposits mapping
    
    
    function deposits(address who) external view returns (address, uint96) {
        Storage.AddressUint storage userData = _deposits()[who];
        return (userData.who, userData.amount);
    }

    
    
    function _votingPower()
        internal
        pure
        returns (History.HistoricalBalances memory)
    {
        // This call returns a storage mapping with a unique non overwrite-able storage location
        // which can be persisted through upgrades, even if they change storage layout
        return (History.load("votingPower"));
    }

    
    
    
    
    function queryVotePower(
        address user,
        uint256 blockNumber,
        bytes calldata
    ) external override returns (uint256) {
        // Get our reference to historical data
        History.HistoricalBalances memory votingPower = _votingPower();
        // Find the historical data and clear everything more than 'staleBlockLag' into the past
        return
            votingPower.findAndClear(
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
        // Find the historical datum
        return votingPower.find(user, blockNumber);
    }

    
    
    
    
    
    ///      address by depositing before them, requiring them to call delegate to reset it.
    ///      Given the gas price required and 0 financial benefit we consider it unlikely.
    ///      Warning - Users should not set delegation to the zero address as this will allow
    ///                someone to change their delegation by depositing a small amount to their
    ///                account.
    function deposit(
        address fundedAccount,
        uint256 amount,
        address firstDelegation
    ) external override {
        // No delegating to zero
        require(firstDelegation != address(0), "Zero addr delegation");
        // Move the tokens into this contract
        token.transferFrom(msg.sender, address(this), amount);
        // Load our deposits storage
        Storage.AddressUint storage userData = _deposits()[fundedAccount];
        // Load who has the user's votes
        address delegate = userData.who;

        if (delegate == address(0)) {
            // If the user is un-delegated we delegate to their indicated address
            delegate = firstDelegation;
            // Set the delegation
            userData.who = delegate;
            // Now we increase the user's balance
            userData.amount += uint96(amount);
        } else {
            // In this case we make no change to the user's delegation
            // Now we increase the user's balance
            userData.amount += uint96(amount);
        }
        // Next we increase the delegation to their delegate
        // Get the storage pointer
        History.HistoricalBalances memory votingPower = _votingPower();
        // Load the most recent voter power stamp
        uint256 delegateeVotes = votingPower.loadTop(delegate);
        // Emit an event to track votes
        emit VoteChange(fundedAccount, delegate, int256(amount));
        // Add the newly deposited votes to the delegate
        votingPower.push(delegate, delegateeVotes + amount);
    }

    
    
    function withdraw(uint256 amount) external virtual override {
        // Load our deposits storage
        Storage.AddressUint storage userData = _deposits()[msg.sender];
        // Reduce the user's stored balance
        // If properly optimized this block should result in 1 sload 1 store
        userData.amount -= uint96(amount);
        address delegate = userData.who;
        // Reduce the delegate voting power
        // Get the storage pointer
        History.HistoricalBalances memory votingPower = _votingPower();
        // Load the most recent voter power stamp
        uint256 delegateeVotes = votingPower.loadTop(delegate);
        // remove the votes from the delegate
        votingPower.push(delegate, delegateeVotes - amount);
        // Emit an event to track votes
        emit VoteChange(msg.sender, delegate, -1 * int256(amount));
        // Transfers the result to the sender
        token.transfer(msg.sender, amount);
    }

    
    
    function changeDelegation(address newDelegate) external {
        // Get the stored user data
        Storage.AddressUint storage userData = _deposits()[msg.sender];
        // Get the user balance
        uint256 userBalance = uint256(userData.amount);
        address oldDelegate = userData.who;
        // Reset the user delegation
        userData.who = newDelegate;
        // Reduce the old voting power
        // Get the storage pointer
        History.HistoricalBalances memory votingPower = _votingPower();
        // Load the old delegate's voting power
        uint256 oldDelegateVotes = votingPower.loadTop(oldDelegate);
        // Reduce the old voting power
        votingPower.push(oldDelegate, oldDelegateVotes - userBalance);
        // Emit an event to track votes
        emit VoteChange(msg.sender, oldDelegate, -1 * int256(userBalance));
        // Get the new delegate's votes
        uint256 newDelegateVotes = votingPower.loadTop(newDelegate);
        // Store the increase in power
        votingPower.push(newDelegate, newDelegateVotes + userBalance);
        // Emit an event tracking this voting power change
        emit VoteChange(msg.sender, newDelegate, int256(userBalance));
    }
}
// 
pragma solidity ^0.8.3;



// All elves stay in the elfiverse
contract FrozenLockingVault is AbstractLockingVault {
    
    
    
    constructor(IERC20 _token, uint256 _staleBlockLag)
        AbstractLockingVault(_token, _staleBlockLag)
    {}

    // These functions are the only way for tokens to leave the contract
    // Therefore they now revert

    
    function withdraw(uint256) external pure override {
        revert("Frozen");
    }
}

contract LockingVault is AbstractLockingVault {
    
    
    
    constructor(IERC20 _token, uint256 _staleBlockLag)
        AbstractLockingVault(_token, _staleBlockLag)
    {}
}

// 
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

// 
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

// 
pragma solidity ^0.8.3;

interface IERC20 {
    function symbol() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    // Note this is non standard but nearly all ERC20 have exposed decimal functions
    function decimals() external view returns (uint8);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
