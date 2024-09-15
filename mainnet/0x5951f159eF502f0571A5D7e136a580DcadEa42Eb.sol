// SPDX-License-Identifier: MIT


pragma solidity ^0.8.11;


///         `msg.origin` is not authorized.
error Unauthorized();


///         or entered an illegal condition which is not recoverable from.
error IllegalState();


///         to the function.
error IllegalArgument();

pragma solidity >=0.5.0;



interface ITokenAdapter {
    
    ///
    
    function version() external view returns (string memory);

    
    ///
    
    function token() external view returns (address);

    
    ///
    
    function underlyingToken() external view returns (address);

    
    ///
    
    function price() external view returns (uint256);

    
    ///
    
    
    ///
    
    function wrap(uint256 amount, address recipient)
        external
        returns (uint256 amountYieldTokens);

    
    ///
    
    
    ///
    
    function unwrap(uint256 amount, address recipient)
        external
        returns (uint256 amountUnderlyingTokens);
}

pragma solidity >=0.5.0;



interface IERC20Minimal {
    
    ///
    
    
    
    event Transfer(address indexed owner, address indexed recipient, uint256 amount);

    
    ///
    
    
    
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    
    ///
    
    function totalSupply() external view returns (uint256);

    
    ///
    
    ///
    
    function balanceOf(address account) external view returns (uint256);

    
    ///
    
    
    ///
    
    function allowance(address owner, address spender) external view returns (uint256);

    
    ///
    
    ///
    
    
    ///
    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    ///
    
    ///
    
    
    ///
    
    function approve(address spender, uint256 amount) external returns (bool);

    
    ///
    
    
    ///
    
    
    
    ///
    
    function transferFrom(address owner, address recipient, uint256 amount) external returns (bool);
}

pragma solidity >=0.5.0;



interface IERC20Metadata {
    
    ///
    
    function name() external view returns (string memory);

    
    ///
    
    function symbol() external view returns (string memory);

    
    ///
    
    function decimals() external view returns (uint8);
}
pragma solidity ^0.8.11;










contract YearnTokenAdapter is ITokenAdapter {
    uint256 private constant MAXIMUM_SLIPPAGE = 10000;
    string public constant override version = "2.1.0";

    address public immutable override token;
    address public immutable override underlyingToken;

    constructor(address _token, address _underlyingToken) {
        token = _token;
        underlyingToken = _underlyingToken;
    }

    
    function price() external view override returns (uint256) {
        return IYearnVaultV2(token).pricePerShare();
    }

    
    function wrap(uint256 amount, address recipient) external override returns (uint256) {
        TokenUtils.safeTransferFrom(underlyingToken, msg.sender, address(this), amount);
        TokenUtils.safeApprove(underlyingToken, token, amount);

        return IYearnVaultV2(token).deposit(amount, recipient);
    }

    
    function unwrap(uint256 amount, address recipient) external override returns (uint256) {
        TokenUtils.safeTransferFrom(token, msg.sender, address(this), amount);

        uint256 balanceBefore = TokenUtils.safeBalanceOf(token, address(this));

        uint256 amountWithdrawn = IYearnVaultV2(token).withdraw(amount, recipient, MAXIMUM_SLIPPAGE);

        uint256 balanceAfter = TokenUtils.safeBalanceOf(token, address(this));

        // If the Yearn vault did not burn all of the shares then revert. This is critical in mathematical operations
        // performed by the system because the system always expects that all of the tokens were unwrapped. In Yearn,
        // this sometimes does not happen in cases where strategies cannot withdraw all of the requested tokens (an
        // example strategy where this can occur is with Compound and AAVE where funds may not be accessible because
        // they were lent out).
        if (balanceBefore - balanceAfter != amount) {
            revert IllegalState();
        }

        return amountWithdrawn;
    }
}

// 
pragma solidity >=0.5.0;






interface IYearnVaultV2 is IERC20Minimal, IERC20Metadata {
  struct StrategyParams {
    uint256 performanceFee;
    uint256 activation;
    uint256 debtRatio;
    uint256 minDebtPerHarvest;
    uint256 maxDebtPerHarvest;
    uint256 lastReport;
    uint256 totalDebt;
    uint256 totalGain;
    uint256 totalLoss;
    bool enforceChangeLimit;
    uint256 profitLimitRatio;
    uint256 lossLimitRatio;
    address customCheck;
  }

  function apiVersion() external pure returns (string memory);

  function permit(
    address owner,
    address spender,
    uint256 amount,
    uint256 expiry,
    bytes calldata signature
  ) external returns (bool);

  // NOTE: Vyper produces multiple signatures for a given function with "default" args
  function deposit() external returns (uint256);

  function deposit(uint256 amount) external returns (uint256);

  function deposit(uint256 amount, address recipient) external returns (uint256);

  // NOTE: Vyper produces multiple signatures for a given function with "default" args
  function withdraw() external returns (uint256);

  function withdraw(uint256 maxShares) external returns (uint256);

  function withdraw(uint256 maxShares, address recipient) external returns (uint256);

  function withdraw(
    uint256 maxShares,
    address recipient,
    uint256 maxLoss
  ) external returns (uint256);

  function token() external view returns (address);

  function strategies(address _strategy) external view returns (StrategyParams memory);

  function pricePerShare() external view returns (uint256);

  function totalAssets() external view returns (uint256);

  function depositLimit() external view returns (uint256);

  function maxAvailableShares() external view returns (uint256);

  
  ///         (since its last report). Can be used to determine expectedReturn in your Strategy.
  function creditAvailable() external view returns (uint256);

  
  ///         (since its last report). Can be used to determine expectedReturn in your Strategy.
  function debtOutstanding() external view returns (uint256);

  
  ///         performance (since its last report). Can be used to determine expectedReturn in your Strategy.
  function expectedReturn() external view returns (uint256);

  
  ///         is handled as intended by the Strategy. Therefore, this function will be called by BaseStrategy to make
  ///         sure the integration is correct.
  function report(
    uint256 _gain,
    uint256 _loss,
    uint256 _debtPayment
  ) external returns (uint256);

  
  ///         the positions are possible, or in the extreme scenario that the Strategy needs to be put into
  ///         "Emergency Exit" mode in order for it to exit as quickly as possible. The latter scenario could be for any
  ///         reason that is considered "critical" that the Strategy exits its position as fast as possible, such as a
  ///         sudden change in market conditions leading to losses, or an imminent failure in an external dependency.
  function revokeStrategy() external;

  
  ///         The Strategy serves the Vault, so it is subject to governance defined by the Vault.
  function governance() external view returns (address);

  
  ///         The Strategy serves the Vault, so it is subject to management defined by the Vault.
  function management() external view returns (address);

  
  ///         Strategy serves the Vault, so it is subject to guardian defined by the Vault.
  function guardian() external view returns (address);
}

pragma solidity ^0.8.11;








library TokenUtils {
    
    ///
    
    
    
    ///                this is malformed data when the call was a success.
    error ERC20CallFailed(address target, bool success, bytes data);

    
    ///
    
    ///
    
    ///
    
    function expectDecimals(address token) internal view returns (uint8) {
        (bool success, bytes memory data) = token.staticcall(
            abi.encodeWithSelector(IERC20Metadata.decimals.selector)
        );

        if (!success || data.length < 32) {
            revert ERC20CallFailed(token, success, data);
        }

        return abi.decode(data, (uint8));
    }

    
    ///
    
    ///
    
    
    ///
    
    function safeBalanceOf(address token, address account) internal view returns (uint256) {
        (bool success, bytes memory data) = token.staticcall(
            abi.encodeWithSelector(IERC20Minimal.balanceOf.selector, account)
        );

        if (!success || data.length < 32) {
            revert ERC20CallFailed(token, success, data);
        }

        return abi.decode(data, (uint256));
    }

    
    ///
    
    ///
    
    
    
    function safeTransfer(address token, address recipient, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20Minimal.transfer.selector, recipient, amount)
        );

        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }

    
    ///
    
    ///
    
    
    
    function safeApprove(address token, address spender, uint256 value) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20Minimal.approve.selector, spender, value)
        );

        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }

    
    ///
    
    ///
    
    
    
    
    function safeTransferFrom(address token, address owner, address recipient, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20Minimal.transferFrom.selector, owner, recipient, amount)
        );

        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }

    
    ///
    
    ///
    
    
    
    function safeMint(address token, address recipient, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20Mintable.mint.selector, recipient, amount)
        );

        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }

    
    ///
    /// Reverts with a `CallFailed` error if execution of the burn fails or returns an unexpected value.
    ///
    
    
    function safeBurn(address token, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20Burnable.burn.selector, amount)
        );

        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }

    
    ///
    
    ///
    
    
    
    function safeBurnFrom(address token, address owner, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20Burnable.burnFrom.selector, owner, amount)
        );

        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }
}

pragma solidity >=0.5.0;





interface IERC20Burnable is IERC20Minimal {
    
    ///
    
    ///
    
    function burn(uint256 amount) external returns (bool);

    
    ///
    
    
    ///
    
    function burnFrom(address owner, uint256 amount) external returns (bool);
}

pragma solidity >=0.5.0;





interface IERC20Mintable is IERC20Minimal {
    
    ///
    
    
    ///
    
    function mint(address recipient, uint256 amount) external returns (bool);
}