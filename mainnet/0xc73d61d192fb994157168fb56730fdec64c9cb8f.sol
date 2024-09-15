// SPDX-License-Identifier: GPL-3.0-or-later

// 
pragma solidity ^0.8.17;



contract UnsupportedProtocol {
    error UnsupportedProtocolError();

    fallback() external {
        revert UnsupportedProtocolError();
    }
}