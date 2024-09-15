
/**
 *Submitted for verification at Etherscan.io on 2023-01-31
*/

// Sources flattened with hardhat v2.9.9 https://hardhat.org

// File src/interfaces/ITokenAdapter.sol

pragma solidity >=0.5.0;



interface ITokenAdapter {
    
    ///
    
    function version() external view returns (string memory);

    
    ///
    
    function token() external view returns (address);

    
    ///
    
    function underlyingToken() external view returns (address);

    
    ///         for.
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


// File src/interfaces/external/idle/IIdleCDO.sol

pragma solidity >=0.7.0;

// import "../../IERC20Minimal.sol";
// import "../../../../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";



interface IIdleCDO {
    function AATranche() external view returns (address);
    function BBTranche() external view returns (address);

    function strategy() external view returns (address);
    function strategyToken() external view returns (address);
    function token() external view returns (address);

    
    function allowAAWithdraw() external view returns (bool);

    
    function allowBBWithdraw() external view returns (bool);

    
    
    function tranchePrice(address _tranche) external view returns (uint256);

    
    /// ie the interest generated since the last update of priceAA and priceBB (done on depositXX/withdrawXX/harvest)
    /// useful for showing updated gains on frontends
    
    
    
    function virtualPrice(address _tranche) external view returns (uint256);

    
    
    
    
    function depositAA(uint256 _amount) external returns (uint256);

    
    
    
    
    function depositBB(uint256 _amount) external returns (uint256);

    
    
    
    function withdrawAA(uint256 _amount) external returns (uint256);

    
    
    
    function withdrawBB(uint256 _amount) external returns (uint256);
}


// File lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


// File lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


// File src/interfaces/IERC20Burnable.sol

pragma solidity >=0.5.0;



interface IERC20Burnable is IERC20 {
    
    ///
    
    ///
    
    function burn(uint256 amount) external returns (bool);

    
    ///
    
    
    ///
    
    function burnFrom(address owner, uint256 amount) external returns (bool);
}


// File src/interfaces/IERC20Mintable.sol

pragma solidity >=0.5.0;



interface IERC20Mintable is IERC20 {
    
    ///
    
    
    function mint(address recipient, uint256 amount) external;
}


// File src/libraries/TokenUtils.sol

pragma solidity ^0.8.13;






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

        if (token.code.length == 0 || !success || data.length < 32) {
            revert ERC20CallFailed(token, success, data);
        }

        return abi.decode(data, (uint8));
    }

    
    ///
    
    ///
    
    
    ///
    
    function safeBalanceOf(address token, address account) internal view returns (uint256) {
        (bool success, bytes memory data) = token.staticcall(
            abi.encodeWithSelector(IERC20.balanceOf.selector, account)
        );

        if (token.code.length == 0 || !success || data.length < 32) {
            revert ERC20CallFailed(token, success, data);
        }

        return abi.decode(data, (uint256));
    }

    
    ///
    
    ///
    
    
    
    function safeTransfer(address token, address recipient, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.transfer.selector, recipient, amount)
        );

        if (token.code.length == 0 || !success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }

    
    ///
    
    ///
    
    
    
    function safeApprove(address token, address spender, uint256 value) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.approve.selector, spender, value)
        );

        if (token.code.length == 0 || !success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }

    
    ///
    
    ///
    
    
    
    
    function safeTransferFrom(address token, address owner, address recipient, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.transferFrom.selector, owner, recipient, amount)
        );

        if (token.code.length == 0 || !success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }

    
    ///
    
    ///
    
    
    
    function safeMint(address token, address recipient, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20Mintable.mint.selector, recipient, amount)
        );

        if (token.code.length == 0 || !success || (data.length != 0 && !abi.decode(data, (bool)))) {
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

        if (token.code.length == 0 || !success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }

    
    ///
    
    ///
    
    
    
    function safeBurnFrom(address token, address owner, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20Burnable.burnFrom.selector, owner, amount)
        );

        if (token.code.length == 0 || !success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }
}


// File src/adapters/idle/IdleTrancheAdapter.sol

pragma solidity ^0.8.11;




contract IdleTrancheAdapter is ITokenAdapter {
    string public constant override version = "1.0.0";

    address public immutable override token;
    address public immutable override underlyingToken;
    IIdleCDO public immutable idleCDO;
    bool public immutable isAATranche;

    constructor(address _token, address _underlyingToken, address _idleCDO) {
        token = _token;
        underlyingToken = _underlyingToken;
        idleCDO = IIdleCDO(_idleCDO);
        isAATranche = _token == IIdleCDO(_idleCDO).AATranche();
    }

    
    function price() external view override returns (uint256) {
        return idleCDO.virtualPrice(token);
    }

    
    function wrap(uint256 amount, address recipient) external override returns (uint256) {
        TokenUtils.safeTransferFrom(underlyingToken, msg.sender, address(this), amount);
        TokenUtils.safeApprove(underlyingToken, address(idleCDO), 0);
        TokenUtils.safeApprove(underlyingToken, address(idleCDO), amount);

        uint256 mintedTranche = isAATranche ? idleCDO.depositAA(amount) : idleCDO.depositBB(amount);

        TokenUtils.safeTransfer(token, recipient, mintedTranche);
        return mintedTranche;
    }

    
    function unwrap(uint256 amount, address recipient) external override returns (uint256) {
        TokenUtils.safeTransferFrom(token, msg.sender, address(this), amount);

        uint256 balanceBefore = TokenUtils.safeBalanceOf(underlyingToken, address(this));
        isAATranche ? idleCDO.withdrawAA(amount) : idleCDO.withdrawBB(amount);
        uint256 amountWithdrawn = TokenUtils.safeBalanceOf(underlyingToken, address(this)) - balanceBefore;

        TokenUtils.safeTransfer(underlyingToken, recipient, amountWithdrawn);
        return amountWithdrawn;
    }
}