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

/// 
// solhint-disable func-name-mixedcase
pragma solidity >=0.8.4;












interface IHifiProxyTarget {
    /// CUSTOM ERRORS ///

    
    error HifiProxyTarget__AddLiquidityHTokenSlippage(uint256 expectedHTokenRequired, uint256 actualHTokenRequired);

    
    error HifiProxyTarget__AddLiquidityUnderlyingSlippage(
        uint256 expectedUnderlyingRequired,
        uint256 actualUnderlyingRequired
    );

    
    error HifiProxyTarget__TradeSlippage(uint256 expectedAmount, uint256 actualAmount);

    /// EVENTS

    
    
    
    
    event BorrowHTokenAndBuyUnderlying(address indexed borrower, uint256 borrowAmount, uint256 underlyingAmount);

    
    
    
    
    event BorrowHTokenAndSellHToken(address indexed borrower, uint256 borrowAmount, uint256 underlyingAmount);

    /// NON-CONSTANT FUNCTIONS ///

    
    ///
    /// Requirements:
    /// - The caller must have allowed the DSProxy to spend `underlyingAmount` and `maxHTokenRequired` tokens.
    ///
    
    
    
    function addLiquidity(
        IHifiPool hifiPool,
        uint256 underlyingOffered,
        uint256 maxHTokenRequired
    ) external;

    
    ///
    /// Requirements:
    /// - The `signature` must be a valid signed approval given by caller to the DSProxy to spend `underlyingAmount`
    /// and `maxHTokenRequired` tokens for the given `deadline` and the caller's current nonce.
    ///
    
    
    
    
    
    
    function addLiquidityWithSignature(
        IHifiPool hifiPool,
        uint256 underlyingOffered,
        uint256 maxHTokenRequired,
        uint256 deadline,
        bytes memory signatureHToken,
        bytes memory signatureUnderlying
    ) external;

    
    
    
    
    function borrowHToken(
        IBalanceSheetV2 balanceSheet,
        IHToken hToken,
        uint256 borrowAmount
    ) external;

    
    ///
    /// Requirements:
    /// - The caller must have allowed the DSProxy to spend `underlyingAmount` tokens.
    ///
    
    
    
    
    function borrowHTokenAndAddLiquidity(
        IBalanceSheetV2 balanceSheet,
        IHifiPool hifiPool,
        uint256 maxBorrowAmount,
        uint256 underlyingOffered
    ) external;

    
    ///
    /// Requirements:
    /// - The `signature` must be a valid signed approval given by the caller to the DSProxy to spend
    /// `underlyingOffered` tokens for the given `deadline` and the caller's current nonce.
    ///
    
    
    
    
    
    
    function borrowHTokenAndAddLiquidityWithSignature(
        IBalanceSheetV2 balanceSheet,
        IHifiPool hifiPool,
        uint256 maxBorrowAmount,
        uint256 underlyingOffered,
        uint256 deadline,
        bytes memory signatureUnderlying
    ) external;

    
    ///
    
    ///
    
    
    
    
    function borrowHTokenAndBuyUnderlying(
        IBalanceSheetV2 balanceSheet,
        IHifiPool hifiPool,
        uint256 maxBorrowAmount,
        uint256 underlyingOut
    ) external;

    
    ///
    
    ///
    
    
    
    
    function borrowHTokenAndSellHToken(
        IBalanceSheetV2 balanceSheet,
        IHifiPool hifiPool,
        uint256 borrowAmount,
        uint256 minUnderlyingOut
    ) external;

    
    ///
    /// Requirements:
    /// - The caller must have allowed DSProxy to spend `maxUnderlyingIn` tokens.
    ///
    
    
    
    function buyHToken(
        IHifiPool hifiPool,
        uint256 hTokenOut,
        uint256 maxUnderlyingIn
    ) external;

    
    ///
    /// Requirements:
    /// - The caller must have allowed DSProxy to spend `maxUnderlyingIn + underlyingOffered` tokens.
    ///
    
    
    
    function buyHTokenAndAddLiquidity(
        IHifiPool hifiPool,
        uint256 hTokenOut,
        uint256 maxUnderlyingAmount
    ) external;

    
    ///
    /// Requirements:
    /// - The `signature` must be a valid signed approval given by the caller to the DSProxy to spend
    /// `maxUnderlyingIn + underlyingOffered` tokens for the given `deadline` and the caller's current nonce.
    ///
    
    
    
    
    
    function buyHTokenAndAddLiquidityWithSignature(
        IHifiPool hifiPool,
        uint256 hTokenOut,
        uint256 maxUnderlyingAmount,
        uint256 deadline,
        bytes memory signatureUnderlying
    ) external;

    
    ///
    
    /// - The caller must have allowed the DSProxy to spend `maxUnderlyingIn` tokens.
    ///
    
    
    
    
    function buyHTokenAndRepayBorrow(
        IHifiPool hifiPool,
        IBalanceSheetV2 balanceSheet,
        uint256 maxUnderlyingIn,
        uint256 hTokenOut
    ) external;

    
    ///
    
    /// - The `signature` must be a valid signed approval given by the caller to the DSProxy to spend `maxUnderlyingIn`
    /// tokens for the given `deadline` and the caller's current nonce.
    ///
    
    
    
    
    
    
    function buyHTokenAndRepayBorrowWithSignature(
        IHifiPool hifiPool,
        IBalanceSheetV2 balanceSheet,
        uint256 maxUnderlyingIn,
        uint256 hTokenOut,
        uint256 deadline,
        bytes memory signatureUnderlying
    ) external;

    
    ///
    /// Requirements:
    /// - The `signature` must be a valid signed approval given by the caller to the DSProxy to spend `maxUnderlyingIn`
    /// tokens for the given `deadline` and the caller's current nonce.
    ///
    
    
    
    
    
    function buyHTokenWithSignature(
        IHifiPool hifiPool,
        uint256 hTokenOut,
        uint256 maxUnderlyingIn,
        uint256 deadline,
        bytes memory signatureUnderlying
    ) external;

    
    ///
    /// Requirements:
    /// - The caller must have allowed DSProxy to spend `maxHTokenIn` tokens.
    ///
    
    
    
    function buyUnderlying(
        IHifiPool hifiPool,
        uint256 underlyingOut,
        uint256 maxHTokenIn
    ) external;

    
    ///
    /// - The caller must have allowed DSProxy to spend `maxHTokenAmount` tokens.
    ///
    
    
    
    function buyUnderlyingAndAddLiquidity(
        IHifiPool hifiPool,
        uint256 maxHTokenAmount,
        uint256 underlyingOffered
    ) external;

    
    ///
    /// - The `signature` must be a valid signed approval given by the caller to the DSProxy to spend
    /// `maxHTokenAmount` tokens for the given `deadline` and the caller's current nonce.
    ///
    
    
    
    
    
    function buyUnderlyingAndAddLiquidityWithSignature(
        IHifiPool hifiPool,
        uint256 maxHTokenAmount,
        uint256 underlyingOffered,
        uint256 deadline,
        bytes memory signatureHToken
    ) external;

    
    ///
    /// Requirements:
    /// - The `signature` must be a valid signed approval given by the caller to the DSProxy to spend `maxHTokenIn`
    /// tokens for the given `deadline` and the caller's current nonce.
    ///
    
    
    
    
    
    function buyUnderlyingWithSignature(
        IHifiPool hifiPool,
        uint256 underlyingOut,
        uint256 maxHTokenIn,
        uint256 deadline,
        bytes memory signatureHToken
    ) external;

    
    ///
    
    /// - The caller must have allowed the DSProxy to spend `collateralAmount` tokens.
    ///
    
    
    
    function depositCollateral(
        IBalanceSheetV2 balanceSheet,
        IErc20 collateral,
        uint256 depositAmount
    ) external;

    
    ///
    /// Requirements:
    /// - The caller must have allowed the DSProxy to spend `collateralAmount` tokens.
    ///
    
    
    
    
    
    function depositCollateralAndBorrowHToken(
        IBalanceSheetV2 balanceSheet,
        IErc20 collateral,
        IHToken hToken,
        uint256 depositAmount,
        uint256 borrowAmount
    ) external;

    
    ///
    /// Requirements:
    /// - The caller must have allowed the DSProxy to spend `collateralAmount` tokens.
    ///
    
    
    
    
    
    
    function depositCollateralAndBorrowHTokenAndAddLiquidity(
        IBalanceSheetV2 balanceSheet,
        IErc20 collateral,
        IHifiPool hifiPool,
        uint256 depositAmount,
        uint256 maxBorrowAmount,
        uint256 underlyingOffered
    ) external;

    
    /// signatures.
    ///
    /// Requirements:
    /// - The `signature` must be a valid signed approval given by the caller to the DSProxy to spend `collateralAmount`
    /// and `underlyingAmount` tokens for the given `deadline` and the caller's current nonce.
    ///
    
    
    
    
    
    
    
    
    
    function depositCollateralAndBorrowHTokenAndAddLiquidityWithSignature(
        IBalanceSheetV2 balanceSheet,
        IErc20Permit collateral,
        IHifiPool hifiPool,
        uint256 depositAmount,
        uint256 maxBorrowAmount,
        uint256 underlyingOffered,
        uint256 deadline,
        bytes memory signatureCollateral,
        bytes memory signatureUnderlying
    ) external;

    
    ///
    /// Requirements:
    /// - The caller must have allowed the DSProxy to spend `collateralAmount` tokens.
    ///
    
    
    
    
    
    
    function depositCollateralAndBorrowHTokenAndSellHToken(
        IBalanceSheetV2 balanceSheet,
        IErc20 collateral,
        IHifiPool hifiPool,
        uint256 depositAmount,
        uint256 borrowAmount,
        uint256 minUnderlyingOut
    ) external;

    
    ///
    /// Requirements:
    /// - The `signature` must be a valid signed approval given by the caller to the DSProxy to spend `collateralAmount`
    /// and `underlyingAmount` for the given `deadline` and the caller's current nonce.
    ///
    
    
    
    
    
    
    
    
    function depositCollateralAndBorrowHTokenAndSellHTokenWithSignature(
        IBalanceSheetV2 balanceSheet,
        IErc20Permit collateral,
        IHifiPool hifiPool,
        uint256 depositAmount,
        uint256 borrowAmount,
        uint256 minUnderlyingOut,
        uint256 deadline,
        bytes memory signatureCollateral
    ) external;

    
    ///
    /// Requirements:
    /// - The `signature` must be a valid signed approval given by the caller to the DSProxy to spend
    /// `depositAmount` `collateral` tokens for the given `deadline` and the caller's current nonce.
    ///
    
    
    
    
    
    
    
    function depositCollateralAndBorrowHTokenWithSignature(
        IBalanceSheetV2 balanceSheet,
        IErc20Permit collateral,
        IHToken hToken,
        uint256 depositAmount,
        uint256 borrowAmount,
        uint256 deadline,
        bytes memory signatureCollateral
    ) external;

    
    ///
    
    /// - The `signature` must be a valid signed approval given by the caller to the DSProxy to spend
    /// `depositAmount` tokens for the given `deadline` and the caller's current nonce.
    ///
    
    
    
    
    
    function depositCollateralWithSignature(
        IBalanceSheetV2 balanceSheet,
        IErc20Permit collateral,
        uint256 depositAmount,
        uint256 deadline,
        bytes memory signatureCollateral
    ) external;

    
    ///
    /// Requirements:
    /// - The caller must have allowed the DSProxy to spend `depositAmount + underlyingOffered` tokens.
    ///
    
    
    
    function depositUnderlyingAndMintHTokenAndAddLiquidity(
        IHifiPool hifiPool,
        uint256 depositAmount,
        uint256 underlyingOffered
    ) external;

    
    /// EIP-2612 signatures.
    ///
    /// Requirements:
    /// - The `signature` must be a valid signed approval given by the caller to the DSProxy to spend
    ///  `depositAmount + underlyingOffered` for the given `deadline` and the caller's current nonce.
    ///
    
    
    
    
    
    function depositUnderlyingAndMintHTokenAndAddLiquidityWithSignature(
        IHifiPool hifiPool,
        uint256 depositAmount,
        uint256 underlyingOffered,
        uint256 deadline,
        bytes memory signatureUnderlying
    ) external;

    
    ///
    
    /// - The caller must have allowed the DSProxy to spend `underlyingAmount` tokens.
    ///
    
    
    
    function depositUnderlyingAndRepayBorrow(
        IHToken hToken,
        IBalanceSheetV2 balanceSheet,
        uint256 underlyingAmount
    ) external;

    
    ///
    
    /// - The `signature` must be a valid signed approval given by the caller to the DSProxy to spend `underlyingAmount`
    ///   for the given `deadline` and the caller's current nonce.
    ///
    
    
    
    
    
    function depositUnderlyingAndRepayBorrowWithSignature(
        IHToken hToken,
        IBalanceSheetV2 balanceSheet,
        uint256 underlyingAmount,
        uint256 deadline,
        bytes memory signatureUnderlying
    ) external;

    
    ///
    
    /// - The caller must have allowed the DSProxy to spend `hTokenAmount` hTokens.
    ///
    
    
    
    function redeem(
        IHToken hToken,
        uint256 hTokenAmount,
        uint256 underlyingAmount
    ) external;

    
    ///
    
    /// - The `signature` must be a valid signed approval given by the caller to the DSProxy to spend  `hTokenAmount`
    ///  for the given `deadline` and the caller's current nonce.
    ///
    
    
    
    
    
    function redeemWithSignature(
        IHToken hToken,
        uint256 hTokenAmount,
        uint256 underlyingAmount,
        uint256 deadline,
        bytes memory signatureHToken
    ) external;

    
    ///
    
    /// - The caller must have allowed the DSProxy to spend `poolTokensBurned` tokens.
    ///
    
    
    function removeLiquidity(IHifiPool hifiPool, uint256 poolTokensBurned) external;

    
    /// retrieved from the AMM.
    ///
    
    /// - The caller must have allowed the DSProxy to spend `poolTokensBurned` tokens.
    ///
    
    
    function removeLiquidityAndRedeem(IHifiPool hifiPool, uint256 poolTokensBurned) external;

    
    ///
    
    /// - The `signature` must be a valid signed approval given by the caller to the DSProxy to spend `poolTokensBurned`
    ///  for the given `deadline` and the caller's current nonce.
    ///
    
    
    
    
    function removeLiquidityAndRedeemWithSignature(
        IHifiPool hifiPool,
        uint256 poolTokensBurned,
        uint256 deadline,
        bytes memory signatureLPToken
    ) external;

    
    ///
    
    /// - The caller must have allowed the DSProxy to spend `poolTokensBurned` tokens.
    ///
    
    
    
    function removeLiquidityAndSellHToken(
        IHifiPool hifiPool,
        uint256 poolTokensBurned,
        uint256 minUnderlyingOut
    ) external;

    
    ///
    
    /// - The `signature` must be a valid signed approval given by the caller to the DSProxy to spend `poolTokensBurned`
    ///  for the given `deadline` and the caller's current nonce.
    ///
    
    
    
    
    
    function removeLiquidityAndSellHTokenWithSignature(
        IHifiPool hifiPool,
        uint256 poolTokensBurned,
        uint256 minUnderlyingOut,
        uint256 deadline,
        bytes memory signatureLPToken
    ) external;

    
    ///
    
    /// - The caller must have allowed the DSProxy to spend `poolTokensBurned` tokens.
    /// - Can only be called before maturation.
    ///
    
    
    
    function removeLiquidityAndWithdrawUnderlying(
        IHifiPool hifiPool,
        uint256 poolTokensBurned,
        uint256 withdrawAmount
    ) external;

    
    /// using EIP-2612 signatures.
    ///
    
    /// - The `signature` must be a valid signed approval given by the caller to the DSProxy to spend `poolTokensBurned`
    ///  for the given `deadline` and the caller's current nonce.
    ///
    
    
    
    
    
    function removeLiquidityAndWithdrawUnderlyingWithSignature(
        IHifiPool hifiPool,
        uint256 poolTokensBurned,
        uint256 withdrawAmount,
        uint256 deadline,
        bytes memory signatureLPToken
    ) external;

    
    ///
    
    /// - The `signature` must be a valid signed approval given by the caller to the DSProxy to spend `poolTokensBurned`
    ///  for the given `deadline` and the caller's current nonce.
    ///
    
    
    
    
    function removeLiquidityWithSignature(
        IHifiPool hifiPool,
        uint256 poolTokensBurned,
        uint256 deadline,
        bytes memory signatureLPToken
    ) external;

    
    ///
    
    /// - The caller must have allowed the DSProxy to spend `repayAmount` hTokens.
    ///
    
    
    
    function repayBorrow(
        IBalanceSheetV2 balanceSheet,
        IHToken hToken,
        uint256 repayAmount
    ) external;

    
    ///
    
    /// - The `signature` must be a valid signed approval given by the caller to the DSProxy to spend `repayAmount`
    ///  hTokens for the given `deadline` and the caller's current nonce.
    ///
    
    
    
    
    
    function repayBorrowWithSignature(
        IBalanceSheetV2 balanceSheet,
        IHToken hToken,
        uint256 repayAmount,
        uint256 deadline,
        bytes memory signatureHToken
    ) external;

    
    ///
    /// Requirements:
    /// - The caller must have allowed DSProxy to spend `hTokenIn` tokens.
    ///
    
    
    
    function sellHToken(
        IHifiPool hifiPool,
        uint256 hTokenIn,
        uint256 minUnderlyingOut
    ) external;

    
    ///
    /// Requirements:
    /// - The `signature` must be a valid signed approval given by the caller to the DSProxy to spend `hTokenIn`
    ///  hTokens for the given `deadline` and the caller's current nonce.
    ///
    
    
    
    
    
    function sellHTokenWithSignature(
        IHifiPool hifiPool,
        uint256 hTokenIn,
        uint256 minUnderlyingOut,
        uint256 deadline,
        bytes memory signatureHToken
    ) external;

    
    ///
    /// Requirements:
    /// - The caller must have allowed DSProxy to spend `underlyingIn` tokens.
    ///
    
    
    
    function sellUnderlying(
        IHifiPool hifiPool,
        uint256 underlyingIn,
        uint256 minHTokenOut
    ) external;

    
    ///
    
    /// - The caller must have allowed the DSProxy to spend `underlyingIn` tokens.
    ///
    
    
    
    
    /// amount to repay.
    function sellUnderlyingAndRepayBorrow(
        IHifiPool hifiPool,
        IBalanceSheetV2 balanceSheet,
        uint256 underlyingIn,
        uint256 minHTokenOut
    ) external;

    
    ///
    
    /// - The `signature` must be a valid signed approval given by the caller to the DSProxy to spend `underlyingIn`
    ///   for the given `deadline` and the caller's current nonce.
    ///
    
    
    
    
    /// amount to repay.
    
    
    function sellUnderlyingAndRepayBorrowWithSignature(
        IHifiPool hifiPool,
        IBalanceSheetV2 balanceSheet,
        uint256 underlyingIn,
        uint256 minHTokenOut,
        uint256 deadline,
        bytes memory signatureUnderlying
    ) external;

    
    ///
    /// Requirements:
    /// - The `signature` must be a valid signed approval given by the caller to the DSProxy to spend `underlyingIn`
    ///   for the given `deadline` and the caller's current nonce.
    ///
    
    
    
    
    
    function sellUnderlyingWithSignature(
        IHifiPool hifiPool,
        uint256 underlyingIn,
        uint256 minHTokenOut,
        uint256 deadline,
        bytes memory signatureUnderlying
    ) external;

    
    
    
    
    function withdrawCollateral(
        IBalanceSheetV2 balanceSheet,
        IErc20 collateral,
        uint256 withdrawAmount
    ) external;

    
    
    
    
    function wrapEthAndDepositCollateral(WethInterface weth, IBalanceSheetV2 balanceSheet) external payable;

    
    ///
    
    ///
    
    
    
    
    
    function wrapEthAndDepositAndBorrowHTokenAndSellHToken(
        WethInterface weth,
        IBalanceSheetV2 balanceSheet,
        IHifiPool hifiPool,
        uint256 borrowAmount,
        uint256 minUnderlyingOut
    ) external payable;
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
/// 
pragma solidity ^0.8.4;













contract HifiProxyTarget is IHifiProxyTarget {
    using SafeErc20 for IErc20;

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    function addLiquidity(
        IHifiPool hifiPool,
        uint256 underlyingOffered,
        uint256 maxHTokenRequired
    ) public override {
        // Ensure that we are within the user's slippage tolerance.
        (uint256 hTokenRequired, ) = hifiPool.getMintInputs(underlyingOffered);
        if (hTokenRequired > maxHTokenRequired) {
            revert HifiProxyTarget__AddLiquidityHTokenSlippage(maxHTokenRequired, hTokenRequired);
        }

        // Transfer the underlying to the DSProxy.
        IErc20 underlying = hifiPool.underlying();
        underlying.safeTransferFrom(msg.sender, address(this), underlyingOffered);

        // Allow the HifiPool contract to spend underlying from the DSProxy.
        approveSpender(underlying, address(hifiPool), underlyingOffered);

        // Transfer the hTokens to the DSProxy.
        IHToken hToken = hifiPool.hToken();
        hToken.transferFrom(msg.sender, address(this), hTokenRequired);

        // Allow the HifiPool contract to spend hTokens from the DSProxy.
        approveSpender(hToken, address(hifiPool), hTokenRequired);

        // Add liquidity to the AMM.
        uint256 poolTokensMinted = hifiPool.mint(underlyingOffered);

        // The LP tokens are now in the DSProxy, so we relay them to the end user.
        hifiPool.transfer(msg.sender, poolTokensMinted);
    }

    
    function addLiquidityWithSignature(
        IHifiPool hifiPool,
        uint256 underlyingOffered,
        uint256 maxHTokenRequired,
        uint256 deadline,
        bytes memory signatureHToken,
        bytes memory signatureUnderlying
    ) external override {
        permitInternal(IErc20Permit(address(hifiPool.underlying())), underlyingOffered, deadline, signatureUnderlying);
        permitInternal(hifiPool.hToken(), maxHTokenRequired, deadline, signatureHToken);
        addLiquidity(hifiPool, underlyingOffered, maxHTokenRequired);
    }

    
    function borrowHToken(
        IBalanceSheetV2 balanceSheet,
        IHToken hToken,
        uint256 borrowAmount
    ) public override {
        balanceSheet.borrow(hToken, borrowAmount);

        // The hTokens are now in the DSProxy, so we relay them to the end user.
        hToken.transfer(msg.sender, borrowAmount);
    }

    
    function borrowHTokenAndAddLiquidity(
        IBalanceSheetV2 balanceSheet,
        IHifiPool hifiPool,
        uint256 maxBorrowAmount,
        uint256 underlyingOffered
    ) public override {
        // Ensure that we are within the user's slippage tolerance.
        (uint256 hTokenRequired, ) = hifiPool.getMintInputs(underlyingOffered);
        if (hTokenRequired > maxBorrowAmount) {
            revert HifiProxyTarget__AddLiquidityHTokenSlippage(maxBorrowAmount, hTokenRequired);
        }

        // Borrow the hTokens.
        IHToken hToken = hifiPool.hToken();
        balanceSheet.borrow(hToken, hTokenRequired);

        // Transfer the underlying to the DSProxy.
        IErc20 underlying = hifiPool.underlying();
        underlying.safeTransferFrom(msg.sender, address(this), underlyingOffered);

        // Allow the HifiPool contract to spend underlying from the DSProxy.
        approveSpender(underlying, address(hifiPool), underlyingOffered);

        // Allow the HifiPool contract to spend hTokens from the DSProxy.
        approveSpender(hToken, address(hifiPool), hTokenRequired);

        // Add liquidity to pool.
        uint256 poolTokensMinted = hifiPool.mint(underlyingOffered);

        // The LP tokens are now in the DSProxy, so we relay them to the end user.
        hifiPool.transfer(msg.sender, poolTokensMinted);
    }

    
    function borrowHTokenAndAddLiquidityWithSignature(
        IBalanceSheetV2 balanceSheet,
        IHifiPool hifiPool,
        uint256 maxBorrowAmount,
        uint256 underlyingOffered,
        uint256 deadline,
        bytes memory signatureUnderlying
    ) external override {
        permitInternal(IErc20Permit(address(hifiPool.underlying())), underlyingOffered, deadline, signatureUnderlying);
        borrowHTokenAndAddLiquidity(balanceSheet, hifiPool, maxBorrowAmount, underlyingOffered);
    }

    
    function borrowHTokenAndBuyUnderlying(
        IBalanceSheetV2 balanceSheet,
        IHifiPool hifiPool,
        uint256 maxBorrowAmount,
        uint256 underlyingOut
    ) external override {
        // Ensure that we are within the user's slippage tolerance.
        uint256 hTokenIn = hifiPool.getQuoteForBuyingUnderlying(underlyingOut);
        if (hTokenIn > maxBorrowAmount) {
            revert HifiProxyTarget__TradeSlippage(maxBorrowAmount, hTokenIn);
        }

        // Borrow the hTokens.
        IHToken hToken = hifiPool.hToken();
        balanceSheet.borrow(hToken, hTokenIn);

        // Allow the HifiPool contract to spend hTokens from the DSProxy.
        approveSpender(hToken, address(hifiPool), hTokenIn);

        // Buy underlying and relay it to the end user.
        hifiPool.buyUnderlying(msg.sender, underlyingOut);

        emit BorrowHTokenAndBuyUnderlying(msg.sender, hTokenIn, underlyingOut);
    }

    
    function borrowHTokenAndSellHToken(
        IBalanceSheetV2 balanceSheet,
        IHifiPool hifiPool,
        uint256 borrowAmount,
        uint256 minUnderlyingOut
    ) public override {
        // Ensure that we are within the user's slippage tolerance.
        uint256 underlyingOut = hifiPool.getQuoteForSellingHToken(borrowAmount);
        if (underlyingOut < minUnderlyingOut) {
            revert HifiProxyTarget__TradeSlippage(minUnderlyingOut, underlyingOut);
        }

        // Borrow the hTokens.
        IHToken hToken = hifiPool.hToken();
        balanceSheet.borrow(hToken, borrowAmount);

        // Allow the HifiPool contract to spend hTokens from the DSProxy.
        approveSpender(hToken, address(hifiPool), borrowAmount);

        // Sell the hTokens and relay the underlying to the end user.
        hifiPool.sellHToken(msg.sender, borrowAmount);

        emit BorrowHTokenAndSellHToken(msg.sender, borrowAmount, underlyingOut);
    }

    
    function buyHToken(
        IHifiPool hifiPool,
        uint256 hTokenOut,
        uint256 maxUnderlyingIn
    ) public override {
        // Ensure that we are within the user's slippage tolerance.
        uint256 underlyingIn = hifiPool.getQuoteForBuyingHToken(hTokenOut);
        if (underlyingIn > maxUnderlyingIn) {
            revert HifiProxyTarget__TradeSlippage(maxUnderlyingIn, underlyingIn);
        }

        // Transfer the underlying to the DSProxy.
        IErc20 underlying = hifiPool.underlying();
        underlying.safeTransferFrom(msg.sender, address(this), underlyingIn);

        // Allow the HifiPool contract to spend underlying from the DSProxy.
        approveSpender(underlying, address(hifiPool), underlyingIn);

        // Buy the hTokens and relay them to the end user.
        hifiPool.buyHToken(msg.sender, hTokenOut);
    }

    
    function buyHTokenAndAddLiquidity(
        IHifiPool hifiPool,
        uint256 hTokenOut,
        uint256 maxUnderlyingAmount
    ) public override {
        // Transfer the underlying to the DSProxy.
        IErc20 underlying = hifiPool.underlying();
        uint256 underlyingIn = hifiPool.getQuoteForBuyingHToken(hTokenOut);
        underlying.safeTransferFrom(msg.sender, address(this), underlyingIn);

        // Allow the HifiPool contract to spend underlying from the DSProxy.
        approveSpender(underlying, address(hifiPool), underlyingIn);

        // Buy the hTokens.
        hifiPool.buyHToken(address(this), hTokenOut);

        // Calculate how much underlying is required to provide "hTokenOut" liquidity to the AMM.
        IHToken hToken = hifiPool.hToken();
        uint256 underlyingRequired = getUnderlyingRequired(hifiPool, hTokenOut);

        // Ensure that we are within the user's slippage tolerance.
        uint256 totalUnderlyingAmount = underlyingIn + underlyingRequired;
        if (totalUnderlyingAmount > maxUnderlyingAmount) {
            revert HifiProxyTarget__AddLiquidityUnderlyingSlippage(maxUnderlyingAmount, totalUnderlyingAmount);
        }

        // Transfer the underlying to the DSProxy.
        underlying.safeTransferFrom(msg.sender, address(this), underlyingRequired);

        // Allow the HifiPool contract to spend hTokens from the DSProxy.
        approveSpender(underlying, address(hifiPool), underlyingRequired);
        approveSpender(hToken, address(hifiPool), hTokenOut);

        // Add liquidity to the AMM.
        (uint256 hTokenRequired, ) = hifiPool.getMintInputs(underlyingRequired);
        uint256 poolTokensMinted = hifiPool.mint(underlyingRequired);

        // The LP tokens are now in the DSProxy, so we relay them to the end user.
        hifiPool.transfer(msg.sender, poolTokensMinted);

        // "hTokenOut" is greater or equal than "hTokenRequired", because not all of "hTokenOut" was used in the mint.
        // "normalizedUnderlyingRequired" was denormalized to "underlyingRequired", offsetting the trailing 12 digits.
        unchecked {
            uint256 hTokenDelta = hTokenOut - hTokenRequired;
            hToken.transfer(msg.sender, hTokenDelta);
        }
    }

    
    function buyHTokenAndRepayBorrow(
        IHifiPool hifiPool,
        IBalanceSheetV2 balanceSheet,
        uint256 maxUnderlyingIn,
        uint256 hTokenOut
    ) public override {
        // Ensure that we are within the user's slippage tolerance.
        uint256 underlyingIn = hifiPool.getQuoteForBuyingHToken(hTokenOut);
        if (underlyingIn > maxUnderlyingIn) {
            revert HifiProxyTarget__TradeSlippage(maxUnderlyingIn, underlyingIn);
        }

        // Transfer the underlying to the DSProxy.
        IErc20 underlying = hifiPool.underlying();
        underlying.safeTransferFrom(msg.sender, address(this), underlyingIn);

        // Allow the HifiPool contract to spend underlying from the DSProxy.
        approveSpender(underlying, address(hifiPool), underlyingIn);

        // Buy the hTokens.
        hifiPool.buyHToken(address(this), hTokenOut);

        // Query the amount of debt that the user owes.
        IHToken hToken = hifiPool.hToken();
        uint256 debtAmount = balanceSheet.getDebtAmount(address(this), hToken);

        // Use the recently bought hTokens to repay the borrow.
        if (debtAmount >= hTokenOut) {
            balanceSheet.repayBorrow(hToken, hTokenOut);
        } else {
            balanceSheet.repayBorrow(hToken, debtAmount);

            // Relay any remaining hTokens to the end user.
            unchecked {
                uint256 hTokenDelta = hTokenOut - debtAmount;
                hToken.transfer(msg.sender, hTokenDelta);
            }
        }
    }

    
    function buyHTokenAndAddLiquidityWithSignature(
        IHifiPool hifiPool,
        uint256 hTokenOut,
        uint256 maxUnderlyingAmount,
        uint256 deadline,
        bytes memory signatureUnderlying
    ) external override {
        permitInternal(
            IErc20Permit(address(hifiPool.underlying())),
            maxUnderlyingAmount,
            deadline,
            signatureUnderlying
        );
        buyHTokenAndAddLiquidity(hifiPool, hTokenOut, maxUnderlyingAmount);
    }

    
    function buyHTokenAndRepayBorrowWithSignature(
        IHifiPool hifiPool,
        IBalanceSheetV2 balanceSheet,
        uint256 maxUnderlyingIn,
        uint256 hTokenOut,
        uint256 deadline,
        bytes memory signatureUnderlying
    ) external override {
        permitInternal(IErc20Permit(address(hifiPool.underlying())), maxUnderlyingIn, deadline, signatureUnderlying);
        buyHTokenAndRepayBorrow(hifiPool, balanceSheet, maxUnderlyingIn, hTokenOut);
    }

    
    function buyHTokenWithSignature(
        IHifiPool hifiPool,
        uint256 hTokenOut,
        uint256 maxUnderlyingIn,
        uint256 deadline,
        bytes memory signatureUnderlying
    ) external override {
        permitInternal(IErc20Permit(address(hifiPool.underlying())), maxUnderlyingIn, deadline, signatureUnderlying);
        buyHToken(hifiPool, hTokenOut, maxUnderlyingIn);
    }

    
    function buyUnderlying(
        IHifiPool hifiPool,
        uint256 underlyingOut,
        uint256 maxHTokenIn
    ) public override {
        // Ensure that we are within the user's slippage tolerance.
        uint256 hTokenIn = hifiPool.getQuoteForBuyingUnderlying(underlyingOut);
        if (hTokenIn > maxHTokenIn) {
            revert HifiProxyTarget__TradeSlippage(maxHTokenIn, hTokenIn);
        }

        // Transfer the hTokens to the DSProxy.
        IErc20 hToken = hifiPool.hToken();
        hToken.transferFrom(msg.sender, address(this), hTokenIn);

        // Allow the HifiPool contract to spend underlying from the DSProxy.
        approveSpender(hToken, address(hifiPool), hTokenIn);

        // Buy the underlying and relay it to the end user.
        hifiPool.buyUnderlying(msg.sender, underlyingOut);
    }

    
    function buyUnderlyingAndAddLiquidity(
        IHifiPool hifiPool,
        uint256 maxHTokenAmount,
        uint256 underlyingOffered
    ) public override {
        // Ensure that we are within the user's slippage tolerance.
        uint256 hTokenIn = hifiPool.getQuoteForBuyingUnderlying(underlyingOffered);
        if (hTokenIn > maxHTokenAmount) {
            revert HifiProxyTarget__TradeSlippage(maxHTokenAmount, hTokenIn);
        }

        // Transfer the hTokens to the DSProxy.
        IHToken hToken = hifiPool.hToken();
        hToken.transferFrom(msg.sender, address(this), hTokenIn);

        // Allow the HifiPool contract to spend hTokens from the DSProxy.
        approveSpender(hToken, address(hifiPool), maxHTokenAmount);

        // Buy the underlying.
        hifiPool.buyUnderlying(address(this), underlyingOffered);

        // Ensure that we are within the user's slippage tolerance.
        (uint256 hTokenRequired, ) = hifiPool.getMintInputs(underlyingOffered);
        uint256 totalhTokenAmount = hTokenIn + hTokenRequired;
        if (totalhTokenAmount > maxHTokenAmount) {
            revert HifiProxyTarget__AddLiquidityHTokenSlippage(maxHTokenAmount, totalhTokenAmount);
        }

        // Transfer the hTokens to the DSProxy. We are calling the "transfer" function twice because we couldn't
        // have known what value "hTokenRequired" will have had after the call to "buyUnderlying".
        hToken.transferFrom(msg.sender, address(this), hTokenRequired);

        // Allow the HifiPool contract to spend underlying from the DSProxy.
        approveSpender(hifiPool.underlying(), address(hifiPool), underlyingOffered);

        // Add liquidity to the AMM.
        uint256 poolTokensMinted = hifiPool.mint(underlyingOffered);

        // The LP tokens are now in the DSProxy, so we relay them to the end user.
        hifiPool.transfer(msg.sender, poolTokensMinted);
    }

    
    function buyUnderlyingWithSignature(
        IHifiPool hifiPool,
        uint256 underlyingOut,
        uint256 maxHTokenIn,
        uint256 deadline,
        bytes memory signatureHToken
    ) external override {
        permitInternal(hifiPool.hToken(), maxHTokenIn, deadline, signatureHToken);
        buyUnderlying(hifiPool, underlyingOut, maxHTokenIn);
    }

    
    function buyUnderlyingAndAddLiquidityWithSignature(
        IHifiPool hifiPool,
        uint256 maxHTokenAmount,
        uint256 underlyingOffered,
        uint256 deadline,
        bytes memory signatureHToken
    ) external override {
        permitInternal(hifiPool.hToken(), maxHTokenAmount, deadline, signatureHToken);
        buyUnderlyingAndAddLiquidity(hifiPool, maxHTokenAmount, underlyingOffered);
    }

    
    function depositCollateral(
        IBalanceSheetV2 balanceSheet,
        IErc20 collateral,
        uint256 depositAmount
    ) public override {
        // Transfer the collateral to the DSProxy.
        collateral.safeTransferFrom(msg.sender, address(this), depositAmount);

        // Deposit the collateral into the BalanceSheet contract.
        depositCollateralInternal(balanceSheet, collateral, depositAmount);
    }

    
    function depositCollateralAndBorrowHToken(
        IBalanceSheetV2 balanceSheet,
        IErc20 collateral,
        IHToken hToken,
        uint256 depositAmount,
        uint256 borrowAmount
    ) public override {
        depositCollateral(balanceSheet, collateral, depositAmount);
        borrowHToken(balanceSheet, hToken, borrowAmount);
    }

    
    function depositCollateralAndBorrowHTokenAndAddLiquidity(
        IBalanceSheetV2 balanceSheet,
        IErc20 collateral,
        IHifiPool hifiPool,
        uint256 depositAmount,
        uint256 maxBorrowAmount,
        uint256 underlyingOffered
    ) public override {
        depositCollateral(balanceSheet, collateral, depositAmount);
        borrowHTokenAndAddLiquidity(balanceSheet, hifiPool, maxBorrowAmount, underlyingOffered);
    }

    
    function depositCollateralAndBorrowHTokenAndAddLiquidityWithSignature(
        IBalanceSheetV2 balanceSheet,
        IErc20Permit collateral,
        IHifiPool hifiPool,
        uint256 depositAmount,
        uint256 maxBorrowAmount,
        uint256 underlyingOffered,
        uint256 deadline,
        bytes memory signatureCollateral,
        bytes memory signatureUnderlying
    ) external override {
        permitInternal(collateral, depositAmount, deadline, signatureCollateral);
        permitInternal(IErc20Permit(address(hifiPool.underlying())), underlyingOffered, deadline, signatureUnderlying);
        depositCollateralAndBorrowHTokenAndAddLiquidity(
            balanceSheet,
            collateral,
            hifiPool,
            depositAmount,
            maxBorrowAmount,
            underlyingOffered
        );
    }

    
    function depositCollateralAndBorrowHTokenAndSellHToken(
        IBalanceSheetV2 balanceSheet,
        IErc20 collateral,
        IHifiPool hifiPool,
        uint256 depositAmount,
        uint256 borrowAmount,
        uint256 minUnderlyingOut
    ) public override {
        depositCollateral(balanceSheet, collateral, depositAmount);
        borrowHTokenAndSellHToken(balanceSheet, hifiPool, borrowAmount, minUnderlyingOut);
    }

    
    function depositCollateralAndBorrowHTokenAndSellHTokenWithSignature(
        IBalanceSheetV2 balanceSheet,
        IErc20Permit collateral,
        IHifiPool hifiPool,
        uint256 depositAmount,
        uint256 borrowAmount,
        uint256 minUnderlyingOut,
        uint256 deadline,
        bytes memory signatureCollateral
    ) external override {
        permitInternal(collateral, depositAmount, deadline, signatureCollateral);
        depositCollateralAndBorrowHTokenAndSellHToken(
            balanceSheet,
            collateral,
            hifiPool,
            depositAmount,
            borrowAmount,
            minUnderlyingOut
        );
    }

    
    function depositCollateralAndBorrowHTokenWithSignature(
        IBalanceSheetV2 balanceSheet,
        IErc20Permit collateral,
        IHToken hToken,
        uint256 depositAmount,
        uint256 borrowAmount,
        uint256 deadline,
        bytes memory signatureCollateral
    ) external override {
        permitInternal(collateral, depositAmount, deadline, signatureCollateral);
        depositCollateralAndBorrowHToken(balanceSheet, collateral, hToken, depositAmount, borrowAmount);
    }

    
    function depositCollateralWithSignature(
        IBalanceSheetV2 balanceSheet,
        IErc20Permit collateral,
        uint256 depositAmount,
        uint256 deadline,
        bytes memory signatureCollateral
    ) external override {
        permitInternal(collateral, depositAmount, deadline, signatureCollateral);
        depositCollateral(balanceSheet, collateral, depositAmount);
    }

    
    function depositUnderlyingAndMintHTokenAndAddLiquidity(
        IHifiPool hifiPool,
        uint256 depositAmount,
        uint256 underlyingOffered
    ) public override {
        // Calculate how many hTokens will be minted.
        uint256 hTokenMinted = normalize(depositAmount, hifiPool.underlyingPrecisionScalar());

        // Ensure that we are within the user's slippage tolerance.
        (uint256 hTokenRequired, ) = hifiPool.getMintInputs(underlyingOffered);
        if (hTokenRequired > hTokenMinted) {
            revert HifiProxyTarget__AddLiquidityHTokenSlippage(hTokenMinted, hTokenRequired);
        }

        // Transfer the underlying to the DSProxy.
        IErc20 underlying = hifiPool.underlying();
        uint256 totalUnderlyingAmount = depositAmount + underlyingOffered;
        underlying.safeTransferFrom(msg.sender, address(this), totalUnderlyingAmount);

        // Deposit the underlying in the HToken contract to mint hTokens.
        IHToken hToken = hifiPool.hToken();

        // Allow the HToken contract to spend underlying from the DSProxy.
        approveSpender(underlying, address(hToken), depositAmount);

        // Deposit the underlying in the HToken contract to mint hTokens.
        hToken.depositUnderlying(depositAmount);

        // Allow the HifiPool contract to spend underlying from the DSProxy.
        approveSpender(underlying, address(hifiPool), underlyingOffered);

        // Allow the HifiPool contract to spend hTokens from the DSProxy.
        approveSpender(hToken, address(hifiPool), hTokenRequired);

        // Add liquidity to pool.
        uint256 poolTokensMinted = hifiPool.mint(underlyingOffered);

        // The LP tokens are now in the DSProxy, so we relay them to the end user.
        hifiPool.transfer(msg.sender, poolTokensMinted);

        // Relay any remaining hTokens to the end user.
        if (hTokenMinted > hTokenRequired) {
            unchecked {
                uint256 hTokenDelta = hTokenMinted - hTokenRequired;
                hToken.transfer(msg.sender, hTokenDelta);
            }
        }
    }

    
    function depositUnderlyingAndMintHTokenAndAddLiquidityWithSignature(
        IHifiPool hifiPool,
        uint256 depositAmount,
        uint256 underlyingOffered,
        uint256 deadline,
        bytes memory signatureUnderlying
    ) external override {
        uint256 totalUnderlyingAmount = depositAmount + underlyingOffered;
        permitInternal(
            IErc20Permit(address(hifiPool.underlying())),
            totalUnderlyingAmount,
            deadline,
            signatureUnderlying
        );

        depositUnderlyingAndMintHTokenAndAddLiquidity(hifiPool, depositAmount, underlyingOffered);
    }

    
    function depositUnderlyingAndRepayBorrow(
        IHToken hToken,
        IBalanceSheetV2 balanceSheet,
        uint256 underlyingAmount
    ) public override {
        uint256 oldHTokenBalance = hToken.balanceOf(address(this));
        depositUnderlyingInternal(hToken, underlyingAmount);

        // Calculate how many hTokens were minted.
        uint256 newHTokenBalance = hToken.balanceOf(address(this));
        uint256 hTokenAmount;
        unchecked {
            hTokenAmount = newHTokenBalance - oldHTokenBalance;
        }

        // Query the amount of debt that the user owes.
        uint256 debtAmount = balanceSheet.getDebtAmount(address(this), hToken);

        // Use the recently minted hTokens to repay the borrow.
        if (debtAmount >= hTokenAmount) {
            balanceSheet.repayBorrow(hToken, hTokenAmount);
        } else {
            balanceSheet.repayBorrow(hToken, debtAmount);

            // Relay any remaining hTokens to the end user.
            unchecked {
                uint256 hTokenDelta = hTokenAmount - debtAmount;
                hToken.transfer(msg.sender, hTokenDelta);
            }
        }
    }

    
    function depositUnderlyingAndRepayBorrowWithSignature(
        IHToken hToken,
        IBalanceSheetV2 balanceSheet,
        uint256 underlyingAmount,
        uint256 deadline,
        bytes memory signatureUnderlying
    ) external override {
        permitInternal(IErc20Permit(address(hToken.underlying())), underlyingAmount, deadline, signatureUnderlying);
        depositUnderlyingAndRepayBorrow(hToken, balanceSheet, underlyingAmount);
    }

    
    function redeem(
        IHToken hToken,
        uint256 hTokenAmount,
        uint256 underlyingAmount
    ) public override {
        // Transfer the hTokens to the DSProxy.
        hToken.transferFrom(msg.sender, address(this), hTokenAmount);

        // Redeem the underlying.
        IErc20 underlying = hToken.underlying();
        hToken.redeem(underlyingAmount);

        // The underlying is now in the DSProxy, so we relay it to the end user.
        underlying.safeTransfer(msg.sender, underlyingAmount);
    }

    
    function redeemWithSignature(
        IHToken hToken,
        uint256 hTokenAmount,
        uint256 underlyingAmount,
        uint256 deadline,
        bytes memory signatureHToken
    ) external override {
        permitInternal(hToken, hTokenAmount, deadline, signatureHToken);
        redeem(hToken, hTokenAmount, underlyingAmount);
    }

    
    function removeLiquidity(IHifiPool hifiPool, uint256 poolTokensBurned) public override {
        // Transfer the LP tokens to the DSProxy.
        hifiPool.transferFrom(msg.sender, address(this), poolTokensBurned);

        // Burn the LP tokens.
        (uint256 underlyingReturned, uint256 hTokenReturned) = hifiPool.burn(poolTokensBurned);

        // The underlying and the hTokens are now in the DSProxy, so we relay them to the end user.
        hifiPool.underlying().safeTransfer(msg.sender, underlyingReturned);
        hifiPool.hToken().transfer(msg.sender, hTokenReturned);
    }

    
    function removeLiquidityAndRedeem(IHifiPool hifiPool, uint256 poolTokensBurned) public override {
        // Transfer the LP tokens to the DSProxy.
        hifiPool.transferFrom(msg.sender, address(this), poolTokensBurned);

        // Burn the LP tokens.
        (uint256 underlyingReturned, uint256 hTokenReturned) = hifiPool.burn(poolTokensBurned);

        // Calculate how much underlying will be redeemed.
        uint256 underlyingRedeemed = denormalize(hTokenReturned, hifiPool.underlyingPrecisionScalar());

        // Normalize the underlying amount to 18 decimals.
        uint256 hTokenAmount = normalize(underlyingRedeemed, hifiPool.underlyingPrecisionScalar());

        // Redeem the underlying.
        IHToken hToken = hifiPool.hToken();
        hToken.redeem(underlyingRedeemed);

        // Relay all the underlying it to the end user.
        uint256 totalUnderlyingAmount = underlyingReturned + underlyingRedeemed;
        hToken.underlying().safeTransfer(msg.sender, totalUnderlyingAmount);

        // Relay any remaining hTokens to the end user.
        if (hTokenReturned > hTokenAmount) {
            unchecked {
                uint256 hTokenDelta = hTokenReturned - hTokenAmount;
                hToken.transfer(msg.sender, hTokenDelta);
            }
        }
    }

    
    function removeLiquidityAndRedeemWithSignature(
        IHifiPool hifiPool,
        uint256 poolTokensBurned,
        uint256 deadline,
        bytes memory signatureLPToken
    ) external override {
        permitInternal(hifiPool, poolTokensBurned, deadline, signatureLPToken);
        removeLiquidityAndRedeem(hifiPool, poolTokensBurned);
    }

    
    function removeLiquidityAndSellHToken(
        IHifiPool hifiPool,
        uint256 poolTokensBurned,
        uint256 minUnderlyingOut
    ) public override {
        // Transfer the LP tokens to the DSProxy.
        hifiPool.transferFrom(msg.sender, address(this), poolTokensBurned);

        // Burn the LP tokens.
        (uint256 underlyingReturned, uint256 hTokenReturned) = hifiPool.burn(poolTokensBurned);

        // The underlying is now in the DSProxy, so we relay it to the end user.
        hifiPool.underlying().safeTransfer(msg.sender, underlyingReturned);

        // Ensure that we are within the user's slippage tolerance.
        uint256 underlyingOut = hifiPool.getQuoteForSellingHToken(hTokenReturned);
        if (underlyingOut < minUnderlyingOut) {
            revert HifiProxyTarget__TradeSlippage(minUnderlyingOut, underlyingOut);
        }

        // Allow the HifiPool contract to spend hTokens from the DSProxy.
        approveSpender(hifiPool.hToken(), address(hifiPool), hTokenReturned);

        // Sell the hTokens and relay the underlying to the end user.
        hifiPool.sellHToken(msg.sender, hTokenReturned);
    }

    
    function removeLiquidityAndSellHTokenWithSignature(
        IHifiPool hifiPool,
        uint256 poolTokensBurned,
        uint256 minUnderlyingOut,
        uint256 deadline,
        bytes memory signatureLPToken
    ) external override {
        permitInternal(hifiPool, poolTokensBurned, deadline, signatureLPToken);
        removeLiquidityAndSellHToken(hifiPool, poolTokensBurned, minUnderlyingOut);
    }

    
    function removeLiquidityAndWithdrawUnderlying(
        IHifiPool hifiPool,
        uint256 poolTokensBurned,
        uint256 withdrawAmount
    ) public override {
        // Transfer the LP tokens to the DSProxy.
        hifiPool.transferFrom(msg.sender, address(this), poolTokensBurned);

        // Burn the LP tokens.
        (uint256 underlyingReturned, uint256 hTokenReturned) = hifiPool.burn(poolTokensBurned);

        // Normalize the underlying amount to 18 decimals.
        uint256 hTokenAmount = normalize(withdrawAmount, hifiPool.underlyingPrecisionScalar());

        // Withdraw underlying in exchange for hTokens.
        IHToken hToken = hifiPool.hToken();
        hToken.withdrawUnderlying(withdrawAmount);

        // Relay any remaining hTokens to the end user.
        if (hTokenReturned > hTokenAmount) {
            unchecked {
                uint256 hTokenDelta = hTokenReturned - hTokenAmount;
                hToken.transfer(msg.sender, hTokenDelta);
            }
        }

        // Relay all the underlying it to the end user.
        uint256 totalUnderlyingAmount = underlyingReturned + withdrawAmount;
        hToken.underlying().safeTransfer(msg.sender, totalUnderlyingAmount);
    }

    
    function removeLiquidityAndWithdrawUnderlyingWithSignature(
        IHifiPool hifiPool,
        uint256 poolTokensBurned,
        uint256 withdrawAmount,
        uint256 deadline,
        bytes memory signatureLPToken
    ) public override {
        permitInternal(hifiPool, poolTokensBurned, deadline, signatureLPToken);
        removeLiquidityAndWithdrawUnderlying(hifiPool, poolTokensBurned, withdrawAmount);
    }

    
    function removeLiquidityWithSignature(
        IHifiPool hifiPool,
        uint256 poolTokensBurned,
        uint256 deadline,
        bytes memory signatureLPToken
    ) external override {
        permitInternal(hifiPool, poolTokensBurned, deadline, signatureLPToken);
        removeLiquidity(hifiPool, poolTokensBurned);
    }

    
    function repayBorrow(
        IBalanceSheetV2 balanceSheet,
        IHToken hToken,
        uint256 repayAmount
    ) public override {
        // Transfer the hTokens to the DSProxy.
        hToken.transferFrom(msg.sender, address(this), repayAmount);

        // Repay the borrow.
        balanceSheet.repayBorrow(hToken, repayAmount);
    }

    
    function repayBorrowWithSignature(
        IBalanceSheetV2 balanceSheet,
        IHToken hToken,
        uint256 repayAmount,
        uint256 deadline,
        bytes memory signatureHToken
    ) external override {
        permitInternal(hToken, repayAmount, deadline, signatureHToken);
        repayBorrow(balanceSheet, hToken, repayAmount);
    }

    
    function sellHToken(
        IHifiPool hifiPool,
        uint256 hTokenIn,
        uint256 minUnderlyingOut
    ) public override {
        // Ensure that we are within the user's slippage tolerance.
        uint256 underlyingOut = hifiPool.getQuoteForSellingHToken(hTokenIn);
        if (underlyingOut < minUnderlyingOut) {
            revert HifiProxyTarget__TradeSlippage(minUnderlyingOut, underlyingOut);
        }

        // Transfer the hTokens to the DSProxy.
        IHToken hToken = hifiPool.hToken();
        hToken.transferFrom(msg.sender, address(this), hTokenIn);

        // Allow the HifiPool contract to spend hTokens from the DSProxy.
        approveSpender(hToken, address(hifiPool), hTokenIn);

        // Sell the hTokens and relay the underlying to the end user.
        hifiPool.sellHToken(msg.sender, hTokenIn);
    }

    
    function sellHTokenWithSignature(
        IHifiPool hifiPool,
        uint256 hTokenIn,
        uint256 minUnderlyingOut,
        uint256 deadline,
        bytes memory signatureHToken
    ) external override {
        // Transfer the hTokens to the DSProxy.
        IHToken hToken = hifiPool.hToken();
        permitInternal(hToken, hTokenIn, deadline, signatureHToken);
        sellHToken(hifiPool, hTokenIn, minUnderlyingOut);
    }

    
    function sellUnderlying(
        IHifiPool hifiPool,
        uint256 underlyingIn,
        uint256 minHTokenOut
    ) public override {
        // Ensure that we are within the user's slippage tolerance.
        uint256 hTokenOut = hifiPool.getQuoteForSellingUnderlying(underlyingIn);
        if (hTokenOut < minHTokenOut) {
            revert HifiProxyTarget__TradeSlippage(minHTokenOut, hTokenOut);
        }

        // Transfer the underlying to the DSProxy.
        IErc20 underlying = hifiPool.underlying();
        underlying.safeTransferFrom(msg.sender, address(this), underlyingIn);

        // Allow the HifiPool contract to spend underlying from the DSProxy.
        approveSpender(underlying, address(hifiPool), underlyingIn);

        // Sell the underlying and relay the hTokens to the end user.
        hifiPool.sellUnderlying(msg.sender, underlyingIn);
    }

    
    function sellUnderlyingAndRepayBorrow(
        IHifiPool hifiPool,
        IBalanceSheetV2 balanceSheet,
        uint256 underlyingIn,
        uint256 minHTokenOut
    ) public override {
        // Ensure that we are within the user's slippage tolerance.
        uint256 hTokenOut = hifiPool.getQuoteForSellingUnderlying(underlyingIn);
        if (hTokenOut < minHTokenOut) {
            revert HifiProxyTarget__TradeSlippage(minHTokenOut, hTokenOut);
        }

        // Transfer the underlying to the DSProxy.
        IErc20 underlying = hifiPool.underlying();
        underlying.safeTransferFrom(msg.sender, address(this), underlyingIn);

        // Allow the HifiPool contract to spend underlying from the DSProxy.
        approveSpender(underlying, address(hifiPool), underlyingIn);

        // Sell the underlying.
        hifiPool.sellUnderlying(address(this), underlyingIn);

        // Query the amount of debt that the user owes.
        IHToken hToken = hifiPool.hToken();
        uint256 debtAmount = balanceSheet.getDebtAmount(address(this), hToken);

        // Repay the borrow.
        if (debtAmount >= hTokenOut) {
            balanceSheet.repayBorrow(hToken, hTokenOut);
        } else {
            balanceSheet.repayBorrow(hToken, debtAmount);

            // Relay any remaining hTokens to the end user.
            unchecked {
                uint256 hTokenDelta = hTokenOut - debtAmount;
                hToken.transfer(msg.sender, hTokenDelta);
            }
        }
    }

    
    function sellUnderlyingAndRepayBorrowWithSignature(
        IHifiPool hifiPool,
        IBalanceSheetV2 balanceSheet,
        uint256 underlyingIn,
        uint256 minHTokenOut,
        uint256 deadline,
        bytes memory signatureUnderlying
    ) external override {
        permitInternal(IErc20Permit(address(hifiPool.underlying())), underlyingIn, deadline, signatureUnderlying);
        sellUnderlyingAndRepayBorrow(hifiPool, balanceSheet, underlyingIn, minHTokenOut);
    }

    
    function sellUnderlyingWithSignature(
        IHifiPool hifiPool,
        uint256 underlyingIn,
        uint256 minHTokenOut,
        uint256 deadline,
        bytes memory signatureUnderlying
    ) external override {
        permitInternal(IErc20Permit(address(hifiPool.underlying())), underlyingIn, deadline, signatureUnderlying);
        sellUnderlying(hifiPool, underlyingIn, minHTokenOut);
    }

    
    function withdrawCollateral(
        IBalanceSheetV2 balanceSheet,
        IErc20 collateral,
        uint256 withdrawAmount
    ) external override {
        balanceSheet.withdrawCollateral(collateral, withdrawAmount);

        // The collateral is now in the DSProxy, so we relay it to the end user.
        collateral.safeTransfer(msg.sender, withdrawAmount);
    }

    
    function wrapEthAndDepositCollateral(WethInterface weth, IBalanceSheetV2 balanceSheet) public payable override {
        uint256 depositAmount = msg.value;

        // Convert the received ETH to WETH.
        weth.deposit{ value: depositAmount }();

        // Deposit the collateral into the BalanceSheet contract.
        depositCollateralInternal(balanceSheet, IErc20(address(weth)), depositAmount);
    }

    
    function wrapEthAndDepositAndBorrowHTokenAndSellHToken(
        WethInterface weth,
        IBalanceSheetV2 balanceSheet,
        IHifiPool hifiPool,
        uint256 borrowAmount,
        uint256 minUnderlyingOut
    ) external payable override {
        wrapEthAndDepositCollateral(weth, balanceSheet);
        borrowHTokenAndSellHToken(balanceSheet, hifiPool, borrowAmount, minUnderlyingOut);
    }

    /// INTERNAL CONSTANT FUNCTIONS ///

    
    
    
    
    function denormalize(uint256 amount, uint256 precisionScalar) internal pure returns (uint256 denormalizedAmount) {
        unchecked {
            denormalizedAmount = precisionScalar != 1 ? amount / precisionScalar : amount;
        }
    }

    
    
    
    
    function normalize(uint256 amount, uint256 precisionScalar) internal pure returns (uint256 normalizedAmount) {
        normalizedAmount = precisionScalar != 1 ? amount * precisionScalar : amount;
    }

    /// INTERNAL NON-CONSTANT FUNCTIONS ///

    
    function approveSpender(
        IErc20 token,
        address spender,
        uint256 amount
    ) internal {
        uint256 allowance = token.allowance(address(this), spender);
        if (allowance < amount) {
            token.approve(spender, type(uint256).max);
        }
    }

    
    function depositCollateralInternal(
        IBalanceSheetV2 balanceSheet,
        IErc20 collateral,
        uint256 collateralAmount
    ) internal {
        // Allow the BalanceSheet contract to spend collateral from the DSProxy.
        approveSpender(collateral, address(balanceSheet), collateralAmount);

        // Deposit the collateral into the BalanceSheet contract.
        balanceSheet.depositCollateral(collateral, collateralAmount);
    }

    
    function depositUnderlyingInternal(IHToken hToken, uint256 underlyingAmount) internal {
        IErc20 underlying = hToken.underlying();

        // Transfer the underlying to the DSProxy.
        underlying.safeTransferFrom(msg.sender, address(this), underlyingAmount);

        // Allow the HToken contract to spend underlying from the DSProxy.
        approveSpender(underlying, address(hToken), underlyingAmount);

        // Deposit the underlying in the HToken contract to mint hTokens.
        hToken.depositUnderlying(underlyingAmount);
    }

    
    function getUnderlyingRequired(IHifiPool hifiPool, uint256 hTokenOut)
        internal
        view
        returns (uint256 underlyingRequired)
    {
        // Calculate how much underlying is required to provide "hTokenOut" liquidity to the AMM.
        IHToken hToken = hifiPool.hToken();
        uint256 normalizedUnderlyingReserves = hifiPool.getNormalizedUnderlyingReserves();
        uint256 hTokenReserves = hToken.balanceOf(address(hifiPool));
        uint256 normalizedUnderlyingRequired = (normalizedUnderlyingReserves * hTokenOut) / hTokenReserves;
        underlyingRequired = denormalize(normalizedUnderlyingRequired, hifiPool.underlyingPrecisionScalar());
    }

    
    function permitInternal(
        IErc20Permit token,
        uint256 amount,
        uint256 deadline,
        bytes memory signature
    ) internal {
        if (signature.length > 0) {
            bytes32 r;
            bytes32 s;
            uint8 v;

            // solhint-disable-next-line no-inline-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            token.permit(msg.sender, address(this), amount, deadline, v, r, s);
        }
    }
}

// 
pragma solidity >=0.8.4;







interface IHifiPool is IErc20Permit {
    /// CUSTOM ERRORS ///

    
    error HifiPool__BondMatured();

    
    error HifiPool__BuyHTokenZero();

    
    error HifiPool__BuyHTokenUnderlyingZero();

    
    error HifiPool__BuyUnderlyingZero();

    
    error HifiPool__BurnZero();

    
    error HifiPool__MintZero();

    
    /// smaller than the underlying reserves.
    error HifiPool__NegativeInterestRate(
        uint256 virtualHTokenReserves,
        uint256 hTokenOut,
        uint256 normalizedUnderlyingReserves,
        uint256 normalizedUnderlyingIn
    );

    
    error HifiPool__SellHTokenZero();

    
    error HifiPool__SellHTokenUnderlyingZero();

    
    error HifiPool__SellUnderlyingZero();

    
    error HifiPool__ToInt256CastOverflow(uint256 number);

    
    error HifiPool__VirtualHTokenReservesOverflow(uint256 hTokenBalance, uint256 totalSupply);

    /// EVENTS ///

    
    
    
    
    
    
    event AddLiquidity(
        uint256 maturity,
        address indexed provider,
        uint256 underlyingAmount,
        uint256 hTokenAmount,
        uint256 poolTokenAmount
    );

    
    
    
    
    
    
    event RemoveLiquidity(
        uint256 maturity,
        address indexed provider,
        uint256 underlyingAmount,
        uint256 hTokenAmount,
        uint256 poolTokenAmount
    );

    
    
    
    
    
    
    event Trade(
        uint256 maturity,
        address indexed from,
        address indexed to,
        int256 underlyingAmount,
        int256 hTokenAmount
    );

    /// PUBLIC CONSTANT FUNCTIONS ///

    
    ///
    
    /// - Cannot be called after maturity.
    ///
    
    
    function getQuoteForBuyingHToken(uint256 hTokenOut) external view returns (uint256 underlyingIn);

    
    ///
    
    /// - Cannot be called after maturity.
    ///
    
    
    function getQuoteForBuyingUnderlying(uint256 underlyingOut) external view returns (uint256 hTokenIn);

    
    /// amount of underlying invested.
    
    
    
    function getMintInputs(uint256 underlyingOffered)
        external
        view
        returns (uint256 hTokenRequired, uint256 poolTokensMinted);

    
    
    
    
    function getBurnOutputs(uint256 poolTokensBurned)
        external
        view
        returns (uint256 underlyingReturned, uint256 hTokenReturned);

    
    ///
    
    /// - Cannot be called after maturity.
    ///
    
    
    function getQuoteForSellingHToken(uint256 hTokenIn) external view returns (uint256 underlyingOut);

    
    ///
    
    /// - Cannot be called after maturity.
    ///
    
    
    function getQuoteForSellingUnderlying(uint256 underlyingIn) external view returns (uint256 hTokenOut);

    
    function getNormalizedUnderlyingReserves() external view returns (uint256 normalizedUnderlyingReserves);

    
    
    function getVirtualHTokenReserves() external view returns (uint256 virtualHTokenReserves);

    
    function maturity() external view returns (uint256);

    
    function hToken() external view returns (IHToken);

    
    function underlying() external view returns (IErc20);

    
    function underlyingPrecisionScalar() external view returns (uint256);

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    ///
    
    ///
    /// Requirements:
    /// - The amount to burn cannot be zero.
    ///
    
    
    
    function burn(uint256 poolTokensBurned) external returns (uint256 underlyingReturned, uint256 hTokenReturned);

    
    ///
    
    ///
    /// Requirements:
    /// - All from "getQuoteForBuyingHToken".
    /// - The caller must have allowed this contract to spend `underlyingIn` tokens.
    /// - The caller must have at least `underlyingIn` in their account.
    ///
    
    
    
    function buyHToken(address to, uint256 hTokenOut) external returns (uint256 underlyingIn);

    
    ///
    /// Requirements:
    /// - All from "getQuoteForBuyingUnderlying".
    /// - The caller must have allowed this contract to spend `hTokenIn` tokens.
    /// - The caller must have at least `hTokenIn` in their account.
    ///
    
    
    
    function buyUnderlying(address to, uint256 underlyingOut) external returns (uint256 hTokenIn);

    
    /// hTokens gets calculated and taken from the caller to be investigated alongside underlying tokens.
    ///
    
    ///
    /// Requirements:
    /// - The caller must have allowed this contract to spend `underlyingOffered` and `hTokenRequired` tokens.
    ///
    
    
    function mint(uint256 underlyingOffered) external returns (uint256 poolTokensMinted);

    
    ///
    
    ///
    /// Requirements:
    /// - All from "getQuoteForSellingHToken".
    /// - The caller must have allowed this contract to spend `hTokenIn` tokens.
    /// - The caller must have at least `hTokenIn` in their account.
    ///
    
    
    
    function sellHToken(address to, uint256 hTokenIn) external returns (uint256 underlyingOut);

    
    ///
    
    ///
    /// Requirements:
    /// - All from "getQuoteForSellingUnderlying".
    /// - The caller must have allowed this contract to spend `underlyingIn` tokens.
    /// - The caller must have at least `underlyingIn` in their account.
    ///
    
    
    
    function sellUnderlying(address to, uint256 underlyingIn) external returns (uint256 hTokenOut);
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



interface WethInterface {
    function deposit() external payable;

    function withdraw(uint256) external;
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