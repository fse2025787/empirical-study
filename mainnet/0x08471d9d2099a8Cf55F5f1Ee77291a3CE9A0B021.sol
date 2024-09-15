// SPDX-License-Identifier: LGPL-3.0-only

/**
 *Submitted for verification at Etherscan.io on 2022-11-18
*/

// 
pragma solidity >=0.7.0 <0.9.0;



contract TokenPocketCallbackProxy {

    address public executor;

    event SafeCreationByTokenPocket(address creator, address proxy, address singleton, bytes initializer, uint256 saltNonce);

    constructor(address _executor) {
        require(address(0) != _executor, "Invalid executor address provided");
        executor = _executor;
    }

    function proxyCreated(
        address proxy,
        address _singleton,
        bytes calldata initializer,
        uint256 saltNonce
    ) external onlyExecutor {
        emit SafeCreationByTokenPocket(tx.origin, proxy, _singleton, initializer, saltNonce);
    }

    modifier onlyExecutor() {
        require(msg.sender == executor, "Invalid executor called");
        _;
    }
}