// SPDX-License-Identifier: MIT

// 

pragma solidity ^0.8.15;

contract BoredAndDangerousBatchHelper {
    
    address public immutable JENKINS_BOOK;

    
    error BatchError(bytes innerError);
    
    error FailedToSendEther(address sender, address recipient);
    
    error MismatchedArrays();

    constructor (address _JENKINS_BOOK) {
        JENKINS_BOOK = _JENKINS_BOOK;
    }

    
    
    
    
    function batch(bytes[] calldata calls, uint[] calldata msgValues, bool revertOnFail) external payable {
        // Check array length
        if (calls.length != msgValues.length) {
            revert MismatchedArrays();
        }

        // Check that proper ETH value is sent
        uint msgValueTotal = 0;
        for (uint256 i = 0; i < calls.length; ++i) {
            msgValueTotal += msgValues[i];
        }
        if (msgValueTotal != msg.value) {
            revert FailedToSendEther(msg.sender, address(this));
        }

        // Perform external calls
        for (uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory result) = JENKINS_BOOK.call{value: msgValues[i]}(calls[i]);
            if (!success && revertOnFail) {
                _getRevertMsg(result);
            }
        }
    }

    
    /// If the returned data is malformed or not correctly abi encoded then this call can fail itself.
    function _getRevertMsg(bytes memory _returnData) internal pure {
        // If the _res length is less than 68, then
        // the transaction failed with custom error or silently (without a revert message)
        if (_returnData.length < 68) revert BatchError(_returnData);

        assembly {
            // Slice the sighash.
            _returnData := add(_returnData, 0x04)
        }
        revert(abi.decode(_returnData, (string))); // All that remains is the revert string
    }
    
}