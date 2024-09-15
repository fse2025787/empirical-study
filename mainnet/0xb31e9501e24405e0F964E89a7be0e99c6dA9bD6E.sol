// SPDX-License-Identifier: UNLICENSED"
pragma experimental ABIEncoderV2;


// "
pragma solidity >=0.6.10;





interface IGelatoCondition {

    
    
    ///  "ok" selector or _taskReceiptId, since those two things are handled by GelatoCore.
    
    ///  source of Task identification.
    
    ///  Condition's specific parameters in.
    
    function ok(uint256 _taskReceiptId, bytes calldata _conditionData, uint256 _cycleId)
        external
        view
        returns(string memory);
}
// "
pragma solidity >=0.6.10;



abstract contract GelatoConditionsStandard is IGelatoCondition {
    string internal constant OK = "OK";
}

// 
pragma solidity 0.8.0;



IGelatoGasPriceOracle constant GELATO_GAS_PRICE_ORACLE = IGelatoGasPriceOracle(
    0x169E633A2D1E6c10dD91238Ba11c4A708dfEF37C
);

address constant GELATO_EXECUTOR_MODULE = 0x98edc8067Cc671BCAE82D36dCC609C3E4e078AC8;

address constant CONDITION_MAKER_VAULT_UNSAFE_OSM = 0xDF3CDd10e646e4155723a3bC5b1191741DD90333;

// 
pragma solidity 0.8.0;








contract ConditionMakerVaultUnSafePosition is GelatoConditionsStandard {
    
    
    
    
    function ok(
        uint256,
        bytes calldata _conditionData,
        uint256
    ) public view virtual override returns (string memory) {
        (
            uint256 _vaultID,
            address _priceOracle,
            bytes memory _oraclePeekPayload,
            bytes memory _oraclePeepPayload,
            uint256 _minPeekLimit,
            uint256 _minPeepLimit
        ) =
            abi.decode(
                _conditionData[4:],
                (uint256, address, bytes, bytes, uint256, uint256)
            );

        return
            _isOk(
                isVaultUnsafeOSM(
                    _vaultID,
                    _priceOracle,
                    _oraclePeekPayload,
                    _minPeekLimit
                )
            ) ||
                _isOk(
                    isVaultUnsafeOSM(
                        _vaultID,
                        _priceOracle,
                        _oraclePeepPayload,
                        _minPeepLimit
                    )
                )
                ? OK
                : "MakerVaultNotUnsafe";
    }

    
    
    
    
    ///  e.g. Maker's ETH/USD oracle for ETH collateral pricing.
    
    ///  method e.g. the selector for MakerOracle's read fn.
    
    /// of the collateral as specified by the _priceOracle.
    
    function isVaultUnsafeOSM(
        uint256 _vaultID,
        address _priceOracle,
        bytes memory _oraclePayload,
        uint256 _minLimit
    ) public view virtual returns (string memory) {
        return
            IConditionMakerVaultUnsafeOSM(CONDITION_MAKER_VAULT_UNSAFE_OSM)
                .isVaultUnsafeOSM(
                _vaultID,
                _priceOracle,
                _oraclePayload,
                _minLimit
            );
    }

    
    
    
    function getConditionData(
        uint256 _vaultId,
        address _priceOracle,
        bytes calldata _oraclePeekPayload,
        bytes calldata _oraclePeepPayload,
        uint256 _minPeekLimit,
        uint256 _minPeepLimit
    ) public pure virtual returns (bytes memory) {
        return
            abi.encodeWithSelector(
                this.isVaultUnsafeOSM.selector,
                _vaultId,
                _priceOracle,
                _oraclePeekPayload,
                _oraclePeepPayload,
                _minPeekLimit,
                _minPeepLimit
            );
    }

    function _isOk(string memory _isSafe) internal view returns (bool) {
        return
            keccak256(abi.encodePacked(_isSafe)) ==
            keccak256(abi.encodePacked(OK));
    }
}

// 
pragma solidity 0.8.0;

interface IGelatoGasPriceOracle {
    function latestAnswer() external view returns (int256);
}

// 
pragma solidity 0.8.0;

interface IConditionMakerVaultUnsafeOSM {
    function isVaultUnsafeOSM(
        uint256 _vaultID,
        address _priceOracle,
        bytes memory _oraclePayload,
        uint256 _minColRatio
    ) external view returns (string memory);
}