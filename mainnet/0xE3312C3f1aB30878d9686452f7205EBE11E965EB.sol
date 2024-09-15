// SPDX-License-Identifier: AGPL-3.0

// 
pragma solidity 0.8.15;




error OTCEscrow_UnapprovedUser();
error OTCEscrow_NotOlympus();
error OTCEscrow_TradeInProgress();




///         with other crypto institutions
contract OTCEscrow {
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    /// Involved Parties
    address public olympus;
    address public tradePartner;

    /// OTC Tokens
    address public olympusToken;
    address public externalToken;

    /// Token Amounts
    uint256 public olympusAmount;
    uint256 public externalAmount;

    constructor(
        address olympus_,
        address tradePartner_,
        address olympusToken_,
        address externalToken_,
        uint256 olympusAmount_,
        uint256 externalAmount_
    ) {
        olympus = olympus_;
        tradePartner = tradePartner_;

        olympusToken = olympusToken_;
        externalToken = externalToken_;

        olympusAmount = olympusAmount_;
        externalAmount = externalAmount_;
    }

    /* ========== MODIFIERS ========== */

    modifier onlyApprovedParties() {
        if (msg.sender != olympus && msg.sender != tradePartner) revert OTCEscrow_UnapprovedUser();
        _;
    }

    modifier onlyOlympus() {
        if (msg.sender != olympus) revert OTCEscrow_NotOlympus();
        _;
    }

    modifier tradeInactive() {
        uint256 olympusTokenBalance = IERC20(olympusToken).balanceOf(address(this));
        if (olympusTokenBalance != 0) revert OTCEscrow_TradeInProgress();
        _;
    }

    /* ========== OTC TRADE FUNCTIONS ========== */

    
    ///         Olympus's tokens that were escrowed in the contract to the trade partner
    
    function swap() external onlyApprovedParties {
        IERC20(externalToken).safeTransferFrom(tradePartner, olympus, externalAmount);
        IERC20(olympusToken).safeTransfer(tradePartner, olympusAmount);
    }

    
    
    function revoke() external onlyOlympus {
        uint256 olympusTokenBalance = IERC20(olympusToken).balanceOf(address(this));
        IERC20(olympusToken).safeTransfer(olympus, olympusTokenBalance);
    }

    
    ///         contract rather than exchanged through the swap function
    
    function revokeReceivedToken() external onlyApprovedParties {
        uint256 externalTokenBalance = IERC20(externalToken).balanceOf(address(this));
        IERC20(externalToken).safeTransfer(tradePartner, externalTokenBalance);
    }

    /* ========== MANAGEMENT FUNCTIONS ========== */

    
    
    function newTrade(
        address tradePartner_,
        address olympusToken_,
        address externalToken_,
        uint256 olympusAmount_,
        uint256 externalAmount_
    ) external onlyOlympus tradeInactive {
        tradePartner = tradePartner_;

        olympusToken = olympusToken_;
        externalToken = externalToken_;

        olympusAmount = olympusAmount_;
        externalAmount = externalAmount_;
    }
}

// 
pragma solidity >=0.7.5;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// 
pragma solidity >=0.7.5;





/// Taken from Solmate
library SafeERC20 {
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.transfer.selector, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FAILED");
    }

    function safeApprove(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.approve.selector, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "APPROVE_FAILED");
    }

    function safeTransferETH(address to, uint256 amount) internal {
        (bool success, ) = to.call{value: amount}(new bytes(0));

        require(success, "ETH_TRANSFER_FAILED");
    }
}