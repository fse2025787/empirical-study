// SPDX-License-Identifier: GPL-3.0

// 
pragma solidity ^0.8.13;









contract RocketOvmPriceMessenger {
    // Immutables
    ICrossDomainMessenger immutable ovmL1CrossDomainMessenger;
    RocketStorageInterface immutable rocketStorage;
    RocketOvmPriceOracle immutable rocketL2OvmPriceOracle;
    bytes32 immutable rocketNetworkBalancesKey;

    
    uint256 lastRate;

    constructor(RocketStorageInterface _rocketStorage, RocketOvmPriceOracle _rocketL2OvmPriceOracle, ICrossDomainMessenger _ovmL1CrossDomainMessenger) {
        rocketStorage = _rocketStorage;
        rocketL2OvmPriceOracle = _rocketL2OvmPriceOracle;
        ovmL1CrossDomainMessenger = _ovmL1CrossDomainMessenger;
        // Precompute storage key for RocketNetworkBalances address
        rocketNetworkBalancesKey = keccak256(abi.encodePacked("contract.address", "rocketNetworkBalances"));
    }

    
    function rateStale() external view returns (bool) {
        return rate() != lastRate;
    }

    
    function rate() public view returns (uint256) {
        // Retrieve the inputs from RocketNetworkBalances and calculate the rate
        RocketNetworkBalancesInterface rocketNetworkBalances = RocketNetworkBalancesInterface(rocketStorage.getAddress(rocketNetworkBalancesKey));
        uint256 supply = rocketNetworkBalances.getTotalRETHSupply();
        if (supply == 0) {
            return 0;
        }
        return 1 ether * rocketNetworkBalances.getTotalETHBalance() / supply;
    }

    
    function submitRate() external {
        lastRate = rate();
        // Send the cross chain message
        ovmL1CrossDomainMessenger.sendMessage(
            address(rocketL2OvmPriceOracle),
            abi.encodeWithSelector(
                rocketL2OvmPriceOracle.updateRate.selector,
                lastRate
            ),
            500000
        );
    }
}

pragma solidity >0.5.0 <0.9.0;

// 

interface RocketStorageInterface {

    // Deploy status
    function getDeployedStatus() external view returns (bool);

    // Guardian
    function getGuardian() external view returns(address);
    function setGuardian(address _newAddress) external;
    function confirmGuardian() external;

    // Getters
    function getAddress(bytes32 _key) external view returns (address);
    function getUint(bytes32 _key) external view returns (uint);
    function getString(bytes32 _key) external view returns (string memory);
    function getBytes(bytes32 _key) external view returns (bytes memory);
    function getBool(bytes32 _key) external view returns (bool);
    function getInt(bytes32 _key) external view returns (int);
    function getBytes32(bytes32 _key) external view returns (bytes32);

    // Setters
    function setAddress(bytes32 _key, address _value) external;
    function setUint(bytes32 _key, uint _value) external;
    function setString(bytes32 _key, string calldata _value) external;
    function setBytes(bytes32 _key, bytes calldata _value) external;
    function setBool(bytes32 _key, bool _value) external;
    function setInt(bytes32 _key, int _value) external;
    function setBytes32(bytes32 _key, bytes32 _value) external;

    // Deleters
    function deleteAddress(bytes32 _key) external;
    function deleteUint(bytes32 _key) external;
    function deleteString(bytes32 _key) external;
    function deleteBytes(bytes32 _key) external;
    function deleteBool(bytes32 _key) external;
    function deleteInt(bytes32 _key) external;
    function deleteBytes32(bytes32 _key) external;

    // Arithmetic
    function addUint(bytes32 _key, uint256 _amount) external;
    function subUint(bytes32 _key, uint256 _amount) external;

    // Protected storage
    function getNodeWithdrawalAddress(address _nodeAddress) external view returns (address);
    function getNodePendingWithdrawalAddress(address _nodeAddress) external view returns (address);
    function setWithdrawalAddress(address _nodeAddress, address _newWithdrawalAddress, bool _confirm) external;
    function confirmWithdrawalAddress(address _nodeAddress) external;
}

pragma solidity >0.5.0 <0.9.0;

// 

interface RocketNetworkBalancesInterface {
    function getBalancesBlock() external view returns (uint256);
    function getLatestReportableBlock() external view returns (uint256);
    function getTotalETHBalance() external view returns (uint256);
    function getStakingETHBalance() external view returns (uint256);
    function getTotalRETHSupply() external view returns (uint256);
    function getETHUtilizationRate() external view returns (uint256);
    function submitBalances(uint256 _block, uint256 _total, uint256 _staking, uint256 _rethSupply) external;
    function executeUpdateBalances(uint256 _block, uint256 _totalEth, uint256 _stakingEth, uint256 _rethSupply) external;
}

// 
pragma solidity >0.5.0 <0.9.0;

/**
 * @title ICrossDomainMessenger
 */
interface ICrossDomainMessenger {
    /**********
     * Events *
     **********/

    event SentMessage(
        address indexed target,
        address sender,
        bytes message,
        uint256 messageNonce,
        uint256 gasLimit
    );
    event RelayedMessage(bytes32 indexed msgHash);
    event FailedRelayedMessage(bytes32 indexed msgHash);

    /*************
     * Variables *
     *************/

    function xDomainMessageSender() external view returns (address);

    /********************
     * Public Functions *
     ********************/

    /**
     * Sends a cross domain message to the target messenger.
     * @param _target Target contract address.
     * @param _message Message to send to the target.
     * @param _gasLimit Gas limit for the provided message.
     */
    function sendMessage(
        address _target,
        bytes calldata _message,
        uint32 _gasLimit
    ) external;
}

// 
pragma solidity ^0.8.13;





contract RocketOvmPriceOracle {
    // Events
    event RateUpdated(uint256 rate);

    // Immutables
    ICrossDomainMessenger immutable ovmL2CrossDomainMessenger;

    
    uint256 public rate;

    
    uint256 public lastUpdated;

    
    address public owner;

    constructor(address _l2CrossDomainMessenger) {
        ovmL2CrossDomainMessenger = ICrossDomainMessenger(_l2CrossDomainMessenger);
        owner = msg.sender;
    }

    
    function setOwner(address _newOwner) external {
        require(msg.sender == owner, "Only owner");
        owner = _newOwner;
    }

    
    function updateRate(uint256 _newRate) external {
        // Only calls originating from L1 owner can update the rate
        require(
            msg.sender == address(ovmL2CrossDomainMessenger)
            && ovmL2CrossDomainMessenger.xDomainMessageSender() == owner,
            "Only owner"
        );
        // Set rate and last updated timestamp
        rate = _newRate;
        lastUpdated = block.timestamp;
        // Emit event
        emit RateUpdated(_newRate);
    }
}