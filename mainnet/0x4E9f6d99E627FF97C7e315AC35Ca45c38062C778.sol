// SPDX-License-Identifier: GPL-3.0-or-later


interface IEventRelayer {
    enum EventType {BorrowedUSDCType, RepaidDebtEarlyType, RepaidDebtMatureType}
    function relay(EventType eventType, address user) external;
}

// 
pragma solidity ^0.6.10;




contract DecimalMath {
    using SafeMath for uint256;

    uint256 constant public UNIT = 1e27;

    
    function muld(uint256 x, uint256 y) internal pure returns (uint256) {
        return x.mul(y).div(UNIT);
    }

    
    function divd(uint256 x, uint256 y) internal pure returns (uint256) {
        return x.mul(UNIT).div(y);
    }

    
    /// Assumes x and y are both fixed point with `decimals` digits.
    function muldrup(uint256 x, uint256 y) internal pure returns (uint256)
    {
        uint256 z = x.mul(y);
        return z.mod(UNIT) == 0 ? z.div(UNIT) : z.div(UNIT).add(1);
    }

    
    /// Assumes x and y are both fixed point with `decimals` digits.
    function divdrup(uint256 x, uint256 y) internal pure returns (uint256)
    {
        uint256 z = x.mul(UNIT);
        return z.mod(y) == 0 ? z.div(y) : z.div(y).add(1);
    }
}

// 
// Code adapted from https://github.com/OpenZeppelin/openzeppelin-contracts/pull/2237/
pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC2612 standard as defined in the EIP.
 *
 * Adds the {permit} method, which can be used to change one's
 * {IERC20-allowance} without having to send a transaction, by signing a
 * message. This allows users to spend tokens without having to hold Ether.
 *
 * See https://eips.ethereum.org/EIPS/eip-2612.
 */
interface IERC2612 {
    /**
     * @dev Sets `amount` as the allowance of `spender` over `owner`'s tokens,
     * given `owner`'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(address owner, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    /**
     * @dev Returns the current ERC2612 nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);
}

// 
pragma solidity ^0.6.10;


interface IDelegable {
    function addDelegate(address) external;
    function addDelegateBySignature(address, address, uint, uint8, bytes32, bytes32) external;
    function delegated(address, address) external view returns (bool);
}

// 

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}
// 
pragma solidity ^0.6.10;

 // TODO: Bring into @yield-protocol/utils
 // TODO: Make into library












library RoundingMath {
    function divrup(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require (y > 0, "USDCProxy: Division by zero");
        return x % y == 0 ? x / y : x / y + 1;
    }
}

contract USDCProxy is IEventRelayer, DecimalMath {
    using SafeCast for uint256;
    using SafeMath for uint256;
    using RoundingMath for uint256;
    using YieldAuth for DaiAbstract;
    using YieldAuth for IFYDai;
    using YieldAuth for IUSDC;
    using YieldAuth for IController;
    using YieldAuth for IPool;

    event BorrowedUSDC(address indexed user);
    event RepaidDebtEarly(address indexed user);
    event RepaidDebtMature(address indexed user);

    DaiAbstract public immutable dai;
    IUSDC public immutable usdc;
    IController public immutable controller;
    DssPsmAbstract public immutable psm;
    IEventRelayer public immutable usdcProxy;

    address public immutable treasury;

    bytes32 public constant WETH = "ETH-A";

    constructor(IController _controller, DssPsmAbstract psm_) public {
        ITreasury _treasury = _controller.treasury();
        dai = _treasury.dai();
        treasury = address(_treasury);
        controller = _controller;
        psm = psm_;
        usdc = IUSDC(AuthGemJoinAbstract(psm_.gemJoin()).gem());
        usdcProxy = IEventRelayer(address(this)); // This contract has two functions, as itself, and delegatecalled by a dsproxy.
    }

    
    function relay(EventType eventType, address user) public override {
        if (eventType == EventType.BorrowedUSDCType) emit BorrowedUSDC(user);
        if (eventType == EventType.RepaidDebtEarlyType) emit RepaidDebtEarly(user);
        if (eventType == EventType.RepaidDebtMatureType) emit RepaidDebtMature(user);
    }

    
    /// Must have approved the operator with `controller.addDelegate(borrowProxy.address)` or with `borrowDaiForMaximumFYDaiWithSignature`.
    /// Caller must have called `borrowDaiForMaximumFYDaiWithSignature` at least once before to set proxy approvals.
    
    
    
    
    
    function borrowUSDCForMaximumFYDai(
        IPool pool,
        bytes32 collateral,
        uint256 maturity,
        address to,
        uint256 usdcToBorrow,
        uint256 maximumFYDai
    )
        public
        returns (uint256)
    {
        pool.fyDai().approve(address(pool), type(uint256).max); // TODO: Move to right place
        
        uint256 usdcToBorrow18 = usdcToBorrow.mul(1e12); // USDC has 6 decimals
        uint256 fee = usdcToBorrow18.mul(psm.tout()) / 1e18; // tout has 18 decimals
        uint256 daiToBuy = usdcToBorrow18.add(fee);

        uint256 fyDaiToBorrow = pool.buyDaiPreview(daiToBuy.toUint128()); // If not calculated on-chain, there will be fyDai left as slippage
        require (fyDaiToBorrow <= maximumFYDai, "USDCProxy: Too much fyDai required");

        // The collateral for this borrow needs to have been posted beforehand
        controller.borrow(collateral, maturity, msg.sender, address(this), fyDaiToBorrow);
        pool.buyDai(address(this), address(this), daiToBuy.toUint128());
        psm.buyGem(to, usdcToBorrow); // PSM takes USDC amounts with 6 decimals

        usdcProxy.relay(EventType.BorrowedUSDCType, msg.sender);

        return fyDaiToBorrow;
    }

    
    /// Must have approved the operator with `controller.addDelegate(borrowProxy.address)` or with `repayMinimumFYDaiDebtForDaiWithSignature`.
    /// Must have approved the operator with `pool.addDelegate(borrowProxy.address)` or with `repayMinimumFYDaiDebtForDaiWithSignature`.
    /// If `repaymentInUSDC` exceeds the existing debt, the surplus will be locked in the proxy.
    
    
    
    
    
    function repayDebtEarly(
        IPool pool,
        bytes32 collateral,
        uint256 maturity,
        address to,
        uint256 usdcRepayment,
        uint256 minFYDaiRepayment
    )
        public
        returns (uint256)
    {
        uint256 usdcRepayment18 = usdcRepayment.mul(1e12); // USDC has 6 decimals
        uint256 fee = usdcRepayment18.mul(psm.tin()) / 1e18; // Fees in PSM are fixed point in WAD
        uint256 daiObtained = usdcRepayment18.sub(fee); // If not right, the `sellDai` might revert.

        usdc.transferFrom(msg.sender, address(this), usdcRepayment);
        psm.sellGem(address(this), usdcRepayment); // PSM takes USDC amounts with 6 decimals
        uint256 fyDaiRepayment =  pool.sellDai(address(this), address(this), daiObtained.toUint128());
        require(fyDaiRepayment >= minFYDaiRepayment, "USDCProxy: Not enough debt repaid");
        controller.repayFYDai(collateral, maturity, address(this), to, fyDaiRepayment);

        usdcProxy.relay(EventType.RepaidDebtEarlyType, msg.sender);

        return daiObtained;
    }

    
    /// Must have approved the operator with `controller.addDelegate(borrowProxy.address)` or with `repayAllWithFYDaiWithSignature`.
    /// Must have approved the operator with `pool.addDelegate(borrowProxy.address)` or with `repayAllWithFYDaiWithSignature`.
    
    
    
    
    function repayAllEarly(
        IPool pool,
        bytes32 collateral,
        uint256 maturity,
        address to,
        uint256 maxUSDCIn
    )
        public
        returns (uint256)
    {
        uint256 fyDaiDebt = controller.debtFYDai(collateral, maturity, to);
        uint256 daiIn = pool.buyFYDaiPreview(fyDaiDebt.toUint128());
        uint256 usdcIn18 = (daiIn * 1e18).divrup(1e18 + psm.tin()); // Fixed point division with 18 decimals - We are working an usdc value from a dai one, so we round up.
        uint256 usdcIn = usdcIn18.divrup(1e12); // We are working an usdc value from a dai one, so we round up.

        require (usdcIn <= maxUSDCIn, "USDCProxy: Too much USDC required");
        usdc.transferFrom(msg.sender, address(this), usdcIn);
        psm.sellGem(address(this), usdcIn);
        pool.buyFYDai(address(this), address(this), fyDaiDebt.toUint128());
        controller.repayFYDai(collateral, maturity, address(this), to, fyDaiDebt);

        usdcProxy.relay(EventType.RepaidDebtEarlyType, msg.sender);

        return usdcIn;
    }

    
    /// Must have approved the operator with `controller.addDelegate(borrowProxy.address)` or with `repayAllWithFYDaiWithSignature`.
    /// Must have approved the operator with `pool.addDelegate(borrowProxy.address)` or with `repayAllWithFYDaiWithSignature`.
    
    
    
    
    
    function repayDebtMature(
        bytes32 collateral,
        uint256 maturity,
        address to,
        uint256 daiRepayment
    )
        public
        returns (uint256)
    {
        return _repayDebtMature(
            collateral,
            maturity,
            to,
            daiRepayment
        );
    }

    
    /// Must have approved the operator with `controller.addDelegate(borrowProxy.address)` or with `repayAllWithFYDaiWithSignature`.
    /// Must have approved the operator with `pool.addDelegate(borrowProxy.address)` or with `repayAllWithFYDaiWithSignature`.
    
    
    
    
    function repayAllMature(
        bytes32 collateral,
        uint256 maturity,
        address to
    )
        public
        returns (uint256)
    {
        return _repayDebtMature(
            collateral,
            maturity,
            to,
            controller.debtDai(collateral, maturity, msg.sender)
        );
    }

    
    /// Must have approved the operator with `controller.addDelegate(borrowProxy.address)` or with `repayAllWithFYDaiWithSignature`.
    /// Must have approved the operator with `pool.addDelegate(borrowProxy.address)` or with `repayAllWithFYDaiWithSignature`.
    
    
    
    
    function _repayDebtMature(
        bytes32 collateral,
        uint256 maturity,
        address to,
        uint256 daiRepayment
    )
        internal
        returns (uint256)
    {
        uint256 usdcRepayment18 = (daiRepayment * 1e18).divrup(1e18 - psm.tin());
        uint256 usdcRepayment = usdcRepayment18.divrup(1e12);
        usdc.transferFrom(msg.sender, address(this), usdcRepayment);
        psm.sellGem(address(this), usdcRepayment);
        controller.repayDai(collateral, maturity, address(this), to, daiRepayment);

        usdcProxy.relay(EventType.RepaidDebtMatureType, msg.sender);

        return usdcRepayment;
    }

    /// --------------------------------------------------
    /// Signature method wrappers
    /// --------------------------------------------------

    
    function borrowUSDCForMaximumFYDaiApprove(IPool pool) public {
        // allow the pool to pull FYDai/dai from us for trading
        if (pool.fyDai().allowance(address(this), address(pool)) < type(uint112).max)
            pool.fyDai().approve(address(pool), type(uint256).max);
        
        if (dai.allowance(address(this), address(psm)) < type(uint256).max)
            dai.approve(address(psm), type(uint256).max); // Approve to provide Dai to the PSM
    }

    
    /// Must have approved the operator with `controller.addDelegate(borrowProxy.address)` or with `borrowDaiForMaximumFYDaiWithSignature`.
    /// Caller must have called `borrowDaiForMaximumFYDaiWithSignature` at least once before to set proxy approvals.
    
    
    
    
    
    
    function borrowUSDCForMaximumFYDaiWithSignature(
        IPool pool,
        bytes32 collateral,
        uint256 maturity,
        address to,
        uint256 usdcToBorrow,
        uint256 maximumFYDai,
        
        bytes memory controllerSig
    )
        public
        returns (uint256)
    {
        borrowUSDCForMaximumFYDaiApprove(pool);
        if (controllerSig.length > 0) controller.addDelegatePacked(controllerSig);
        return borrowUSDCForMaximumFYDai(pool, collateral, maturity, to, usdcToBorrow, maximumFYDai);
    }

    
    function repayDebtEarlyApprove(IPool pool) public {
        // Send the USDC to the PSM
        if (usdc.allowance(address(this), address(psm.gemJoin())) < type(uint112).max) // USDC reduces allowances when set to MAX
            usdc.approve(address(psm.gemJoin()), type(uint256).max);
        
        // Send the Dai to the Pool
        if (dai.allowance(address(this), address(pool)) < type(uint256).max)
            dai.approve(address(pool), type(uint256).max);

        // Send the fyDai to the Treasury
        if (pool.fyDai().allowance(address(this), treasury) < type(uint112).max)
            pool.fyDai().approve(treasury, type(uint256).max);
    }

    
    /// If `repaymentInDai` exceeds the existing debt, only the necessary Dai will be used.
    
    
    
    
    
    
    
    function repayDebtEarlyWithSignature(
        IPool pool,
        bytes32 collateral,
        uint256 maturity,
        address to,
        uint256 repaymentInUSDC,
        uint256 fyDaiDebt, // Calculate off-chain, works as slippage protection
        bytes memory usdcSig,
        bytes memory controllerSig
    )
        public
        returns (uint256)
    {
        repayDebtEarlyApprove(pool);
        if (usdcSig.length > 0) usdc.permitPacked(address(this), usdcSig);
        if (controllerSig.length > 0) controller.addDelegatePacked(controllerSig);
        return repayDebtEarly(pool, collateral, maturity, to, repaymentInUSDC, fyDaiDebt);
    }

    
    
    
    
    
    
    
    function repayAllEarlyWithSignature(
        IPool pool,
        bytes32 collateral,
        uint256 maturity,
        address to,
        uint256 maxUSDCIn,
        bytes memory usdcSig,
        bytes memory controllerSig
    )
        public
        returns (uint256)
    {
        repayDebtEarlyApprove(pool); // Same permissions
        if (usdcSig.length > 0) usdc.permitPacked(address(this), usdcSig);
        if (controllerSig.length > 0) controller.addDelegatePacked(controllerSig);
        return repayAllEarly(pool, collateral, maturity, to, maxUSDCIn);
    }

    
    function repayDebtMatureApprove() public {
        // Send the USDC to the PSM
        if (usdc.allowance(address(this), address(psm.gemJoin())) < type(uint112).max) // USDC reduces allowances when set to MAX
            usdc.approve(address(psm.gemJoin()), type(uint256).max);
        
        // Send the Dai to the Treasury
        if (dai.allowance(address(this), address(treasury)) < type(uint256).max)
            dai.approve(address(treasury), type(uint256).max);
    }

    
    /// If the amount of Dai obtained by selling USDC exceeds the existing debt, the surplus will be locked in the proxy.
    
    
    
    
    
    
    function repayDebtMatureWithSignature(
        bytes32 collateral,
        uint256 maturity,
        address to,
        uint256 repaymentInUSDC,
        bytes memory usdcSig,
        bytes memory controllerSig
    )
        public
        returns (uint256)
    {
        repayDebtMatureApprove();
        if (usdcSig.length > 0) usdc.permitPacked(address(this), usdcSig);
        if (controllerSig.length > 0) controller.addDelegatePacked(controllerSig);
        return repayDebtMature(collateral, maturity, to, repaymentInUSDC);
    }

    
    
    
    
    
    
    function repayAllMatureWithSignature(
        bytes32 collateral,
        uint256 maturity,
        address to,
        bytes memory usdcSig,
        bytes memory controllerSig
    )
        public
        returns (uint256)
    {
        repayDebtMatureApprove(); // Same permissions
        if (usdcSig.length > 0) usdc.permitPacked(address(this), usdcSig);
        if (controllerSig.length > 0) controller.addDelegatePacked(controllerSig);
        return repayAllMature(collateral, maturity, to);
    }

    /// --------------------------------------------------
    /// Convenience functions
    /// --------------------------------------------------

    
    function tin() public view returns (uint256) {
        return psm.tin();
    }

    
    function tout() public view returns (uint256) {
        return psm.tout();
    }
}

// 

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// 
pragma solidity ^0.6.10;


library SafeCast {
    
    function toUint128(uint256 x) internal pure returns(uint128) {
        require(
            x <= type(uint128).max,
            "SafeCast: Cast overflow"
        );
        return uint128(x);
    }

    
    function toInt256(uint256 x) internal pure returns(int256) {
        require(
            x <= uint256(type(int256).max),
            "SafeCast: Cast overflow"
        );
        return int256(x);
    }
}

// 
pragma solidity ^0.6.10;






library YieldAuth {

    
    
    function unpack(bytes memory signature) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }
    }

    
    
    
    function addDelegatePacked(IDelegable target, bytes memory signature) internal {
        bytes32 r;
        bytes32 s;
        uint8 v;

        (r, s, v) = unpack(signature);
        target.addDelegateBySignature(msg.sender, address(this), type(uint256).max, v, r, s);
    }

    
    
    
    
    
    function addDelegatePacked(IDelegable target, address user, address delegate, bytes memory signature) internal {
        bytes32 r;
        bytes32 s;
        uint8 v;

        (r, s, v) = unpack(signature);
        target.addDelegateBySignature(user, delegate, type(uint256).max, v, r, s);
    }

    
    
    
    
    function permitPackedDai(DaiAbstract dai, address spender, bytes memory signature) internal {
        bytes32 r;
        bytes32 s;
        uint8 v;

        (r, s, v) = unpack(signature);
        dai.permit(msg.sender, spender, dai.nonces(msg.sender), type(uint256).max, true, v, r, s);
    }

    
    
    
    
    function permitPacked(IERC2612 token, address spender, bytes memory signature) internal {
        bytes32 r;
        bytes32 s;
        uint8 v;

        (r, s, v) = unpack(signature);
        token.permit(msg.sender, spender, type(uint256).max, type(uint256).max, v, r, s);
    }
}

// 
pragma solidity ^0.6.10;




interface IFYDai is IERC20, IERC2612 {
    function isMature() external view returns(bool);
    function maturity() external view returns(uint);
    function chi0() external view returns(uint);
    function rate0() external view returns(uint);
    function chiGrowth() external view returns(uint);
    function rateGrowth() external view returns(uint);
    function mature() external;
    function unlocked() external view returns (uint);
    function mint(address, uint) external;
    function burn(address, uint) external;
    function flashMint(uint, bytes calldata) external;
    function redeem(address, address, uint256) external returns (uint256);
    // function transfer(address, uint) external returns (bool);
    // function transferFrom(address, address, uint) external returns (bool);
    // function approve(address, uint) external returns (bool);
}

// 
pragma solidity ^0.6.10;









interface ITreasury {
    function debt() external view returns(uint256);
    function savings() external view returns(uint256);
    function pushDai(address user, uint256 dai) external;
    function pullDai(address user, uint256 dai) external;
    function pushChai(address user, uint256 chai) external;
    function pullChai(address user, uint256 chai) external;
    function pushWeth(address to, uint256 weth) external;
    function pullWeth(address to, uint256 weth) external;
    function shutdown() external;
    function live() external view returns(bool);

    function vat() external view returns (VatAbstract);
    function weth() external view returns (IWeth);
    function dai() external view returns (DaiAbstract);
    function daiJoin() external view returns (DaiJoinAbstract);
    function wethJoin() external view returns (GemJoinAbstract);
    function pot() external view returns (PotAbstract);
    function chai() external view returns (IChai);
}

// 
pragma solidity ^0.6.10;






interface IController is IDelegable {
    function treasury() external view returns (ITreasury);
    function series(uint256) external view returns (IFYDai);
    function seriesIterator(uint256) external view returns (uint256);
    function totalSeries() external view returns (uint256);
    function containsSeries(uint256) external view returns (bool);
    function posted(bytes32, address) external view returns (uint256);
    function locked(bytes32, address) external view returns (uint256);
    function debtFYDai(bytes32, uint256, address) external view returns (uint256);
    function debtDai(bytes32, uint256, address) external view returns (uint256);
    function totalDebtDai(bytes32, address) external view returns (uint256);
    function isCollateralized(bytes32, address) external view returns (bool);
    function inDai(bytes32, uint256, uint256) external view returns (uint256);
    function inFYDai(bytes32, uint256, uint256) external view returns (uint256);
    function erase(bytes32, address) external returns (uint256, uint256);
    function shutdown() external;
    function post(bytes32, address, address, uint256) external;
    function withdraw(bytes32, address, address, uint256) external;
    function borrow(bytes32, uint256, address, address, uint256) external;
    function repayFYDai(bytes32, uint256, address, address, uint256) external returns (uint256);
    function repayDai(bytes32, uint256, address, address, uint256) external returns (uint256);
}

// 
pragma solidity ^0.6.10;







interface IPool is IDelegable, IERC20, IERC2612 {
    function dai() external view returns(IERC20);
    function fyDai() external view returns(IFYDai);
    function getDaiReserves() external view returns(uint128);
    function getFYDaiReserves() external view returns(uint128);
    function sellDai(address from, address to, uint128 daiIn) external returns(uint128);
    function buyDai(address from, address to, uint128 daiOut) external returns(uint128);
    function sellFYDai(address from, address to, uint128 fyDaiIn) external returns(uint128);
    function buyFYDai(address from, address to, uint128 fyDaiOut) external returns(uint128);
    function sellDaiPreview(uint128 daiIn) external view returns(uint128);
    function buyDaiPreview(uint128 daiOut) external view returns(uint128);
    function sellFYDaiPreview(uint128 fyDaiIn) external view returns(uint128);
    function buyFYDaiPreview(uint128 fyDaiOut) external view returns(uint128);
    function mint(address from, address to, uint256 daiOffered) external returns (uint256);
    function burn(address from, address to, uint256 tokensBurned) external returns (uint256, uint256);
}

// 
pragma solidity >=0.5.12;

// https://github.com/makerdao/dss-deploy/blob/master/src/join.sol
interface AuthGemJoinAbstract {
    function vat() external view returns (address);
    function ilk() external view returns (bytes32);
    function gem() external view returns (address);
    function dec() external view returns (uint256);
    function live() external view returns (uint256);
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function cage() external;
    function join(address, uint256) external;
    function exit(address, uint256) external;
}

// 
pragma solidity >=0.5.12;

// https://github.com/makerdao/dss/blob/master/src/dai.sol
interface DaiAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function version() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);
    function nonces(address) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external view returns (bytes32);
    function transfer(address, uint256) external;
    function transferFrom(address, address, uint256) external returns (bool);
    function mint(address, uint256) external;
    function burn(address, uint256) external;
    function approve(address, uint256) external returns (bool);
    function push(address, uint256) external;
    function pull(address, uint256) external;
    function move(address, address, uint256) external;
    function permit(address, address, uint256, uint256, bool, uint8, bytes32, bytes32) external;
}

// 
pragma solidity ^0.6.10;




interface IUSDC is IERC20, IERC2612 { 
    function PERMIT_TYPEHASH() external view returns(bytes32);
    function DOMAIN_SEPARATOR() external view returns(bytes32);
}

// 
pragma solidity ^0.6.10;




interface DssPsmAbstract {
    function gemJoin() external view returns(AuthGemJoinAbstract);
    function daiJoin() external view returns(DaiJoinAbstract);
    function tin() external view returns(uint256);
    function tout() external view returns(uint256);
    function file(bytes32 what, uint256 data) external;
    function sellGem(address usr, uint256 gemAmt) external;
    function buyGem(address usr, uint256 gemAmt) external;
}

// 
pragma solidity ^0.6.10;



interface IWeth is IERC20 {
    function deposit() external payable;
    function withdraw(uint) external;
}

// 
pragma solidity >=0.5.12;

// https://github.com/makerdao/dss/blob/master/src/vat.sol
interface VatAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function can(address, address) external view returns (uint256);
    function hope(address) external;
    function nope(address) external;
    function ilks(bytes32) external view returns (uint256, uint256, uint256, uint256, uint256);
    function urns(bytes32, address) external view returns (uint256, uint256);
    function gem(bytes32, address) external view returns (uint256);
    function dai(address) external view returns (uint256);
    function sin(address) external view returns (uint256);
    function debt() external view returns (uint256);
    function vice() external view returns (uint256);
    function Line() external view returns (uint256);
    function live() external view returns (uint256);
    function init(bytes32) external;
    function file(bytes32, uint256) external;
    function file(bytes32, bytes32, uint256) external;
    function cage() external;
    function slip(bytes32, address, int256) external;
    function flux(bytes32, address, address, uint256) external;
    function move(address, address, uint256) external;
    function frob(bytes32, address, address, address, int256, int256) external;
    function fork(bytes32, address, address, int256, int256) external;
    function grab(bytes32, address, address, address, int256, int256) external;
    function heal(uint256) external;
    function suck(address, address, uint256) external;
    function fold(bytes32, address, int256) external;
}

// 
pragma solidity >=0.5.12;

// https://github.com/makerdao/dss/blob/master/src/join.sol
interface GemJoinAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function vat() external view returns (address);
    function ilk() external view returns (bytes32);
    function gem() external view returns (address);
    function dec() external view returns (uint256);
    function live() external view returns (uint256);
    function cage() external;
    function join(address, uint256) external;
    function exit(address, uint256) external;
}

// 
pragma solidity >=0.5.12;

// https://github.com/makerdao/dss/blob/master/src/join.sol
interface DaiJoinAbstract {
    function wards(address) external view returns (uint256);
    function rely(address usr) external;
    function deny(address usr) external;
    function vat() external view returns (address);
    function dai() external view returns (address);
    function live() external view returns (uint256);
    function cage() external;
    function join(address, uint256) external;
    function exit(address, uint256) external;
}

// 
pragma solidity >=0.5.12;

// https://github.com/makerdao/dss/blob/master/src/pot.sol
interface PotAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function pie(address) external view returns (uint256);
    function Pie() external view returns (uint256);
    function dsr() external view returns (uint256);
    function chi() external view returns (uint256);
    function vat() external view returns (address);
    function vow() external view returns (address);
    function rho() external view returns (uint256);
    function live() external view returns (uint256);
    function file(bytes32, uint256) external;
    function file(bytes32, address) external;
    function cage() external;
    function drip() external returns (uint256);
    function join(uint256) external;
    function exit(uint256) external;
}

// 
pragma solidity ^0.6.10;




/// Taken from https://github.com/makerdao/developerguides/blob/master/dai/dsr-integration-guide/dsr.sol
interface IChai is IERC20, IERC2612 {
    function move(address src, address dst, uint wad) external returns (bool);
    function dai(address usr) external returns (uint wad);
    function join(address dst, uint wad) external;
    function exit(address src, uint wad) external;
    function draw(address src, uint wad) external;
}