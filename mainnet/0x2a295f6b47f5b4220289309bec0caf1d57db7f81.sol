// SPDX-License-Identifier: Apache-2.0

/**
 *Submitted for verification at Etherscan.io on 2022-04-10
*/

// 
pragma solidity ^0.8.0;
interface IRelayer {
    enum RelayerType {
        DiscountRate,
        SpotPrice,
        COUNT
    }

    function execute() external returns (bool);

    function executeWithRevert() external;
}interface IOracle {
    function value() external view returns (int256, bool);

    function update() external returns (bool);
}// Lightweight interface for Collybus
// Source: https://github.com/fiatdao/fiat-lux/blob/f49a9457fbcbdac1969c35b4714722f00caa462c/src/interfaces/ICollybus.sol
interface ICollybus {
    function updateDiscountRate(uint256 tokenId_, uint256 rate_) external;

    function updateSpot(address token_, uint256 spot_) external;
}

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
contract StaticRelayer is IRelayer {
    
    error StaticRelayer__executeWithRevert_collybusAlreadyUpdated(
        IRelayer.RelayerType relayerType
    );

    /// ======== Events ======== ///

    event UpdatedCollybus(
        bytes32 tokenId,
        uint256 rate,
        IRelayer.RelayerType relayerType
    );

    /// ======== Storage ======== ///

    address public immutable collybus;
    IRelayer.RelayerType public immutable relayerType;
    bytes32 public immutable encodedTokenId;
    uint256 public immutable value;

    // Flag used to ensure that the value is pushed to Collybus only once
    bool private _updatedCollybus;

    
    
    
    /// uint256 for discount rate, address for spot price
    
    constructor(
        address collybusAddress_,
        IRelayer.RelayerType type_,
        bytes32 encodedTokenId_,
        uint256 value_
    ) {
        collybus = collybusAddress_;
        relayerType = type_;
        encodedTokenId = encodedTokenId_;
        value = value_;
        _updatedCollybus = false;
    }

    
    
    function execute() public override(IRelayer) returns (bool) {
        if (_updatedCollybus) return false;

        _updatedCollybus = true;
        if (relayerType == IRelayer.RelayerType.DiscountRate) {
            ICollybus(collybus).updateDiscountRate(
                uint256(encodedTokenId),
                value
            );
        } else if (relayerType == IRelayer.RelayerType.SpotPrice) {
            ICollybus(collybus).updateSpot(
                address(uint160(uint256(encodedTokenId))),
                value
            );
        }

        emit UpdatedCollybus(encodedTokenId, value, relayerType);
        return true;
    }

    
    function executeWithRevert() public override(IRelayer) {
        if (!execute()) {
            revert StaticRelayer__executeWithRevert_collybusAlreadyUpdated(
                relayerType
            );
        }
    }
}

interface IRelayerFactory {
    function create(
        address collybus_,
        IRelayer.RelayerType relayerType_,
        address oracleAddress,
        bytes32 encodedTokenId,
        uint256 minimumPercentageDeltaValue
    ) external returns (address);

    function createStatic(
        address collybus_,
        IRelayer.RelayerType relayerType_,
        bytes32 encodedTokenId_,
        uint256 value_
    ) external returns (address);
}

contract RelayerFactory is IRelayerFactory {
    // Emitted when a Relayer is created
    event RelayerDeployed(
        address relayerAddress,
        IRelayer.RelayerType relayerType,
        address oracleAddress,
        bytes32 encodedTokenId,
        uint256 minimumPercentageDeltaValue
    );
    // Emitted when a Static Relayer is created
    event StaticRelayerDeployed(
        address relayerAddress,
        IRelayer.RelayerType relayerType,
        bytes32 encodedTokenId,
        uint256 value
    );

    
    
    
    
    
    
    function create(
        address collybus_,
        Relayer.RelayerType relayerType_,
        address oracleAddress_,
        bytes32 encodedTokenId_,
        uint256 minimumPercentageDeltaValue_
    ) public override(IRelayerFactory) returns (address) {
        Relayer relayer = new Relayer(
            collybus_,
            relayerType_,
            oracleAddress_,
            encodedTokenId_,
            minimumPercentageDeltaValue_
        );

        // Pass permissions to the intended contract owner
        relayer.allowCaller(relayer.ANY_SIG(), msg.sender);
        relayer.blockCaller(relayer.ANY_SIG(), address(this));

        emit RelayerDeployed(
            address(relayer),
            relayerType_,
            oracleAddress_,
            encodedTokenId_,
            minimumPercentageDeltaValue_
        );
        return address(relayer);
    }

    
    
    
    
    
    
    function createStatic(
        address collybus_,
        Relayer.RelayerType relayerType_,
        bytes32 encodedTokenId_,
        uint256 value_
    ) public override(IRelayerFactory) returns (address) {
        // Create the Static Relayer contract
        StaticRelayer staticRelayer = new StaticRelayer(
            collybus_,
            relayerType_,
            encodedTokenId_,
            value_
        );

        emit StaticRelayerDeployed(
            address(staticRelayer),
            relayerType_,
            encodedTokenId_,
            value_
        );
        return address(staticRelayer);
    }
}