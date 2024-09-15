
pragma solidity ^0.4.0;



contract AndxorLogger {
    event LogHash(uint256 hash);

    function AndxorLogger() {
    }

    /// logs an hash value into the blockchain
    function logHash(uint256 value) {
        LogHash(value);
    }
}