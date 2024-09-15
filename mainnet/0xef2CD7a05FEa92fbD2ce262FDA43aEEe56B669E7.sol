// SPDX-License-Identifier: MIT

// 
pragma solidity ^0.8.0;



library LimitedCall {
    
    function limitedCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory output) = target.call{value: 0}(data);
        if (!success) {
            revert(RevertMsgExtractor.getRevertMsg(output));
        } else {
            return output;
        }
    }
}


/// This contract is useful to append checks at in a batch of transactions, so that
/// if any of the checks fail, the entire batch of transactions will revert.
contract Assert {
    using LimitedCall for address;

    /// --- EQUALITY ---

    
    
    
    function assertEq(bytes memory actual, bytes memory expected)
        public
        pure
    {
        require(keccak256(actual) == keccak256(expected), "Not equal to expected");
    }
    
    
    
    
    function assertEq(bool actual, bool expected)
        public
        pure
    {
        require(actual == expected, "Not equal to expected");
    }

    
    
    
    function assertEq(uint actual, uint expected)
        public
        pure
    {
        require(actual == expected, "Not equal to expected");
    }

    
    
    
    
    function assertEq(
        address actualTarget,
        bytes memory actualCalldata,
        uint expected
    ) public {
        bytes memory actual = actualTarget.limitedCall(actualCalldata);

        assertEq(abi.decode(actual, (uint)), expected);
    }

    
    
    
    
    
    function assertEq(
        address actualTarget,
        bytes memory actualCalldata,
        address expectedTarget,
        bytes memory expectedCalldata
    ) public {
        bytes memory actual = actualTarget.limitedCall(actualCalldata);
        bytes memory expected = expectedTarget.limitedCall(expectedCalldata);

        assertEq(abi.decode(actual, (uint)), abi.decode(expected, (uint)));
    }

    /// --- RELATIVE EQUALITY ---

    
    
    
    
    function assertEqRel(uint actual, uint expected, uint rel)
        public
        pure
    {
        require(actual <= expected * (1e18 + rel) / 1e18, "Higher than expected");
        require(actual >= expected * (1e18 - rel) / 1e18, "Lower than expected");
    }

    
    
    
    
    
    function assertEqRel(
        address actualTarget,
        bytes memory actualCalldata,
        uint expected,
        uint256 rel
    )
        public
    {
        bytes memory actual = actualTarget.limitedCall(actualCalldata);
        assertEqRel(abi.decode(actual, (uint)), expected, rel);
    }

    
    
    
    
    
    
    function assertEqRel(
        address actualTarget,
        bytes memory actualCalldata,
        address expectedTarget,
        bytes memory expectedCalldata,
        uint256 rel
    )
        public
    {
        bytes memory actual = actualTarget.limitedCall(actualCalldata);
        bytes memory expected = expectedTarget.limitedCall(expectedCalldata);
        assertEqRel(abi.decode(actual, (uint)), abi.decode(expected, (uint)), rel);
    }

    /// --- ABSOLUTE EQUALITY ---

    
    
    
    
    function assertEqAbs(uint actual, uint expected, uint abs)
        public
        pure
    {
        require(actual <= expected + abs, "Higher than expected");
        require(actual >= expected - abs, "Lower than expected");
    }

    
    
    
    
    
    function assertEqAbs(
        address actualTarget,
        bytes memory actualCalldata,
        uint expected,
        uint256 abs
    )
        public
    {
        bytes memory actual = actualTarget.limitedCall(actualCalldata);
        assertEqAbs(abi.decode(actual, (uint)), expected, abs);
    }

    
    
    
    
    
    
    function assertEqAbs(
        address actualTarget,
        bytes memory actualCalldata,
        address expectedTarget,
        bytes memory expectedCalldata,
        uint256 abs
    )
        public
    {
        bytes memory actual = actualTarget.limitedCall(actualCalldata);
        bytes memory expected = expectedTarget.limitedCall(expectedCalldata);
        assertEqAbs(abi.decode(actual, (uint)), abi.decode(expected, (uint)), abs);
    }

    /// --- GREATER THAN ---

    
    
    
    function assertGt(uint actual, uint expected)
        public
        pure
    {
        require(actual > expected, "Not greater than expected");
    }

    
    
    
    
    function assertGt(
        address actualTarget,
        bytes memory actualCalldata,
        uint expected
    ) public {
        bytes memory actual = actualTarget.limitedCall(actualCalldata);
        assertGt(abi.decode(actual, (uint)), expected);
    }

    
    
    
    
    
    function assertGt(
        address actualTarget,
        bytes memory actualCalldata,
        address expectedTarget,
        bytes memory expectedCalldata
    ) public {
        bytes memory actual = actualTarget.limitedCall(actualCalldata);
        bytes memory expected = expectedTarget.limitedCall(expectedCalldata);

        assertGt(abi.decode(actual, (uint)), abi.decode(expected, (uint)));
    }

    /// --- LESS THAN ---

    
    
    
    function assertLt(uint actual, uint expected)
        public
        pure
    {
        require(actual < expected, "Not less than expected");
    }

    
    
    
    
    function assertLt(
        address actualTarget,
        bytes memory actualCalldata,
        uint expected
    ) public {
        bytes memory actual = actualTarget.limitedCall(actualCalldata);
        assertLt(abi.decode(actual, (uint)), expected);
    }

    
    
    
    
    
    function assertLt(
        address actualTarget,
        bytes memory actualCalldata,
        address expectedTarget,
        bytes memory expectedCalldata
    ) public {
        bytes memory actual = actualTarget.limitedCall(actualCalldata);
        bytes memory expected = expectedTarget.limitedCall(expectedCalldata);
        assertLt(abi.decode(actual, (uint)), abi.decode(expected, (uint)));
    }

    /// --- GREATER OR EQUAL ---

    
    
    
    function assertGe(uint actual, uint expected)
        public
        pure
    {
        require(actual >= expected, "Not greater or equal to expected");
    }

    
    
    
    
    function assertGe(
        address actualTarget,
        bytes memory actualCalldata,
        uint expected
    ) public {
        bytes memory actual = actualTarget.limitedCall(actualCalldata);
        assertGe(abi.decode(actual, (uint)), expected);
    }

    
    
    
    
    
    function assertGe(
        address actualTarget,
        bytes memory actualCalldata,
        address expectedTarget,
        bytes memory expectedCalldata
    ) public {
        bytes memory actual = actualTarget.limitedCall(actualCalldata);
        bytes memory expected = expectedTarget.limitedCall(expectedCalldata);
        assertGe(abi.decode(actual, (uint)), abi.decode(expected, (uint)));
    }

    /// --- LESS THAN ---

    
    
    
    function assertLe(uint actual, uint expected)
        public
        pure
    {
        require(actual <= expected, "Not less or equal to expected");
    }

    
    
    
    
    function assertLe(
        address actualTarget,
        bytes memory actualCalldata,
        uint expected
    ) public {
        bytes memory actual = actualTarget.limitedCall(actualCalldata);
        assertLe(abi.decode(actual, (uint)), expected);
    }

    
    
    
    
    
    function assertLe(
        address actualTarget,
        bytes memory actualCalldata,
        address expectedTarget,
        bytes memory expectedCalldata
    ) public {
        bytes memory actual = actualTarget.limitedCall(actualCalldata);
        bytes memory expected = expectedTarget.limitedCall(expectedCalldata);
        assertLe(abi.decode(actual, (uint)), abi.decode(expected, (uint)));
    }
}

// 
// Taken from https://github.com/sushiswap/BoringSolidity/blob/441e51c0544cf2451e6116fe00515e71d7c42e2c/contracts/BoringBatchable.sol

pragma solidity >=0.6.0;


library RevertMsgExtractor {
    
    /// If the returned data is malformed or not correctly abi encoded then this call can fail itself.
    function getRevertMsg(bytes memory returnData)
        internal pure
        returns (string memory)
    {
        // If the _res length is less than 68, then the transaction failed silently (without a revert message)
        if (returnData.length < 68) return "Transaction reverted silently";

        assembly {
            // Slice the sighash.
            returnData := add(returnData, 0x04)
        }
        return abi.decode(returnData, (string)); // All that remains is the revert string
    }
}