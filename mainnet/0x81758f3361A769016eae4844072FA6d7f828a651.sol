// SPDX-License-Identifier: Apache-2.0


// 
pragma solidity >=0.7.0;

contract Authorizable {
    // This contract allows a flexible authorization scheme

    // The owner who can change authorization status
    address public owner;
    // A mapping from an address to its authorization status
    mapping(address => bool) public authorized;

    
    constructor() {
        owner = msg.sender;
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Sender not owner");
        _;
    }

    
    modifier onlyAuthorized() {
        require(isAuthorized(msg.sender), "Sender not Authorized");
        _;
    }

    
    
    
    function isAuthorized(address who) public view returns (bool) {
        return authorized[who];
    }

    
    
    function authorize(address who) external onlyOwner() {
        _authorize(who);
    }

    
    
    function deauthorize(address who) external onlyOwner() {
        authorized[who] = false;
    }

    
    
    function setOwner(address who) public onlyOwner() {
        owner = who;
    }

    
    
    function _authorize(address who) internal {
        authorized[who] = true;
    }
}

// 
pragma solidity ^0.8.3;

contract ReentrancyBlock {
    // A storage slot for the reentrancy flag
    bool private _entered;
    // Will use a state flag to prevent this function from being called back into
    modifier nonReentrant() {
        // Check the state variable before the call is entered
        require(!_entered, "Reentrancy");
        // Store that the function has been entered
        _entered = true;
        // Run the function code
        _;
        // Clear the state
        _entered = false;
    }
}// 
pragma solidity ^0.8.3;




// Allows a call to be executed after a waiting period, also allows a call to
// be canceled within a waiting period.

contract Timelock is Authorizable, ReentrancyBlock {
    // Amount of time for the waiting period
    uint256 public waitTime;

    // Mapping of call hashes to block timestamps
    mapping(bytes32 => uint256) public callTimestamps;
    // Mapping from a call hash to its status of once allowed time increase
    mapping(bytes32 => bool) public timeIncreases;

    
    
    
    
    constructor(
        uint256 _waitTime,
        address _governance,
        address _gsc
    ) Authorizable() {
        _authorize(_gsc);
        waitTime = _waitTime;
        setOwner(_governance);
    }

    
    
    function registerCall(bytes32 callHash) external onlyOwner {
        // We only want to register a call which is not already active
        require(callTimestamps[callHash] == 0, "already registered");
        // Set the timestamp for this call package to be the current time
        callTimestamps[callHash] = block.timestamp;
    }

    
    
    function stopCall(bytes32 callHash) external onlyOwner {
        // We only want this to actually execute when a real thing is deleted to
        // prevent re-ordering attacks
        require(callTimestamps[callHash] != 0, "No call to be removed");
        // Do the actual deletion
        delete callTimestamps[callHash];
        delete timeIncreases[callHash];
    }

    
    
    
    function execute(address[] memory targets, bytes[] calldata calldatas)
        public
        nonReentrant
    {
        // hash provided data to access the mapping
        bytes32 callHash = keccak256(abi.encode(targets, calldatas));
        // call defaults to zero and cannot be executed before it is registered
        require(callTimestamps[callHash] != 0, "call has not been initialized");
        // call cannot be executed before the waiting period has passed
        require(
            callTimestamps[callHash] + waitTime < block.timestamp,
            "not enough time has passed"
        );
        // Gives a revert string to a revert that would occur anyway when the array is accessed
        require(targets.length == calldatas.length, "invalid formatting");
        // execute a package of low level calls
        for (uint256 i = 0; i < targets.length; i++) {
            (bool success, ) = targets[i].call(calldatas[i]);
            // revert if a single call fails
            require(success == true, "call reverted");
        }
        // restore state after successful execution
        delete callTimestamps[callHash];
        delete timeIncreases[callHash];
    }

    
    
    function setWaitTime(uint256 _waitTime) public {
        require(msg.sender == address(this), "contract must be self");
        waitTime = _waitTime;
    }

    
    /// can only be executed once for each call
    
    
    function increaseTime(uint256 timeValue, bytes32 callHash)
        external
        onlyAuthorized
    {
        require(
            timeIncreases[callHash] == false,
            "value can only be changed once"
        );
        require(
            callTimestamps[callHash] != 0,
            "must have been previously registered"
        );
        // Increases the time till the call can be executed
        callTimestamps[callHash] += timeValue;
        // set mapping to indicate call has been changed
        timeIncreases[callHash] = true;
    }
}
