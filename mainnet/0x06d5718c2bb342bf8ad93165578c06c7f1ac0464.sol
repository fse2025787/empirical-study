// SPDX-License-Identifier: MIT

// 
pragma solidity 0.8.10;

interface ILenderVerifier {
    function isAllowed(
        address lender,
        uint256 amount,
        bytes memory signature
    ) external view returns (bool);
}

// 
pragma solidity 0.8.10;

interface IManageable {
    function manager() external view returns (address);
}

// 
pragma solidity 0.8.10;




contract WhitelistLenderVerifier is ILenderVerifier {
    mapping(IManageable => mapping(address => bool)) public isWhitelisted;

    event WhitelistStatusChanged(IManageable portfolio, address lender, bool status);

    function isAllowed(
        address lender,
        uint256,
        bytes memory
    ) external view returns (bool) {
        return isWhitelisted[IManageable(msg.sender)][lender];
    }

    function setLenderWhitelistStatus(
        IManageable portfolio,
        address lender,
        bool status
    ) external {
        require(msg.sender == portfolio.manager(), "WhitelistLenderVerifier: Only portfolio manager can modify whitelist");
        isWhitelisted[portfolio][lender] = status;
        emit WhitelistStatusChanged(portfolio, lender, status);
    }
}