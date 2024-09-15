// SPDX-License-Identifier: Unlicense


// 
pragma solidity >=0.8.4;




/// account (an owner) that can be granted exclusive access to specific functions.
///
/// By default, the owner account will be the one that deploys the contract. This can later be
/// changed with {transfer}.
///
/// This module is used through inheritance. It will make available the modifier `onlyOwner`,
/// which can be applied to your functions to restrict their use to the owner.
///

/// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/access/Ownable.sol
interface IOwnable {
    /// EVENTS ///

    
    
    
    event TransferOwnership(address indexed oldOwner, address indexed newOwner);

    /// NON-CONSTANT FUNCTIONS ///

    
    /// functions anymore.
    ///
    /// WARNING: Doing this will leave the contract without an owner, thereby removing any
    /// functionality that is only available to the owner.
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    function _renounceOwnership() external;

    
    /// called by the current owner.
    
    function _transferOwnership(address newOwner) external;

    /// CONSTANT FUNCTIONS ///

    
    
    function owner() external view returns (address);
}

// 
pragma solidity >=0.8.4;




///
/// We have followed general OpenZeppelin guidelines: functions revert instead of returning
/// `false` on failure. This behavior is nonetheless conventional and does not conflict with
/// the with the expectations of Erc20 applications.
///
/// Additionally, an {Approval} event is emitted on calls to {transferFrom}. This allows
/// applications to reconstruct the allowance for all accounts just by listening to said
/// events. Other implementations of the Erc may not emit these events, as it isn't
/// required by the specification.
///
/// Finally, the non-standard {decreaseAllowance} and {increaseAllowance} functions have been
/// added to mitigate the well-known issues around setting allowances.
///

/// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC20/ERC20.sol
interface IErc20 {
    /// EVENTS ///

    
    
    
    
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    
    
    
    
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// CONSTANT FUNCTIONS ///

    
    /// on behalf of `owner` through {transferFrom}. This is zero by default.
    ///
    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function decimals() external view returns (uint8);

    
    function name() external view returns (string memory);

    
    function symbol() external view returns (string memory);

    
    function totalSupply() external view returns (uint256);

    /// NON-CONSTANT FUNCTIONS ///

    
    ///
    
    ///
    /// IMPORTANT: Beware that changing an allowance with this method brings the risk that someone may
    /// use both the old and the new allowance by unfortunate transaction ordering. One possible solution
    /// to mitigate this race condition is to first reduce the spender's allowance to 0 and set the desired
    /// value afterwards: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    ///
    /// Requirements:
    ///
    /// - `spender` cannot be the zero address.
    ///
    
    function approve(address spender, uint256 amount) external returns (bool);

    
    ///
    
    ///
    /// This is an alternative to {approve} that can be used as a mitigation for problems described
    /// in {Erc20Interface-approve}.
    ///
    /// Requirements:
    ///
    /// - `spender` cannot be the zero address.
    /// - `spender` must have allowance for the caller of at least `subtractedAmount`.
    function decreaseAllowance(address spender, uint256 subtractedAmount) external returns (bool);

    
    ///
    
    ///
    /// This is an alternative to {approve} that can be used as a mitigation for the problems described above.
    ///
    /// Requirements:
    ///
    /// - `spender` cannot be the zero address.
    function increaseAllowance(address spender, uint256 addedAmount) external returns (bool);

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - `recipient` cannot be the zero address.
    /// - The caller must have a balance of at least `amount`.
    ///
    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    /// `is then deducted from the caller's allowance.
    ///
    
    /// not required by the Erc. See the note at the beginning of {Erc20}.
    ///
    /// Requirements:
    ///
    /// - `sender` and `recipient` cannot be the zero address.
    /// - `sender` must have a balance of at least `amount`.
    /// - The caller must have approed `sender` to spent at least `amount` tokens.
    ///
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

pragma solidity >=0.5.0;

interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}
// 
pragma solidity >=0.8.4;









interface IFlashUniswapV2 is IUniswapV2Callee {
    /// CUSTOM ERRORS ///

    
    error FlashUniswapV2__CallNotAuthorized(address caller);

    
    error FlashUniswapV2__FlashBorrowCollateral(address collateral, address underlying);

    
    error FlashUniswapV2__LiquidateUnderlyingBackedVault(address borrower, address underlying);

    
    /// than what the subsidizer is willing to pay.
    error FlashUniswapV2__TurnoutNotSatisfied(uint256 seizeAmount, uint256 repayAmount, int256 turnout);

    
    error FlashUniswapV2__UnderlyingNotInPool(IUniswapV2Pair pair, address token0, address token1, IErc20 underlying);

    /// EVENTS ///

    
    
    
    
    
    
    
    
    event FlashSwapAndLiquidateBorrow(
        address indexed liquidator,
        address indexed borrower,
        address indexed bond,
        uint256 underlyingAmount,
        uint256 seizeAmount,
        uint256 repayAmount,
        uint256 subsidyAmount,
        uint256 profitAmount
    );

    /// CONSTANT FUNCTIONS ///

    
    function balanceSheet() external view returns (IBalanceSheetV2);

    
    /// The formula used is:
    ///
    ///                (collateralReserves * underlyingAmount) * 1000
    /// repayAmount = -----------------------------------------------
    ///                (underlyingReserves - underlyingAmount) * 997
    ///
    /// Otherwise, the formula is:
    ///
    ///               underlyingAmount * 1000
    /// repayAmount =  ---------------------
    ///                         997
    ///
    
    /// corresponding pair token are akin to a normal swap, so the 0.3% LP fee applies.
    
    
    
    
    function getRepayAmount(
        IUniswapV2Pair pair,
        IErc20 underlying,
        uint256 underlyingAmount
    ) external view returns (uint256 repayAmount);

    
    function uniV2Factory() external view returns (address);

    
    function uniV2PairInitCodeHash() external view returns (bytes32);
}

// 
pragma solidity >=0.8.4;



interface IOwnableUpgradeable {
    /// CUSTOM ERRORS ///

    
    error OwnableUpgradeable__NotOwner(address owner, address caller);

    
    error OwnableUpgradeable__OwnerZeroAddress();

    /// EVENTS ///

    
    
    
    event TransferOwnership(address indexed oldOwner, address indexed newOwner);

    /// CONSTANT FUNCTIONS ///

    
    
    function owner() external view returns (address);

    /// NON-CONSTANT FUNCTIONS ///

    
    /// functions anymore.
    ///
    /// WARNING: Doing this will leave the contract without an owner, thereby removing any
    /// functionality that is only available to the owner.
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    function _renounceOwnership() external;

    
    /// called by the current owner.
    
    function _transferOwnership(address newOwner) external;
}

// 
// solhint-disable func-name-mixedcase
pragma solidity >=0.8.4;






/// transactions by setting the allowance with a signature using the `permit` method, and then spend
/// them via `transferFrom`.

interface IErc20Permit is IErc20 {
    /// NON-CONSTANT FUNCTIONS ///

    
    /// signed approval.
    ///
    
    ///
    /// IMPORTANT: The same issues Erc20 `approve` has related to transaction
    /// ordering also apply here.
    ///
    /// Requirements:
    ///
    /// - `owner` cannot be the zero address.
    /// - `spender` cannot be the zero address.
    /// - `deadline` must be a timestamp in the future.
    /// - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner` over the Eip712-formatted
    /// function arguments.
    /// - The signature must use `owner`'s current nonce.
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /// CONSTANT FUNCTIONS ///

    
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    
    function nonces(address account) external view returns (uint256);

    
    function PERMIT_TYPEHASH() external view returns (bytes32);

    
    function version() external view returns (string memory);
}

// 
// solhint-disable var-name-mixedcase
pragma solidity >=0.8.4;







/// (accidentally, or not) to the contract.
interface IErc20Recover is IOwnable {
    /// EVENTS ///

    
    
    
    
    event Recover(address indexed owner, IErc20 token, uint256 recoverAmount);

    
    
    
    event SetNonRecoverableTokens(address indexed owner, IErc20[] nonRecoverableTokens);

    /// NON-CONSTANT FUNCTIONS ///

    
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The contract must be initialized.
    /// - The amount to recover cannot be zero.
    /// - The token to recover cannot be among the non-recoverable tokens.
    ///
    
    
    function _recover(IErc20 token, uint256 recoverAmount) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The contract cannot be already initialized.
    ///
    
    function _setNonRecoverableTokens(IErc20[] calldata tokens) external;

    /// CONSTANT FUNCTIONS ///

    
    function nonRecoverableTokens(uint256 index) external view returns (IErc20);
}
// 
pragma solidity ^0.8.4;











contract FlashUniswapV2 is IFlashUniswapV2 {
    using SafeErc20 for IErc20;

    /// PUBLIC STORAGE ///

    
    IBalanceSheetV2 public override balanceSheet;

    
    address public override uniV2Factory;

    
    bytes32 public override uniV2PairInitCodeHash;

    /// CONSTRUCTOR ///
    constructor(
        IBalanceSheetV2 balanceSheet_,
        address uniV2Factory_,
        bytes32 uniV2PairInitCodeHash_
    ) {
        balanceSheet = IBalanceSheetV2(balanceSheet_);
        uniV2Factory = uniV2Factory_;
        uniV2PairInitCodeHash = uniV2PairInitCodeHash_;
    }

    /// PUBLIC CONSTANT FUNCTIONS ////

    
    function getRepayAmount(
        IUniswapV2Pair pair,
        IErc20 underlying,
        uint256 underlyingAmount
    ) public view override returns (uint256 repayAmount) {
        unchecked {
            uint112 collateralReserves;
            uint112 underlyingReserves;

            address token0 = pair.token0();
            if (token0 == address(underlying)) {
                (underlyingReserves, collateralReserves, ) = pair.getReserves();
            } else {
                (collateralReserves, underlyingReserves, ) = pair.getReserves();
            }

            uint256 numerator = collateralReserves * underlyingAmount * 1000;
            uint256 denominator = (underlyingReserves - underlyingAmount) * 997;
            repayAmount = numerator / denominator + 1;
        }
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    struct UniswapV2CallLocalVars {
        IHToken bond;
        address borrower;
        IErc20 collateral;
        uint256 mintedHTokenAmount;
        uint256 profitAmount;
        uint256 repayAmount;
        uint256 seizeAmount;
        uint256 subsidyAmount;
        int256 turnout;
        IErc20 underlying;
        uint256 underlyingAmount;
    }

    
    function uniswapV2Call(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external override {
        UniswapV2CallLocalVars memory vars;

        // Unpack the ABI encoded data passed by the UniswapV2Pair contract.
        (vars.borrower, vars.bond, vars.collateral, vars.turnout) = abi.decode(
            data,
            (address, IHToken, IErc20, int256)
        );

        // This flash swap contract does not support liquidating vaults backed by underlying.
        vars.underlying = vars.bond.underlying();
        if (vars.collateral == vars.underlying) {
            revert FlashUniswapV2__LiquidateUnderlyingBackedVault(vars.borrower, address(vars.underlying));
        }

        (vars.collateral, vars.underlyingAmount) = getCollateralAddressAndUnderlyingAmount(
            IUniswapV2Pair(msg.sender),
            amount0,
            amount1,
            vars.underlying
        );

        // Check that the caller is a genuine UniswapV2Pair contract.
        if (msg.sender != pairFor(address(vars.collateral), address(vars.underlying))) {
            revert FlashUniswapV2__CallNotAuthorized(msg.sender);
        }

        // Mint hTokens and liquidate the borrower.
        vars.mintedHTokenAmount = mintHTokens(vars.bond, vars.underlyingAmount);
        vars.seizeAmount = liquidateBorrow(vars.borrower, vars.bond, vars.collateral, vars.mintedHTokenAmount);

        // Calculate the amount required to repay.
        vars.repayAmount = getRepayAmount(IUniswapV2Pair(msg.sender), vars.underlying, vars.underlyingAmount);

        // Note that "turnout" is a signed int. When it is negative, it acts as a maximum subsidy amount.
        // When its value is positive, it acts as a minimum profit.
        if (int256(vars.seizeAmount) < int256(vars.repayAmount) + vars.turnout) {
            revert FlashUniswapV2__TurnoutNotSatisfied(vars.seizeAmount, vars.repayAmount, vars.turnout);
        }

        // Transfer the subsidy amount.
        if (vars.repayAmount > vars.seizeAmount) {
            unchecked {
                vars.subsidyAmount = vars.repayAmount - vars.seizeAmount;
            }
            vars.collateral.safeTransferFrom(sender, address(this), vars.subsidyAmount);
        }
        // Or reap the profit.
        else if (vars.seizeAmount > vars.repayAmount) {
            unchecked {
                vars.profitAmount = vars.seizeAmount - vars.repayAmount;
            }
            vars.collateral.safeTransfer(sender, vars.profitAmount);
        }

        // Pay back the loan.
        vars.collateral.safeTransfer(msg.sender, vars.repayAmount);

        // Emit an event.
        emit FlashSwapAndLiquidateBorrow(
            sender,
            vars.borrower,
            address(vars.bond),
            vars.underlyingAmount,
            vars.seizeAmount,
            vars.repayAmount,
            vars.subsidyAmount,
            vars.profitAmount
        );
    }

    /// INTERNAL CONSTANT FUNCTIONS ///

    
    
    ///
    /// Requirements:
    ///
    /// - The amount of non-underlying flash borrowed must be zero.
    /// - The underlying must be one of the pair's tokens.
    ///
    
    
    
    
    
    
    function getCollateralAddressAndUnderlyingAmount(
        IUniswapV2Pair pair,
        uint256 amount0,
        uint256 amount1,
        IErc20 underlying
    ) internal view returns (IErc20 collateral, uint256 underlyingAmount) {
        address token0 = pair.token0();
        address token1 = pair.token1();
        if (token0 == address(underlying)) {
            if (amount1 > 0) {
                revert FlashUniswapV2__FlashBorrowCollateral(token1, token0);
            }
            collateral = IErc20(token1);
            underlyingAmount = amount0;
        } else if (token1 == address(underlying)) {
            if (amount0 > 0) {
                revert FlashUniswapV2__FlashBorrowCollateral(token0, token1);
            }
            collateral = IErc20(token0);
            underlyingAmount = amount1;
        } else {
            revert FlashUniswapV2__UnderlyingNotInPool(pair, token0, token1, underlying);
        }
    }

    
    function pairFor(address tokenA, address tokenB) internal view returns (address pair) {
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            uniV2Factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            uniV2PairInitCodeHash
                        )
                    )
                )
            )
        );
    }

    /// INTERNAL NON-CONSTANT FUNCTIONS ///

    
    function liquidateBorrow(
        address borrower,
        IHToken bond,
        IErc20 collateral,
        uint256 mintedHTokenAmount
    ) internal returns (uint256 seizeCollateralAmount) {
        uint256 collateralAmount = balanceSheet.getCollateralAmount(borrower, collateral);
        uint256 hypotheticalRepayAmount = balanceSheet.getRepayAmount(collateral, collateralAmount, bond);

        // If the hypothetical repay amount is bigger than the debt amount, this could be a single-collateral multi-bond
        // vault. Otherwise, it could be a multi-collateral single-bond vault. However, it is difficult to generalize
        // for the multi-collateral and multi-bond situation. The repay amount could be greater, smaller, or equal
        // to the debt amount depending on the collateral and debt amount distribution.
        uint256 debtAmount = balanceSheet.getDebtAmount(borrower, bond);
        uint256 repayAmount = hypotheticalRepayAmount > debtAmount ? debtAmount : hypotheticalRepayAmount;

        // Truncate the repay amount such that we keep the dust in this contract rather than the BalanceSheet.
        uint256 truncatedRepayAmount = mintedHTokenAmount > repayAmount ? repayAmount : mintedHTokenAmount;

        // Liquidate borrow.
        uint256 oldCollateralBalance = collateral.balanceOf(address(this));
        balanceSheet.liquidateBorrow(borrower, bond, truncatedRepayAmount, collateral);
        uint256 newCollateralBalance = collateral.balanceOf(address(this));
        unchecked {
            seizeCollateralAmount = newCollateralBalance - oldCollateralBalance;
        }
    }

    
    function mintHTokens(IHToken bond, uint256 underlyingAmount) internal returns (uint256 mintedHTokenAmount) {
        IErc20 underlying = bond.underlying();

        // Allow the HToken contract to spend underlying if allowance not enough.
        uint256 allowance = underlying.allowance(address(this), address(bond));
        if (allowance < underlyingAmount) {
            underlying.approve(address(bond), type(uint256).max);
        }

        // Deposit underlying to mint hTokens.
        uint256 oldHTokenBalance = bond.balanceOf(address(this));
        bond.depositUnderlying(underlyingAmount);
        uint256 newHTokenBalance = bond.balanceOf(address(this));
        unchecked {
            mintedHTokenAmount = newHTokenBalance - oldHTokenBalance;
        }
    }
}

// 
pragma solidity >=0.8.4;





error SafeErc20__CallToNonContract(address target);


error SafeErc20__NoReturnData();




/// returns false). Tokens that return no value (and instead revert or throw
/// on failure) are also supported, non-reverting calls are assumed to be successful.
///
/// To use this library you can add a `using SafeErc20 for IErc20;` statement to your contract,
/// which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
///

/// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/utils/Address.sol
library SafeErc20 {
    using Address for address;

    /// INTERNAL FUNCTIONS ///

    function safeTransfer(
        IErc20 token,
        address to,
        uint256 amount
    ) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, amount));
    }

    function safeTransferFrom(
        IErc20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, amount));
    }

    /// PRIVATE FUNCTIONS ///

    
    /// on the return value: the return value is optional (but if data is returned, it cannot be false).
    
    
    function callOptionalReturn(IErc20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.
        bytes memory returndata = functionCall(address(token), data, "SafeErc20LowLevelCall");
        if (returndata.length > 0) {
            // Return data is optional.
            if (!abi.decode(returndata, (bool))) {
                revert SafeErc20__NoReturnData();
            }
        }
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) private returns (bytes memory) {
        if (!target.isContract()) {
            revert SafeErc20__CallToNonContract(target);
        }

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present.
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly.
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// 
pragma solidity >=0.8.4;











interface IBalanceSheetV2 is IOwnableUpgradeable {
    /// CUSTOM ERRORS ///

    
    error BalanceSheet__BondMatured(IHToken bond);

    
    error BalanceSheet__BorrowMaxBonds(IHToken bond, uint256 newBondListLength, uint256 maxBonds);

    
    error BalanceSheet__BorrowNotAllowed(IHToken bond);

    
    error BalanceSheet__BorrowZero();

    
    error BalanceSheet__CollateralCeilingOverflow(uint256 newTotalSupply, uint256 debtCeiling);

    
    error BalanceSheet__DebtCeilingOverflow(uint256 newCollateralAmount, uint256 debtCeiling);

    
    error BalanceSheet__DepositCollateralNotAllowed(IErc20 collateral);

    
    error BalanceSheet__DepositCollateralZero();

    
    error BalanceSheet__FintrollerZeroAddress();

    
    error BalanceSheet__LiquidateBorrowInsufficientCollateral(
        address account,
        uint256 vaultCollateralAmount,
        uint256 seizableAmount
    );

    
    error BalanceSheet__LiquidateBorrowNotAllowed(IHToken bond);

    
    error BalanceSheet__LiquidateBorrowSelf(address account);

    
    error BalanceSheet__LiquidityShortfall(address account, uint256 shortfallLiquidity);

    
    error BalanceSheet__NoLiquidityShortfall(address account);

    
    error BalanceSheet__OracleZeroAddress();

    
    error BalanceSheet__RepayBorrowInsufficientBalance(IHToken bond, uint256 repayAmount, uint256 hTokenBalance);

    
    error BalanceSheet__RepayBorrowInsufficientDebt(IHToken bond, uint256 repayAmount, uint256 debtAmount);

    
    error BalanceSheet__RepayBorrowNotAllowed(IHToken bond);

    
    error BalanceSheet__RepayBorrowZero();

    
    error BalanceSheet__WithdrawCollateralUnderflow(
        address account,
        uint256 vaultCollateralAmount,
        uint256 withdrawAmount
    );

    
    error BalanceSheet__WithdrawCollateralZero();

    /// EVENTS ///

    
    
    
    
    event Borrow(address indexed account, IHToken indexed bond, uint256 borrowAmount);

    
    
    
    
    event DepositCollateral(address indexed account, IErc20 indexed collateral, uint256 collateralAmount);

    
    
    
    
    
    
    
    event LiquidateBorrow(
        address indexed liquidator,
        address indexed borrower,
        IHToken indexed bond,
        uint256 repayAmount,
        IErc20 collateral,
        uint256 seizedCollateralAmount
    );

    
    
    
    
    
    
    event RepayBorrow(
        address indexed payer,
        address indexed borrower,
        IHToken indexed bond,
        uint256 repayAmount,
        uint256 newDebtAmount
    );

    
    
    
    
    event SetFintroller(address indexed owner, address oldFintroller, address newFintroller);

    
    
    
    
    event SetOracle(address indexed owner, address oldOracle, address newOracle);

    
    
    
    
    event WithdrawCollateral(address indexed account, IErc20 indexed collateral, uint256 collateralAmount);

    /// CONSTANT FUNCTIONS ///

    
    
    
    function getBondList(address account) external view returns (IHToken[] memory);

    
    
    
    
    function getCollateralAmount(address account, IErc20 collateral) external view returns (uint256 collateralAmount);

    
    
    
    function getCollateralList(address account) external view returns (IErc20[] memory);

    
    
    
    
    function getCurrentAccountLiquidity(address account)
        external
        view
        returns (uint256 excessLiquidity, uint256 shortfallLiquidity);

    
    
    
    
    function getDebtAmount(address account, IHToken bond) external view returns (uint256 debtAmount);

    
    /// using the current prices provided by the oracle.
    ///
    
    /// respective collateral ratio, then dividing the sum by the total amount of debt drawn by the user.
    ///
    /// Caveats:
    /// - This function expects that the "collateralList" and the "bondList" are each modified in advance to include
    /// the collateral and bond due to be modified.
    ///
    
    
    
    
    
    
    
    function getHypotheticalAccountLiquidity(
        address account,
        IErc20 collateralModify,
        uint256 collateralAmountModify,
        IHToken bondModify,
        uint256 debtAmountModify
    ) external view returns (uint256 excessLiquidity, uint256 shortfallLiquidity);

    
    /// Note that this is for informational purposes only, it doesn't say anything about whether the user can be
    /// liquidated.
    
    /// repayAmount = (seizableCollateralAmount * collateralPriceUsd) / (liquidationIncentive * underlyingPriceUsd)
    
    
    
    
    function getRepayAmount(
        IErc20 collateral,
        uint256 seizableCollateralAmount,
        IHToken bond
    ) external view returns (uint256 repayAmount);

    
    /// is for informational purposes only, it doesn't say anything about whether the user can be liquidated.
    
    /// seizableCollateralAmount = repayAmount * liquidationIncentive * underlyingPriceUsd / collateralPriceUsd
    
    
    
    
    function getSeizableCollateralAmount(
        IHToken bond,
        uint256 repayAmount,
        IErc20 collateral
    ) external view returns (uint256 seizableCollateralAmount);

    /// NON-CONSTANT FUNCTIONS ///

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The Fintroller must allow this action to be performed.
    /// - The maturity of the bond must be in the future.
    /// - The amount to borrow cannot be zero.
    /// - The new length of the bond list must be below the max bonds limit.
    /// - The new total amount of debt cannot exceed the debt ceiling.
    /// - The caller must not end up having a shortfall of liquidity.
    ///
    
    
    function borrow(IHToken bond, uint256 borrowAmount) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The Fintroller must allow this action to be performed.
    /// - The amount to deposit cannot be zero.
    /// - The caller must have allowed this contract to spend `collateralAmount` tokens.
    /// - The new collateral amount cannot exceed the collateral ceiling.
    ///
    
    
    function depositCollateral(IErc20 collateral, uint256 depositAmount) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - All from "repayBorrow".
    /// - The caller cannot be the same with the borrower.
    /// - The Fintroller must allow this action to be performed.
    /// - The borrower must have a shortfall of liquidity if the bond didn't mature.
    /// - The amount of seized collateral cannot be more than what the borrower has in the vault.
    ///
    
    
    
    
    function liquidateBorrow(
        address borrower,
        IHToken bond,
        uint256 repayAmount,
        IErc20 collateral
    ) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The amount to repay cannot be zero.
    /// - The Fintroller must allow this action to be performed.
    /// - The caller must have at least `repayAmount` hTokens.
    /// - The caller must have at least `repayAmount` debt.
    ///
    
    
    function repayBorrow(IHToken bond, uint256 repayAmount) external;

    
    ///
    
    ///
    /// Requirements:
    /// - Same as the `repayBorrow` function, but here `borrower` is the account that must have at least
    /// `repayAmount` hTokens to repay the borrow.
    ///
    
    
    
    function repayBorrowBehalf(
        address borrower,
        IHToken bond,
        uint256 repayAmount
    ) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The new address cannot be the zero address.
    ///
    
    function setFintroller(IFintroller newFintroller) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The new address cannot be the zero address.
    ///
    
    function setOracle(IChainlinkOperator newOracle) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The amount to withdraw cannot be zero.
    /// - There must be enough collateral in the vault.
    /// - The caller's account cannot fall below the collateral ratio.
    ///
    
    
    function withdrawCollateral(IErc20 collateral, uint256 withdrawAmount) external;
}

// 
pragma solidity >=0.8.4;












interface IHToken is
    IOwnable, // no dependency
    IErc20Permit, // one dependency
    IErc20Recover // one dependency
{
    /// CUSTOM ERRORS ///

    
    error HToken__BondMatured(uint256 now, uint256 maturity);

    
    error HToken__BondNotMatured(uint256 now, uint256 maturity);

    
    error HToken__BurnNotAuthorized(address caller);

    
    error HToken__DepositUnderlyingNotAllowed();

    
    error HToken__DepositUnderlyingZero();

    
    error HToken__MaturityPassed(uint256 now, uint256 maturity);

    
    error HToken__MintNotAuthorized(address caller);

    
    error HToken__RedeemInsufficientLiquidity(uint256 underlyingAmount, uint256 totalUnderlyingReserve);

    
    error HToken__RedeemZero();

    
    error HToken__UnderlyingDecimalsOverflow(uint256 decimals);

    
    error HToken__UnderlyingDecimalsZero();

    
    error HToken__WithdrawUnderlyingUnderflow(address depositor, uint256 availableAmount, uint256 underlyingAmount);

    
    error HToken__WithdrawUnderlyingZero();

    /// EVENTS ///

    
    
    
    event Burn(address indexed holder, uint256 burnAmount);

    
    
    
    
    event DepositUnderlying(address indexed depositor, uint256 depositUnderlyingAmount, uint256 hTokenAmount);

    
    
    
    event Mint(address indexed beneficiary, uint256 mintAmount);

    
    
    
    
    event Redeem(address indexed account, uint256 underlyingAmount, uint256 hTokenAmount);

    
    
    
    
    event SetBalanceSheet(address indexed owner, IBalanceSheetV2 oldBalanceSheet, IBalanceSheetV2 newBalanceSheet);

    
    
    
    
    event WithdrawUnderlying(address indexed depositor, uint256 underlyingAmount, uint256 hTokenAmount);

    /// PUBLIC CONSTANT FUNCTIONS ///

    
    function balanceSheet() external view returns (IBalanceSheetV2);

    
    function getDepositorBalance(address depositor) external view returns (uint256 amount);

    
    function fintroller() external view returns (IFintroller);

    
    
    function isMatured() external view returns (bool);

    
    function maturity() external view returns (uint256);

    
    function totalUnderlyingReserve() external view returns (uint256);

    
    function underlying() external view returns (IErc20);

    
    function underlyingPrecisionScalar() external view returns (uint256);

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    ///
    
    ///
    /// Requirements:
    /// - Can only be called by the BalanceSheet contract.
    ///
    
    
    function burn(address holder, uint256 burnAmount) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The Fintroller must allow this action to be performed.
    /// - The underlying amount to deposit cannot be zero.
    /// - The caller must have allowed this contract to spend `underlyingAmount` tokens.
    ///
    
    function depositUnderlying(uint256 underlyingAmount) external;

    
    ///
    
    ///
    /// Requirements:
    /// - Can only be called by the BalanceSheet contract.
    ///
    
    
    function mint(address beneficiary, uint256 mintAmount) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - Can only be called after maturation.
    /// - The amount of underlying to redeem cannot be zero.
    /// - There must be enough liquidity in the contract.
    ///
    
    function redeem(uint256 underlyingAmount) external;

    
    ///
    
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    
    function _setBalanceSheet(IBalanceSheetV2 newBalanceSheet) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The underlying amount to withdraw cannot be zero.
    /// - Can only be called before maturation.
    ///
    
    function withdrawUnderlying(uint256 underlyingAmount) external;
}

// 
// solhint-disable
pragma solidity >=0.5.0;


interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// 
pragma solidity >=0.8.4;





/// https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/v3.4.0/contracts/utils/Address.sol
library Address {
    
    ///
    /// IMPORTANT: It is unsafe to assume that an address for which this function returns false is an
    /// externally-owned account (EOA) and not a contract.
    ///
    /// Among others, `isContract` will return false for the following types of addresses:
    ///
    /// - An externally-owned account
    /// - A contract in construction
    /// - An address where a contract will be created
    /// - An address where a contract lived, but was destroyed
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`.
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }
}

// 
pragma solidity >=0.8.4;









interface IFintroller is IOwnable {
    /// CUSTOM ERRORS ///

    
    error Fintroller__BondNotListed(IHToken bond);

    
    error Fintroller__CollateralDecimalsOverflow(uint256 decimals);

    
    error Fintroller__CollateralDecimalsZero();

    
    error Fintroller__CollateralNotListed(IErc20 collateral);

    
    error Fintroller__CollateralRatioOverflow(uint256 newCollateralRatio);

    
    error Fintroller__CollateralRatioUnderflow(uint256 newCollateralRatio);

    
    error Fintroller__DebtCeilingUnderflow(uint256 newDebtCeiling, uint256 totalSupply);

    
    error Fintroller__LiquidationIncentiveOverflow(uint256 newLiquidationIncentive);

    
    error Fintroller__LiquidationIncentiveUnderflow(uint256 newLiquidationIncentive);

    /// EVENTS ///

    
    
    
    event ListBond(address indexed owner, IHToken indexed bond);

    
    
    
    event ListCollateral(address indexed owner, IErc20 indexed collateral);

    
    
    
    
    event SetBorrowAllowed(address indexed owner, IHToken indexed bond, bool state);

    
    
    
    
    
    event SetCollateralCeiling(
        address indexed owner,
        IErc20 indexed collateral,
        uint256 oldCollateralCeiling,
        uint256 newCollateralCeiling
    );

    
    
    
    
    
    event SetCollateralRatio(
        address indexed owner,
        IErc20 indexed collateral,
        uint256 oldCollateralRatio,
        uint256 newCollateralRatio
    );

    
    
    
    
    
    event SetDebtCeiling(address indexed owner, IHToken indexed bond, uint256 oldDebtCeiling, uint256 newDebtCeiling);

    
    
    
    event SetDepositCollateralAllowed(address indexed owner, IErc20 indexed collateral, bool state);

    
    
    
    
    event SetDepositUnderlyingAllowed(address indexed owner, IHToken indexed bond, bool state);

    
    
    
    
    event SetLiquidateBorrowAllowed(address indexed owner, IHToken indexed bond, bool state);

    
    
    
    
    
    event SetLiquidationIncentive(
        address indexed owner,
        IErc20 collateral,
        uint256 oldLiquidationIncentive,
        uint256 newLiquidationIncentive
    );

    
    
    
    
    event SetMaxBonds(address indexed owner, uint256 oldMaxBonds, uint256 newMaxBonds);

    
    
    
    
    event SetRedeemAllowed(address indexed owner, IHToken indexed bond, bool state);

    
    
    
    
    event SetRepayBorrowAllowed(address indexed owner, IHToken indexed bond, bool state);

    /// STRUCTS ///

    struct Bond {
        uint256 debtCeiling;
        bool isBorrowAllowed;
        bool isDepositUnderlyingAllowed;
        bool isLiquidateBorrowAllowed;
        bool isListed;
        bool isRedeemHTokenAllowed;
        bool isRepayBorrowAllowed;
    }

    struct Collateral {
        uint256 ceiling;
        uint256 ratio;
        uint256 liquidationIncentive;
        bool isDepositCollateralAllowed;
        bool isListed;
    }

    /// CONSTANT FUNCTIONS ///

    
    
    
    
    function getBond(IHToken bond) external view returns (Bond memory);

    
    
    
    
    function getBorrowAllowed(IHToken bond) external view returns (bool);

    
    
    
    
    function getCollateral(IErc20 collateral) external view returns (Collateral memory);

    
    
    
    
    function getCollateralCeiling(IErc20 collateral) external view returns (uint256);

    
    
    
    
    function getCollateralRatio(IErc20 collateral) external view returns (uint256);

    
    
    
    
    function getDebtCeiling(IHToken bond) external view returns (uint256);

    
    
    
    
    function getDepositCollateralAllowed(IErc20 collateral) external view returns (bool);

    
    
    
    
    function getDepositUnderlyingAllowed(IHToken bond) external view returns (bool);

    
    
    
    
    function getLiquidationIncentive(IErc20 collateral) external view returns (uint256);

    
    
    
    
    function getLiquidateBorrowAllowed(IHToken bond) external view returns (bool);

    
    
    
    
    function getRepayBorrowAllowed(IHToken bond) external view returns (bool);

    
    
    
    function isBondListed(IHToken bond) external view returns (bool);

    
    
    
    function isCollateralListed(IErc20 collateral) external view returns (bool);

    
    function maxBonds() external view returns (uint256);

    /// NON-CONSTANT FUNCTIONS ///

    
    ///
    
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    
    function listBond(IHToken bond) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The collateral must have between 1 and 18 decimals.
    ///
    
    function listCollateral(IErc20 collateral) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The bond must be listed.
    ///
    
    
    function setBorrowAllowed(IHToken bond, bool state) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The collateral must be listed.
    ///
    
    
    function setCollateralCeiling(IHToken collateral, uint256 newCollateralCeiling) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The collateral must be listed.
    /// - The new collateral ratio cannot be higher than the maximum collateral ratio.
    /// - The new collateral ratio cannot be lower than the minimum collateral ratio.
    ///
    
    
    function setCollateralRatio(IErc20 collateral, uint256 newCollateralRatio) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The bond must be listed.
    /// - The debt ceiling cannot fall below the current total supply of hTokens.
    ///
    
    
    function setDebtCeiling(IHToken bond, uint256 newDebtCeiling) external;

    
    ///
    
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    
    
    function setDepositCollateralAllowed(IErc20 collateral, bool state) external;

    
    ///
    
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    
    
    function setDepositUnderlyingAllowed(IHToken bond, bool state) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The collateral must be listed.
    /// - The new liquidation incentive cannot be higher than the maximum liquidation incentive.
    /// - The new liquidation incentive cannot be lower than the minimum liquidation incentive.
    ///
    
    
    function setLiquidationIncentive(IErc20 collateral, uint256 newLiquidationIncentive) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The bond must be listed.
    ///
    
    
    function setLiquidateBorrowAllowed(IHToken bond, bool state) external;

    
    ///
    
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    
    function setMaxBonds(uint256 newMaxBonds) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The bond must be listed.
    ///
    
    
    function setRepayBorrowAllowed(IHToken bond, bool state) external;
}

// 
pragma solidity >=0.8.4;









interface IChainlinkOperator {
    /// CUSTOM ERRORS ///

    
    error ChainlinkOperator__DecimalsMismatch(string symbol, uint256 decimals);

    
    error ChainlinkOperator__FeedNotSet(string symbol);

    
    error ChainlinkOperator__PriceZero(string symbol);

    /// EVENTS ///

    
    
    
    event DeleteFeed(IErc20 indexed asset, IAggregatorV3 indexed feed);

    
    
    
    event SetFeed(IErc20 indexed asset, IAggregatorV3 indexed feed);

    /// STRUCTS ///

    struct Feed {
        IErc20 asset;
        IAggregatorV3 id;
        bool isSet;
    }

    /// CONSTANT FUNCTIONS ///

    
    
    
    function getFeed(string memory symbol)
        external
        view
        returns (
            IErc20,
            IAggregatorV3,
            bool
        );

    
    /// format used by Chainlink, which has 8 decimals.
    ///
    
    /// - The normalized price cannot overflow.
    ///
    
    
    function getNormalizedPrice(string memory symbol) external view returns (uint256);

    
    /// has 8 decimals.
    ///
    
    ///
    /// - The feed must be set.
    /// - The price returned by the oracle cannot be zero.
    ///
    
    
    function getPrice(string memory symbol) external view returns (uint256);

    
    function pricePrecision() external view returns (uint256);

    
    function pricePrecisionScalar() external view returns (uint256);

    /// NON-CONSTANT FUNCTIONS ///

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The feed must be set already.
    ///
    
    function deleteFeed(string memory symbol) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The number of decimals of the feed must be 8.
    ///
    
    
    function setFeed(IErc20 asset, IAggregatorV3 feed) external;
}

// 
pragma solidity >=0.8.4;




/// github.com/smartcontractkit/chainlink/blob/v1.2.0/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol
interface IAggregatorV3 {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    /// getRoundData and latestRoundData should both raise "No data present" if they do not have
    /// data to report, instead of returning unset values which could be misinterpreted as
    /// actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}
