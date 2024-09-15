// SPDX-License-Identifier: MIT

// 
pragma solidity 0.8.17;



contract MultiStaticCall {
    struct Call {
        address target;
        bytes callData;
    }

    struct Result {
        bool success;
        bytes returnData;
    }

    
    
    
    
    
    function tryAggregate(bool requireSuccess, Call[] calldata calls) public view returns (Result[] memory returnData) {
        uint256 length = calls.length;
        returnData = new Result[](length);
        unchecked {
            for (uint256 i; i != length; ++i) {
                (bool success, bytes memory ret) = calls[i].target.staticcall(calls[i].callData);

                if (requireSuccess) {
                    require(success, "MultiStaticCall: call failed");
                }

                returnData[i] = Result(success, ret);
            }
        }
    }

    
    
    
    
    
    
    
    function tryBlockAndAggregate(bool requireSuccess, Call[] calldata calls) public view returns (uint256 blockNumber, Result[] memory returnData) {
        blockNumber = block.number;
        returnData = tryAggregate(requireSuccess, calls);
    }
}