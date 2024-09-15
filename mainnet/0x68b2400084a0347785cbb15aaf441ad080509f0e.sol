// SPDX-License-Identifier: Apache-2.0

/**
 *Submitted for verification at Etherscan.io on 2022-04-10
*/

// 
pragma solidity ^0.8.0;

interface IOracle {
    function value() external view returns (int256, bool);

    function update() external returns (bool);
}

error Pausable__whenNotPaused_paused();


error Pausable__whenPaused_notPaused();



abstract contract Guarded {
    /// ======== Custom Errors ======== ///

    error Guarded__notRoot();
    error Guarded__notGranted();

    /// ======== Storage ======== ///

    
    bytes32 public constant ANY_SIG = keccak256("ANY_SIG");
    
    address public constant ANY_CALLER =
        address(uint160(uint256(bytes32(keccak256("ANY_CALLER")))));

    
    
    mapping(bytes32 => mapping(address => bool)) private _canCall;

    /// ======== Events ======== ///

    event AllowCaller(bytes32 sig, address who);
    event BlockCaller(bytes32 sig, address who);

    constructor() {
        // set root
        _setRoot(msg.sender);
    }

    /// ======== Auth ======== ///

    modifier callerIsRoot() {
        if (_canCall[ANY_SIG][msg.sender]) {
            _;
        } else revert Guarded__notRoot();
    }

    modifier checkCaller() {
        if (canCall(msg.sig, msg.sender)) {
            _;
        } else revert Guarded__notGranted();
    }

    
    
    
    
    function allowCaller(bytes32 sig_, address who_) public callerIsRoot {
        _canCall[sig_][who_] = true;
        emit AllowCaller(sig_, who_);
    }

    
    
    
    
    function blockCaller(bytes32 sig_, address who_) public callerIsRoot {
        _canCall[sig_][who_] = false;
        emit BlockCaller(sig_, who_);
    }

    
    
    
    function canCall(bytes32 sig_, address who_) public view returns (bool) {
        return (_canCall[sig_][who_] ||
            _canCall[ANY_SIG][who_] ||
            _canCall[sig_][ANY_CALLER]);
    }

    
    
    function _setRoot(address root_) internal {
        _canCall[ANY_SIG][root_] = true;
        emit AllowCaller(ANY_SIG, root_);
    }
}
contract Pausable is Guarded {
    event Paused(address who);
    event Unpaused(address who);

    bool private _paused;

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        // If the contract is paused, throw an error
        if (_paused) {
            revert Pausable__whenNotPaused_paused();
        }
        _;
    }

    modifier whenPaused() {
        // If the contract is not paused, throw an error
        if (_paused == false) {
            revert Pausable__whenPaused_notPaused();
        }
        _;
    }

    function _pause() internal whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function _unpause() internal whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}
abstract contract Oracle is Pausable, IOracle {
    
    error Oracle__nonReentrant();

    /// ======== Events ======== ///

    event ValueInvalid();
    event ValueUpdated(int256 currentValue, int256 nextValue);
    event OracleReset();

    /// ======== Storage ======== ///
    // Time interval between the value updates
    uint256 public immutable timeUpdateWindow;

    // Timestamp of the current value
    uint256 public lastTimestamp;

    // The next value that will replace the current value once the timeUpdateWindow has passed
    int256 public nextValue;

    // Current value that will be returned by the Oracle
    int256 private _currentValue;

    // Flag that tells if the value provider returned successfully
    bool private _validReturnedValue;

    // Reentrancy constants
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    // Reentrancy guard flag
    uint256 private _reentrantGuard = _NOT_ENTERED;

    /// ======== Modifiers ======== ///

    modifier nonReentrant() {
        // Check if the guard is set
        if (_reentrantGuard != _NOT_ENTERED) {
            revert Oracle__nonReentrant();
        }

        // Set the guard
        _reentrantGuard = _ENTERED;

        // Allow execution
        _;

        // Reset the guard
        _reentrantGuard = _NOT_ENTERED;
    }

    constructor(uint256 timeUpdateWindow_) {
        timeUpdateWindow = timeUpdateWindow_;
        _validReturnedValue = false;
    }

    
    
    
    function value()
        public
        view
        override(IOracle)
        whenNotPaused
        returns (int256, bool)
    {
        // Value is considered valid if the value provider successfully returned a value
        return (_currentValue, _validReturnedValue);
    }

    function getValue() external virtual returns (int256);

    function update()
        public
        override(IOracle)
        checkCaller
        nonReentrant
        returns (bool)
    {
        // Not enough time has passed since the last update
        if (lastTimestamp + timeUpdateWindow > block.timestamp) {
            // Exit early if no update is needed
            return false;
        }

        // Oracle update should not fail even if the value provider fails to return a value
        try this.getValue() returns (int256 returnedValue) {
            // Update the value using an exponential moving average
            if (_currentValue == 0) {
                // First update takes the current value
                nextValue = returnedValue;
                _currentValue = nextValue;
            } else {
                // Update the current value with the next value
                _currentValue = nextValue;
                // Set the returnedValue as the next value
                nextValue = returnedValue;
            }

            // Save when the value was last updated
            lastTimestamp = block.timestamp;
            _validReturnedValue = true;

            emit ValueUpdated(_currentValue, nextValue);

            return true;
        } catch {
            // When a value provider fails, we update the valid flag which will
            // invalidate the value instantly
            _validReturnedValue = false;
            emit ValueInvalid();
        }

        return false;
    }

    function pause() public checkCaller {
        _pause();
    }

    function unpause() public checkCaller {
        _unpause();
    }

    function reset() public whenPaused checkCaller {
        _currentValue = 0;
        nextValue = 0;
        lastTimestamp = 0;
        _validReturnedValue = false;

        emit OracleReset();
    }
}
contract Convert {
    function convert(
        int256 x_,
        uint256 currentPrecision_,
        uint256 targetPrecision_
    ) internal pure returns (int256) {
        if (targetPrecision_ > currentPrecision_)
            return x_ * int256(10**(targetPrecision_ - currentPrecision_));

        return x_ / int256(10**(currentPrecision_ - targetPrecision_));
    }

    function uconvert(
        uint256 x_,
        uint256 currentPrecision_,
        uint256 targetPrecision_
    ) internal pure returns (uint256) {
        if (targetPrecision_ > currentPrecision_)
            return x_ * 10**(targetPrecision_ - currentPrecision_);

        return x_ / 10**(currentPrecision_ - targetPrecision_);
    }
}
// Chainlink Aggregator v3 interface
// https://github.com/smartcontractkit/chainlink/blob/6fea3ccd275466e082a22be690dbaf1609f19dce/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol
interface IChainlinkAggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract ChainlinkValueProvider is Oracle, Convert {
    uint8 public immutable underlierDecimals;
    address public chainlinkAggregatorAddress;

    
    
    
    constructor(
        // Oracle parameters
        uint256 timeUpdateWindow_,
        // Chainlink specific parameter
        address chainlinkAggregatorAddress_
    ) Oracle(timeUpdateWindow_) {
        chainlinkAggregatorAddress = chainlinkAggregatorAddress_;
        underlierDecimals = IChainlinkAggregatorV3Interface(
            chainlinkAggregatorAddress_
        ).decimals();
    }

    
    
    function getValue() external view override(Oracle) returns (int256) {
        // Convert the annual rate to 1e18 precision.
        (, int256 answer, , , ) = IChainlinkAggregatorV3Interface(
            chainlinkAggregatorAddress
        ).latestRoundData();

        return convert(answer, underlierDecimals, 18);
    }

    
    function description() external view returns (string memory) {
        return
            IChainlinkAggregatorV3Interface(chainlinkAggregatorAddress)
                .description();
    }
}
interface IRelayer {
    enum RelayerType {
        DiscountRate,
        SpotPrice,
        COUNT
    }

    function execute() external returns (bool);

    function executeWithRevert() external;
}// Lightweight interface for Collybus
// Source: https://github.com/fiatdao/fiat-lux/blob/f49a9457fbcbdac1969c35b4714722f00caa462c/src/interfaces/ICollybus.sol
interface ICollybus {
    function updateDiscountRate(uint256 tokenId_, uint256 rate_) external;

    function updateSpot(address token_, uint256 spot_) external;
}

/// The Relayer manages an Oracle for which it controls the update flow and via execute() calls
/// pushes data to Collybus when it's needed

/// are value synched. The same is true for the Relayer-Collybus relationship as we do not interrogate the Collybus
/// for the current value and use a storage cached last updated value.
contract Relayer is Guarded, IRelayer {
    
    error Relayer__executeWithRevert_noUpdate(RelayerType relayerType);

    
    error Relayer__setParam_unrecognizedParam(bytes32 param);

    event SetParam(bytes32 param, uint256 value);
    event UpdateOracle(address oracle, int256 value, bool valid);
    event UpdatedCollybus(bytes32 tokenId, uint256 rate, RelayerType);

    /// ======== Storage ======== ///

    address public immutable collybus;
    RelayerType public immutable relayerType;
    address public immutable oracle;
    bytes32 public immutable encodedTokenId;

    uint256 public minimumPercentageDeltaValue;
    int256 private _lastUpdateValue;

    
    
    
    
    /// uint256 for discount rate, address for spot price
    
    /// push data to Collybus
    constructor(
        address collybusAddress_,
        RelayerType type_,
        address oracleAddress_,
        bytes32 encodedTokenId_,
        uint256 minimumPercentageDeltaValue_
    ) {
        collybus = collybusAddress_;
        relayerType = type_;
        oracle = oracleAddress_;
        encodedTokenId = encodedTokenId_;
        minimumPercentageDeltaValue = minimumPercentageDeltaValue_;
        _lastUpdateValue = 0;
    }

    
    /// Supported parameters are:
    /// - minimumPercentageDeltaValue
    
    
    
    function setParam(bytes32 param_, uint256 value_) public checkCaller {
        if (param_ == "minimumPercentageDeltaValue") {
            minimumPercentageDeltaValue = value_;
        } else revert Relayer__setParam_unrecognizedParam(param_);

        emit SetParam(param_, value_);
    }

    
    /// delta change in value is bigger than the minimum threshold value.
    
    function execute() public override(IRelayer) returns (bool) {
        // We always update the oracles before retrieving the rates
        bool oracleUpdated = IOracle(oracle).update();
        (int256 oracleValue, bool isValid) = IOracle(oracle).value();

        // If the oracle was not updated, the value is invalid or the delta condition is not met, we can exit early
        if (
            !oracleUpdated ||
            !isValid ||
            !checkDeviation(
                _lastUpdateValue,
                oracleValue,
                minimumPercentageDeltaValue
            )
        ) {
            // Collybus was not updated so we return false
            return false;
        }

        _lastUpdateValue = oracleValue;

        if (relayerType == RelayerType.DiscountRate) {
            ICollybus(collybus).updateDiscountRate(
                uint256(encodedTokenId),
                uint256(oracleValue)
            );
        } else if (relayerType == RelayerType.SpotPrice) {
            ICollybus(collybus).updateSpot(
                address(uint160(uint256(encodedTokenId))),
                uint256(oracleValue)
            );
        }

        emit UpdatedCollybus(encodedTokenId, uint256(oracleValue), relayerType);

        // Collybus was updated
        return true;
    }

    
    
    function executeWithRevert() public override(IRelayer) {
        if (!execute()) {
            revert Relayer__executeWithRevert_noUpdate(relayerType);
        }
    }

    
    
    
    
    function checkDeviation(
        int256 baseValue_,
        int256 newValue_,
        uint256 percentage_
    ) public pure returns (bool) {
        int256 deviation = (baseValue_ * int256(percentage_)) / 100_00;

        if (
            baseValue_ + deviation <= newValue_ ||
            baseValue_ - deviation >= newValue_
        ) return true;

        return false;
    }
}


contract ChainlinkFactory {
    event ChainlinkDeployed(address relayerAddress, address oracleAddress);

    
    
    
    /// push data to Collybus
    
    
    
    function create(
        // Relayer parameters
        address collybus_,
        address tokenAddress_,
        uint256 minimumPercentageDeltaValue_,
        // Oracle parameters
        uint256 timeUpdateWindow_,
        // Chainlink specific parameters, see ChainlinkValueProvider for more info
        address chainlinkAggregatorAddress_
    ) public returns (address) {
        ChainlinkValueProvider chainlinkValueProvider = new ChainlinkValueProvider(
                timeUpdateWindow_,
                chainlinkAggregatorAddress_
            );

        // Create the relayer that manages the oracle and pushes data to Collybus
        Relayer relayer = new Relayer(
            collybus_,
            IRelayer.RelayerType.SpotPrice,
            address(chainlinkValueProvider),
            bytes32(uint256(uint160(tokenAddress_))),
            minimumPercentageDeltaValue_
        );

        // Whitelist the Relayer in the Oracle so it can trigger updates
        chainlinkValueProvider.allowCaller(
            chainlinkValueProvider.ANY_SIG(),
            address(relayer)
        );

        // Whitelist the deployer
        chainlinkValueProvider.allowCaller(
            chainlinkValueProvider.ANY_SIG(),
            msg.sender
        );
        relayer.allowCaller(relayer.ANY_SIG(), msg.sender);

        // Renounce permissions
        chainlinkValueProvider.blockCaller(
            chainlinkValueProvider.ANY_SIG(),
            address(this)
        );
        relayer.blockCaller(relayer.ANY_SIG(), address(this));

        emit ChainlinkDeployed(
            address(relayer),
            address(chainlinkValueProvider)
        );
        return address(relayer);
    }
}