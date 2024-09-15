// SPDX-License-Identifier: MIT
pragma abicoder v2;

// 
pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// 
pragma solidity ^0.7.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

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
pragma solidity >=0.5.0;



interface IVaultEventsV3 {

    
    
    
    
    
    
    event Deposit(
        address indexed user,
        uint256 share0,
        uint256 share1,
        uint256 amount0,
        uint256 amount1
    );

    
    
    
    
    
    
    event Withdraw(
        address indexed user,
        uint256 share0,
        uint256 share1,
        uint256 amount0,
        uint256 amount1
    );

    
    
    
    event CollectFees(
        uint256 feesFromPool0,
        uint256 feesFromPool1
    );

    
    
    
    event UpdateWhiteList(
        address indexed _address,
        bool status
    );

    
    
    event ChangeManger(
        address indexed _operator
    );

}

// 
pragma solidity >=0.5.0;



interface IVaultOperatorActionsV3 {

    function initPosition(address, int24, int24) external;

    
    
    function addPool(uint24 _poolFee) external;

    
    
    
    
    
    function changeConfig(
        address _swapPool,
        uint8 _performanceFee,
        uint24 _diffTick,
        uint32 _safetyParam
    ) external;

    
    
    
    
    
    function changeMaxShare(
        uint256 _maxShare0,
        uint256 _maxShare1,
        uint256 _maxPersonShare0,
        uint256 _maxPersonShare1
    ) external;

    
    
    function avoidRisk(uint8 _profitScale) external;

//    
//    
//    function reInvest() external;

    
    
    
    
    
    
    function changePool(
        address newPoolAddress,
        int24 _lowerTick,
        int24 _upperTick,
        int24 _spotTick,
        uint8 _profitScale
    ) external;

    
    
    
    
    
    function forceReBalance(
        int24 _lowerTick,
        int24 _upperTick,
        int24 _spotTick,
        uint8 _profitScale
    ) external;

    
    
    
    
    
    function reBalance(
        int24 reBalanceThreshold,
        int24 band,
        int24 _spotTick,
        uint8 _profitScale
    ) external;

}

// 
pragma solidity >=0.5.0;



interface IVaultOwnerActions {

    
    
    function changeManager(address _operator) external;

    
    
    
    function updateWhiteList(address _address, bool status) external;

    
    
    function withdrawPerformanceFee(address to) external;

}

// 
pragma solidity ^0.7.0;





/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// 
pragma solidity >=0.5.0;











interface IUniverseVaultV3 is IVaultOwnerActions, IVaultOperatorActionsV3, IVaultEventsV3{

    
    
    function token0() external view returns (IERC20);

    
    
    function token1() external view returns (IERC20);

    
    
    function protocolFees() external view returns (uint128 fee0, uint128 fee1);

    
    /// Returns maxShare0 The max share of token0
    /// Returns maxShare1 The max share of token1
    /// Returns maxPersonShare0 The max person share of token0
    /// Returns maxPersonShare1 The max person share of token1
    function maxShares() external view returns (uint256 maxShare0, uint256 maxShare1, uint256 maxPersonShare0, uint256 maxPersonShare1);

    
    
    /// Returns principal1 The principal of token1,
    /// Returns poolAddress The uniV3 pool address of the position,
    /// Returns lowerTick The lower tick of the position,
    /// Returns upperTick The upper tick of the position,
    /// Returns tickSpacing The uniV3 pool tickSpacing,
    /// Returns status The status of the position
    function position() external view returns (
        uint128 principal0,
        uint128 principal1,
        address poolAddress,
        int24 lowerTick,
        int24 upperTick,
        int24 tickSpacing,
        bool status
    );

    
    
    /// Returns share1 The share amount of token1,
    function getUserShares(address user) external view returns (uint256 share0, uint256 share1);

    
    
    /// Returns amount1 The amount of token1,
    function getUserBals(address user) external view returns (uint256 amount0, uint256 amount1);

    
    
    function totalShare0() external view returns (uint256);

    
    
    function totalShare1() external view returns (uint256);

    
    
    function getTotalAmounts() external view returns (uint256, uint256, uint256, uint256, uint256, uint256);

    
    
    
    function getPNL() external view returns (uint256 rate, uint256 param);

    
    
    
    
    function getShares(
        uint256 amount0Desired,
        uint256 amount1Desired
    ) external view returns (uint256, uint256);

    
    
    
    
    function getBals(uint256 share0, uint256 share1) external view returns (uint256, uint256);

    
    
    
    
    function deposit(
        uint256 amount0Desired,
        uint256 amount1Desired
    ) external returns(uint256, uint256) ;

    
    
    
    
    
    function deposit(
        uint256 amount0Desired,
        uint256 amount1Desired,
        address to
    ) external returns(uint256, uint256) ;

    
    
    
    function withdraw(uint256 share0, uint256 share1) external returns(uint256, uint256);

    
    
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;

    
    
    
    
    function uniswapV3MintCallback(
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

}

// 
pragma solidity ^0.7.0;



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// 
pragma solidity >=0.5.0;




/// to the ERC20 specification

interface IUniswapV3Pool {
    
    
    function factory() external view returns (address);

    
    
    function token0() external view returns (address);

    
    
    function token1() external view returns (address);

    
    
    function fee() external view returns (uint24);

    
    
    /// e.g.: a tickSpacing of 3 means ticks can be initialized every 3rd tick, i.e., ..., -6, -3, 0, 3, 6, ...
    /// This value is an int24 to avoid casting even though it is always positive.
    
    function tickSpacing() external view returns (int24);

    
    
    /// also prevents out-of-range liquidity from being used to prevent adding in-range liquidity to a pool
    
    function maxLiquidityPerTick() external view returns (uint128);

    
    /// when accessed externally.
    
    /// tick The current tick of the pool, i.e. according to the last tick transition that was run.
    /// This value may not always be equal to SqrtTickMath.getTickAtSqrtRatio(sqrtPriceX96) if the price is on a tick
    /// boundary.
    /// observationIndex The index of the last oracle observation that was written,
    /// observationCardinality The current maximum number of observations stored in the pool,
    /// observationCardinalityNext The next maximum number of observations, to be updated when the observation.
    /// feeProtocol The protocol fee for both tokens of the pool.
    /// Encoded as two 4 bit values, where the protocol fee of token1 is shifted 4 bits and the protocol fee of token0
    /// is the lower 4 bits. Used as the denominator of a fraction of the swap fee, e.g. 4 means 1/4th of the swap fee.
    /// unlocked Whether the pool is currently locked to reentrancy
    function slot0()
    external
    view
    returns (
        uint160 sqrtPriceX96,
        int24 tick,
        uint16 observationIndex,
        uint16 observationCardinality,
        uint16 observationCardinalityNext,
        uint8 feeProtocol,
        bool unlocked
    );

    
    
    function feeGrowthGlobal0X128() external view returns (uint256);

    
    
    function feeGrowthGlobal1X128() external view returns (uint256);

    
    
    function protocolFees() external view returns (uint128, uint128);

    
    
    function liquidity() external view returns (uint128);

    
    
    
    /// tick upper,
    /// liquidityNet how much liquidity changes when the pool price crosses the tick,
    /// feeGrowthOutside0X128 the fee growth on the other side of the tick from the current tick in token0,
    /// feeGrowthOutside1X128 the fee growth on the other side of the tick from the current tick in token1,
    /// tickCumulativeOutside the cumulative tick value on the other side of the tick from the current tick
    /// secondsPerLiquidityOutsideX128 the seconds spent per liquidity on the other side of the tick from the current tick,
    /// secondsOutside the seconds spent on the other side of the tick from the current tick,
    /// initialized Set to true if the tick is initialized, i.e. liquidityGross is greater than 0, otherwise equal to false.
    /// Outside values can only be used if the tick is initialized, i.e. if liquidityGross is greater than 0.
    /// In addition, these values are only relative and must be used only in comparison to previous snapshots for
    /// a specific position.
    function ticks(int24 tick)
    external
    view
    returns (
        uint128 liquidityGross,
        int128 liquidityNet,
        uint256 feeGrowthOutside0X128,
        uint256 feeGrowthOutside1X128,
        int56 tickCumulativeOutside,
        uint160 secondsPerLiquidityOutsideX128,
        uint32 secondsOutside,
        bool initialized
    );

    
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    
    
    
    /// Returns feeGrowthInside0LastX128 fee growth of token0 inside the tick range as of the last mint/burn/poke,
    /// Returns feeGrowthInside1LastX128 fee growth of token1 inside the tick range as of the last mint/burn/poke,
    /// Returns tokensOwed0 the computed amount of token0 owed to the position as of the last mint/burn/poke,
    /// Returns tokensOwed1 the computed amount of token1 owed to the position as of the last mint/burn/poke
    function positions(bytes32 key)
    external
    view
    returns (
        uint128 _liquidity,
        uint256 feeGrowthInside0LastX128,
        uint256 feeGrowthInside1LastX128,
        uint128 tokensOwed0,
        uint128 tokensOwed1
    );

    
    
    
    /// ago, rather than at a specific index in the array.
    
    /// Returns tickCumulative the tick multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
    /// Returns secondsPerLiquidityCumulativeX128 the seconds per in range liquidity for the life of the pool as of the observation timestamp,
    /// Returns initialized whether the observation has been initialized and the values are safe to use
    function observations(uint256 index)
    external
    view
    returns (
        uint32 blockTimestamp,
        int56 tickCumulative,
        uint160 secondsPerLiquidityCumulativeX128,
        bool initialized
    );

    
    
    /// the beginning of the period and another for the end of the period. E.g., to get the last hour time-weighted average tick,
    /// you must call it with secondsAgos = [3600, 0].
    
    /// log base sqrt(1.0001) of token1 / token0. The TickMath library can be used to go from a tick value to a ratio.
    
    
    
    /// timestamp
    function observe(uint32[] calldata secondsAgos)
    external
    view
    returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    
    
    /// I.e., snapshots cannot be compared if a position is not held for the entire period between when the first
    /// snapshot is taken and the second snapshot is taken.
    
    
    
    
    
    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
    external
    view
    returns (
        int56 tickCumulativeInside,
        uint160 secondsPerLiquidityInsideX128,
        uint32 secondsInside
    );

    
    
    
    function initialize(uint160 sqrtPriceX96) external;

    
    
    /// in which they must pay any token0 or token1 owed for the liquidity. The amount of token0/token1 due depends
    /// on tickLower, tickUpper, the amount of liquidity, and the current price.
    
    
    
    
    
    
    
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    
    
    /// Collect must be called by the position owner. To withdraw only token0 or only token1, amount0Requested or
    /// amount1Requested may be set to zero. To withdraw all tokens owed, caller may pass any value greater than the
    /// actual tokens owed, e.g. type(uint128).max. Tokens owed may be from accumulated swap fees or burned liquidity.
    
    
    
    
    
    
    
    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    
    
    
    
    
    
    
    
    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    
    
    
    
    
    
    /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
    
    
    
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    
    
    
    /// with 0 amount{0,1} and sending the donation amount(s) from the callback
    
    
    
    
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    
    
    /// the input observationCardinalityNext.
    
    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;

    
    
    
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    
    
    
    
    
    
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    
    
    
    
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    
    
    
    
    
    
    
    
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    
    
    
    
    
    
    
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    
    
    
    
    
    
    
    
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    
    
    
    
    
    
    
    
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    
    
    
    
    
    
    
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    
    
    /// just before a mint/swap/burn.
    
    
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    
    
    
    
    
    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    
    
    
    
    
    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}

// 
pragma solidity ^0.7.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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
pragma solidity >=0.4.0;



library FixedPoint128 {
    uint256 internal constant Q128 = 0x100000000000000000000000000000000;
}

// 
pragma solidity >=0.4.0;




library FixedPoint96 {
    uint8 internal constant RESOLUTION = 96;
    uint256 internal constant Q96 = 0x1000000000000000000000000;
}

// 
pragma solidity >=0.4.0;




library FullMath {
    
    
    
    
    
    
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // 512-bit multiply [prod1 prod0] = a * b
        // Compute the product mod 2**256 and mod 2**256 - 1
        // then use the Chinese Remainder Theorem to reconstruct
        // the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2**256 + prod0
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Handle non-overflow cases, 256 by 256 division
        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        // Make sure the result is less than 2**256.
        // Also prevents denominator == 0
        require(denominator > prod1);

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Make division exact by subtracting the remainder from [prod1 prod0]
        // Compute remainder using mulmod
        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        // Subtract 256 bit number from 512 bit number
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator
        // Compute largest power of two divisor of denominator.
        // Always >= 1.
        uint256 twos = -denominator & denominator;
        // Divide denominator by power of two
        assembly {
            denominator := div(denominator, twos)
        }

        // Divide [prod1 prod0] by the factors of two
        assembly {
            prod0 := div(prod0, twos)
        }
        // Shift in bits from prod1 into prod0. For this we need
        // to flip `twos` such that it is 2**256 / twos.
        // If twos is zero, then it becomes one
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        // Invert denominator mod 2**256
        // Now that denominator is an odd number, it has an inverse
        // modulo 2**256 such that denominator * inv = 1 mod 2**256.
        // Compute the inverse by starting with a seed that is correct
        // correct for four bits. That is, denominator * inv = 1 mod 2**4
        uint256 inv = (3 * denominator) ^ 2;
        // Now use Newton-Raphson iteration to improve the precision.
        // Thanks to Hensel's lifting lemma, this also works in modular
        // arithmetic, doubling the correct bits in each step.
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256

        // Because the division is now exact we can divide by multiplying
        // with the modular inverse of denominator. This will give us the
        // correct result modulo 2**256. Since the precoditions guarantee
        // that the outcome is less than 2**256, this is the final result.
        // We don't need to compute the high bits of the result and prod1
        // is no longer required.
        result = prod0 * inv;
        return result;
    }

    
    
    
    
    
    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }
}

// 
pragma solidity >=0.5.0;





library LiquidityAmounts {
    
    
    
    function toUint128(uint256 x) private pure returns (uint128 y) {
        require((y = uint128(x)) == x);
    }

    
    
    
    
    
    
    function getLiquidityForAmount0(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount0
    ) internal pure returns (uint128 liquidity) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        uint256 intermediate = FullMath.mulDiv(sqrtRatioAX96, sqrtRatioBX96, FixedPoint96.Q96);
        return toUint128(FullMath.mulDiv(amount0, intermediate, sqrtRatioBX96 - sqrtRatioAX96));
    }

    
    
    
    
    
    
    function getLiquidityForAmount1(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount1
    ) internal pure returns (uint128 liquidity) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        return toUint128(FullMath.mulDiv(amount1, FixedPoint96.Q96, sqrtRatioBX96 - sqrtRatioAX96));
    }

    
    /// pool prices and the prices at the tick boundaries
    
    
    
    
    
    
    function getLiquidityForAmounts(
        uint160 sqrtRatioX96,
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount0,
        uint256 amount1
    ) internal pure returns (uint128 liquidity) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        if (sqrtRatioX96 <= sqrtRatioAX96) {
            liquidity = getLiquidityForAmount0(sqrtRatioAX96, sqrtRatioBX96, amount0);
        } else if (sqrtRatioX96 < sqrtRatioBX96) {
            uint128 liquidity0 = getLiquidityForAmount0(sqrtRatioX96, sqrtRatioBX96, amount0);
            uint128 liquidity1 = getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioX96, amount1);

            liquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1;
        } else {
            liquidity = getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioBX96, amount1);
        }
    }

    
    
    
    
    
    function getAmount0ForLiquidity(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount0) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        return
        FullMath.mulDiv(
            uint256(liquidity) << FixedPoint96.RESOLUTION,
            sqrtRatioBX96 - sqrtRatioAX96,
            sqrtRatioBX96
        ) / sqrtRatioAX96;
    }

    
    
    
    
    
    function getAmount1ForLiquidity(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount1) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        return FullMath.mulDiv(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96);
    }

    
    /// pool prices and the prices at the tick boundaries
    
    
    
    
    
    
    function getAmountsForLiquidity(
        uint160 sqrtRatioX96,
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount0, uint256 amount1) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        if (sqrtRatioX96 <= sqrtRatioAX96) {
            amount0 = getAmount0ForLiquidity(sqrtRatioAX96, sqrtRatioBX96, liquidity);
        } else if (sqrtRatioX96 < sqrtRatioBX96) {
            amount0 = getAmount0ForLiquidity(sqrtRatioX96, sqrtRatioBX96, liquidity);
            amount1 = getAmount1ForLiquidity(sqrtRatioAX96, sqrtRatioX96, liquidity);
        } else {
            amount1 = getAmount1ForLiquidity(sqrtRatioAX96, sqrtRatioBX96, liquidity);
        }
    }
}

// 
pragma solidity ^0.7.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// 
pragma solidity >=0.5.0;


library PoolAddress {
    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    
    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    
    
    
    
    
    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    
    
    
    
    function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {
        require(key.token0 < key.token1);
        pool = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex'ff',
                        factory,
                        keccak256(abi.encode(key.token0, key.token1, key.fee)),
                        POOL_INIT_CODE_HASH
                    )
                )
            )
        );
    }
}

// 
pragma solidity ^0.7.6;











library PositionHelper {

    using SafeMath for uint256;

    struct Position {
        address poolAddress;
        int24 lowerTick;
        int24 upperTick;
        int24 tickSpacing;
        bool status; // True - InvestIn   False - NotInvest
    }

    /* ========== VIEW ========== */

    function _positionInfo(
        Position memory position
    ) internal view returns(uint128, uint256, uint256, uint256, uint256){
        // Pool OBJ
        IUniswapV3Pool pool = IUniswapV3Pool(position.poolAddress);
        // Get Position Key
        bytes32 positionKey = keccak256(abi.encodePacked(address(this), position.lowerTick, position.upperTick));
        // Get Position Detail
        return pool.positions(positionKey);
    }

    function _tickInfo(
        IUniswapV3Pool pool,
        int24 tick
    ) internal view returns (uint256 feeGrowthOutside0X128, uint256 feeGrowthOutside1X128) {
        // liquidityGross\liquidityNet\0\1\tickCumulativeOutside\secondsPerLiquidityOutsideX128\secondsOutside\initialized
        ( , , feeGrowthOutside0X128, feeGrowthOutside1X128, , , , ) = pool.ticks(tick);
    }

    function _getFeeGrowthInside(
        Position memory position
    ) internal view returns (uint256, uint256) {
        IUniswapV3Pool pool = IUniswapV3Pool(position.poolAddress);
        (int24 tickCurrent, uint256 feeGrowthGlobal0X128, uint256 feeGrowthGlobal1X128) = _poolInfo(pool);
        // calculate fee growth below
        (uint256 feeGrowthBelow0X128, uint256 feeGrowthBelow1X128) = _tickInfo(pool, position.lowerTick);
        if (tickCurrent < position.lowerTick) {
            feeGrowthBelow0X128 = feeGrowthGlobal0X128 - feeGrowthBelow0X128;
            feeGrowthBelow1X128 = feeGrowthGlobal1X128 - feeGrowthBelow1X128;
        }
        // calculate fee growth above
        (uint256 feeGrowthAbove0X128, uint256 feeGrowthAbove1X128) = _tickInfo(pool, position.upperTick);
        if (tickCurrent >= position.upperTick) {
            feeGrowthAbove0X128 = feeGrowthGlobal0X128 - feeGrowthAbove0X128;
            feeGrowthAbove1X128 = feeGrowthGlobal1X128 - feeGrowthAbove1X128;
        }
        // calculate inside
        uint256 feeGrowthInside0X128 = feeGrowthGlobal0X128 - feeGrowthBelow0X128 - feeGrowthAbove0X128;
        uint256 feeGrowthInside1X128 = feeGrowthGlobal1X128 - feeGrowthBelow1X128 - feeGrowthAbove1X128;
        return(feeGrowthInside0X128, feeGrowthInside1X128);
    }

    function _getPendingAmounts(
        Position memory position,
        uint128 liquidity,
        uint256 feeGrowthInside0LastX128,
        uint256 feeGrowthInside1LastX128
    ) internal view returns(uint256 tokensPending0, uint256 tokensPending1) {

        // feeInside
        (uint256 feeGrowthInside0X128, uint256 feeGrowthInside1X128) = _getFeeGrowthInside(position);

        // pending calculate
        tokensPending0 = FullMath.mulDiv(
            feeGrowthInside0X128 - feeGrowthInside0LastX128,
            liquidity,
            FixedPoint128.Q128
        );
        tokensPending1 = FullMath.mulDiv(
            feeGrowthInside1X128 - feeGrowthInside1LastX128,
            liquidity,
            FixedPoint128.Q128
        );
    }

    function _getTotalAmounts(Position memory position) internal view returns (uint256 total0, uint256 total1) {
        // Pool OBJ
        IUniswapV3Pool pool = IUniswapV3Pool(position.poolAddress);
        // position info
        (uint128 liquidity, uint256 feeGrowthInside0LastX128, uint256 feeGrowthInside1LastX128, , ) = _positionInfo(position);
        // liquidity Amount
        (uint160 sqrtRatioX96, , , , , , ) = pool.slot0();
        (total0, total1) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtRatioX96,
            TickMath.getSqrtRatioAtTick(position.lowerTick),
            TickMath.getSqrtRatioAtTick(position.upperTick),
            liquidity
        );
        // get Pending
        (uint256 pending0, uint256 pending1) = _getPendingAmounts(position, liquidity, feeGrowthInside0LastX128, feeGrowthInside1LastX128);
        total0 = total0 + pending0;
        total1 = total1 + pending1;
    }

    function _getTotalAmounts(Position memory position, uint8 _performanceFee) internal view returns (uint256 total0, uint256 total1) {
        // Pool OBJ
        IUniswapV3Pool pool = IUniswapV3Pool(position.poolAddress);
        // position info
        (uint128 liquidity, uint256 feeGrowthInside0LastX128, uint256 feeGrowthInside1LastX128, , ) = _positionInfo(position);
        // liquidity Amount
        (uint160 sqrtRatioX96, , , , , , ) = pool.slot0();
        (total0, total1) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtRatioX96,
            TickMath.getSqrtRatioAtTick(position.lowerTick),
            TickMath.getSqrtRatioAtTick(position.upperTick),
            liquidity
        );
        // get Pending
        (uint256 pending0, uint256 pending1) = _getPendingAmounts(position, liquidity, feeGrowthInside0LastX128, feeGrowthInside1LastX128);
        total0 = total0 + pending0;
        total1 = total1 + pending1;
        if(_performanceFee > 0){
            total0 = total0.sub(pending0.div(_performanceFee));
            total1 = total1.sub(pending1.div(_performanceFee));
        }
    }

    function _poolInfo(IUniswapV3Pool pool) internal view returns (int24, uint256, uint256) {
        ( , int24 tick, , , , , ) = pool.slot0();
        uint256 feeGrowthGlobal0X128 = pool.feeGrowthGlobal0X128();
        uint256 feeGrowthGlobal1X128 = pool.feeGrowthGlobal1X128();
        // return
        return (tick, feeGrowthGlobal0X128, feeGrowthGlobal1X128);
    }

    /* ========== BASE FUNCTION ========== */

    function _addLiquidity(
        Position memory position,
        uint128 liquidity
    ) internal returns (uint256 amount0, uint256 amount1){
        // Pool OBJ
        IUniswapV3Pool pool = IUniswapV3Pool(position.poolAddress);
        // add Liquidity on Uniswap
        (amount0, amount1) = pool.mint(
            address(this),
            position.lowerTick,
            position.upperTick,
            liquidity,
            ""
        );
    }

    function _burnLiquidity(
        Position memory position,
        uint128 liquidity
    ) internal returns (uint256 amount0, uint256 amount1) {
        // Pool OBJ
        IUniswapV3Pool pool = IUniswapV3Pool(position.poolAddress);
        (amount0, amount1) = pool.burn(position.lowerTick, position.upperTick, liquidity);
    }

    function _collect(
        Position memory position,
        address to,
        uint128 amount0,
        uint128 amount1
    ) internal returns (uint256 collect0, uint256 collect1) {
        // Pool OBJ
        IUniswapV3Pool pool = IUniswapV3Pool(position.poolAddress);
        // collect ALL to Vault
        (collect0, collect1) = pool.collect(
            to,
            position.lowerTick,
            position.upperTick,
            amount0,
            amount1
        );
    }

    /* ========== SENIOR FUNCTION ========== */

    function _addAll(
        Position memory position,
        uint256 balance0,
        uint256 balance1
    ) internal returns(uint256 amount0, uint256 amount1){
         // Pool OBJ
        IUniswapV3Pool pool = IUniswapV3Pool(position.poolAddress);
        // Calculate Liquidity
        (uint160 sqrtRatioX96, , , , , , ) = pool.slot0();
        uint128 liquidity = LiquidityAmounts.getLiquidityForAmounts(
            sqrtRatioX96,
            TickMath.getSqrtRatioAtTick(position.lowerTick),
            TickMath.getSqrtRatioAtTick(position.upperTick),
            balance0,
            balance1
        );
        // Add to Pool
        (amount0, amount1) = _addLiquidity(position, liquidity);
    }

    function _burnSpecific(
        Position memory position,
        uint128 liquidity,
        address to
    ) internal returns(uint256 amount0, uint256 amount1, uint fee0, uint fee1){
        // Burn
        (amount0, amount1) = _burnLiquidity(position, liquidity);
        // Collect to user
        _collect(position, to, uint128(amount0), uint128(amount1));
        // Collect to Vault
        (fee0, fee1) = _collect(position, address(this), type(uint128).max, type(uint128).max);
    }

    function _burnAll(Position memory position) internal returns(uint, uint) {
        // Read Liq
        (uint128 liquidity, , , , ) = _positionInfo(position);
        return _burn(position, liquidity);
    }

    function _burn(Position memory position, uint128 liquidity) internal returns(uint256 fee0, uint256 fee1) {
        // Burn
        (uint amt0, uint amt1) = _burnLiquidity(position, liquidity);
        // Collect
        (fee0, fee1) = _collect(position, address(this), type(uint128).max, type(uint128).max);
        fee0 = fee0 - amt0;
        fee1 = fee1 - amt1;
    }

    function _getReBalanceTicks(
        PositionHelper.Position memory position,
        int24 reBalanceThreshold,
        int24 band
    ) internal view returns (bool status, int24 lowerTick, int24 upperTick) {
        // get Current Tick
        IUniswapV3Pool pool = IUniswapV3Pool(position.poolAddress);
        ( , int24 tick, , , , , ) = pool.slot0();
        bool lowerRebalance;
        // Check status
        if (position.status) {
            int24 middleTick = (position.lowerTick + position.upperTick) / 2;
            if (middleTick - tick >= reBalanceThreshold) {
                status = true;
                lowerRebalance = true;
            }else if(tick - middleTick >= reBalanceThreshold){
                status = true;
            }
        } else {
            status = true;
        }
        // get new ticks
        if (status) {
            if(lowerRebalance && (tick % position.tickSpacing != 0)){
                tick = _floor(tick, position.tickSpacing) + position.tickSpacing ;
            }else{
                tick = _floor(tick, position.tickSpacing);
            }
            band = _floor(band, position.tickSpacing);
            lowerTick = tick - band;
            upperTick = tick + band;
        }
    }

    function checkDiffTick(PositionHelper.Position memory position, int24 _tick, uint24 _diffTick) internal view {
        // get Current Tick
        IUniswapV3Pool pool = IUniswapV3Pool(position.poolAddress);
        ( , int24 tick, , , , , ) = pool.slot0();
        require(tick - _tick < int24(_diffTick) && _tick - tick < int24(_diffTick), "DIFF TICK");
    }

    function _floor(int24 tick, int24 _tickSpacing) internal pure returns (int24) {
        int24 compressed = tick / _tickSpacing;
        if (tick < 0 && tick % _tickSpacing != 0) compressed--;
        return compressed * _tickSpacing;
    }
}

// 
pragma solidity ^0.7.6;











library PositionHelperV3 {

    using SafeMath for uint256;

    struct Position {
        uint128 principal0;
        uint128 principal1;
        address poolAddress;
        int24 lowerTick;
        int24 upperTick;
        int24 tickSpacing;
        bool status; // True - InvestIn   False - NotInvest
    }

    /* ========== VIEW ========== */

    function _positionInfo(
        Position memory position
    ) internal view returns(uint128, uint256, uint256, uint256, uint256){
        // Pool OBJ
        IUniswapV3Pool pool = IUniswapV3Pool(position.poolAddress);
        // Get Position Key
        bytes32 positionKey = keccak256(abi.encodePacked(address(this), position.lowerTick, position.upperTick));
        // Get Position Detail
        return pool.positions(positionKey);
    }

    function _tickInfo(
        IUniswapV3Pool pool,
        int24 tick
    ) internal view returns (uint256 feeGrowthOutside0X128, uint256 feeGrowthOutside1X128) {
        // liquidityGross\liquidityNet\0\1\tickCumulativeOutside\secondsPerLiquidityOutsideX128\secondsOutside\initialized
        ( , , feeGrowthOutside0X128, feeGrowthOutside1X128, , , , ) = pool.ticks(tick);
    }

    function _getFeeGrowthInside(
        Position memory position
    ) internal view returns (uint256, uint256) {
        IUniswapV3Pool pool = IUniswapV3Pool(position.poolAddress);
        (int24 tickCurrent, uint256 feeGrowthGlobal0X128, uint256 feeGrowthGlobal1X128) = _poolInfo(pool);
        // calculate fee growth below
        (uint256 feeGrowthBelow0X128, uint256 feeGrowthBelow1X128) = _tickInfo(pool, position.lowerTick);
        if (tickCurrent < position.lowerTick) {
            feeGrowthBelow0X128 = feeGrowthGlobal0X128 - feeGrowthBelow0X128;
            feeGrowthBelow1X128 = feeGrowthGlobal1X128 - feeGrowthBelow1X128;
        }
        // calculate fee growth above
        (uint256 feeGrowthAbove0X128, uint256 feeGrowthAbove1X128) = _tickInfo(pool, position.upperTick);
        if (tickCurrent >= position.upperTick) {
            feeGrowthAbove0X128 = feeGrowthGlobal0X128 - feeGrowthAbove0X128;
            feeGrowthAbove1X128 = feeGrowthGlobal1X128 - feeGrowthAbove1X128;
        }
        // calculate inside
        uint256 feeGrowthInside0X128 = feeGrowthGlobal0X128 - feeGrowthBelow0X128 - feeGrowthAbove0X128;
        uint256 feeGrowthInside1X128 = feeGrowthGlobal1X128 - feeGrowthBelow1X128 - feeGrowthAbove1X128;
        return(feeGrowthInside0X128, feeGrowthInside1X128);
    }

    function _getPendingAmounts(
        Position memory position,
        uint128 liquidity,
        uint256 feeGrowthInside0LastX128,
        uint256 feeGrowthInside1LastX128
    ) internal view returns(uint256 tokensPending0, uint256 tokensPending1) {

        // feeInside
        (uint256 feeGrowthInside0X128, uint256 feeGrowthInside1X128) = _getFeeGrowthInside(position);

        // pending calculate
        tokensPending0 = FullMath.mulDiv(
            feeGrowthInside0X128 - feeGrowthInside0LastX128,
            liquidity,
            FixedPoint128.Q128
        );
        tokensPending1 = FullMath.mulDiv(
            feeGrowthInside1X128 - feeGrowthInside1LastX128,
            liquidity,
            FixedPoint128.Q128
        );
    }

    function _getTotalAmounts(Position memory position, uint8 _performanceFee) internal view returns (uint256 total0, uint256 total1) {
        // Pool OBJ
        IUniswapV3Pool pool = IUniswapV3Pool(position.poolAddress);
        // position info
        (uint128 liquidity, uint256 feeGrowthInside0LastX128, uint256 feeGrowthInside1LastX128, , ) = _positionInfo(position);
        // liquidity Amount
        (uint160 sqrtRatioX96, , , , , , ) = pool.slot0();
        (total0, total1) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtRatioX96,
            TickMath.getSqrtRatioAtTick(position.lowerTick),
            TickMath.getSqrtRatioAtTick(position.upperTick),
            liquidity
        );
        // get Pending
        (uint256 pending0, uint256 pending1) = _getPendingAmounts(position, liquidity, feeGrowthInside0LastX128, feeGrowthInside1LastX128);
        total0 = total0 + pending0;
        total1 = total1 + pending1;
        if (_performanceFee > 0) {
            total0 = total0.sub(pending0.div(_performanceFee));
            total1 = total1.sub(pending1.div(_performanceFee));
        }
    }

    function _poolInfo(IUniswapV3Pool pool) internal view returns (int24, uint256, uint256) {
        ( , int24 tick, , , , , ) = pool.slot0();
        uint256 feeGrowthGlobal0X128 = pool.feeGrowthGlobal0X128();
        uint256 feeGrowthGlobal1X128 = pool.feeGrowthGlobal1X128();
        // return
        return (tick, feeGrowthGlobal0X128, feeGrowthGlobal1X128);
    }

    /* ========== BASE FUNCTION ========== */

    function _addLiquidity(
        Position memory position,
        uint128 liquidity
    ) internal returns (uint256 amount0, uint256 amount1){
        // Pool OBJ
        IUniswapV3Pool pool = IUniswapV3Pool(position.poolAddress);
        // add Liquidity on Uniswap
        (amount0, amount1) = pool.mint(
            address(this),
            position.lowerTick,
            position.upperTick,
            liquidity,
            ""
        );
    }

    function _burnLiquidity(
        Position memory position,
        uint128 liquidity
    ) internal returns (uint256 amount0, uint256 amount1) {
        // Pool OBJ
        IUniswapV3Pool pool = IUniswapV3Pool(position.poolAddress);
        (amount0, amount1) = pool.burn(position.lowerTick, position.upperTick, liquidity);
    }

    function _collect(
        Position memory position,
        address to,
        uint128 amount0,
        uint128 amount1
    ) internal returns (uint256 collect0, uint256 collect1) {
        // Pool OBJ
        IUniswapV3Pool pool = IUniswapV3Pool(position.poolAddress);
        // collect ALL to Vault
        (collect0, collect1) = pool.collect(
            to,
            position.lowerTick,
            position.upperTick,
            amount0,
            amount1
        );
    }

    /* ========== SENIOR FUNCTION ========== */

    function _addAll(
        Position memory position,
        uint256 balance0,
        uint256 balance1
    ) internal returns(uint256 amount0, uint256 amount1){
        // Pool OBJ
        IUniswapV3Pool pool = IUniswapV3Pool(position.poolAddress);
        // Calculate Liquidity
        (uint160 sqrtRatioX96, , , , , , ) = pool.slot0();
        uint128 liquidity = LiquidityAmounts.getLiquidityForAmounts(
            sqrtRatioX96,
            TickMath.getSqrtRatioAtTick(position.lowerTick),
            TickMath.getSqrtRatioAtTick(position.upperTick),
            balance0,
            balance1
        );
        // Add to Pool
        (amount0, amount1) = _addLiquidity(position, liquidity);
    }

    function _burnAll(
        Position memory position
    ) internal returns(uint256, uint256, uint256, uint256) {
        // Read Liq
        (uint128 liquidity, , , , ) = _positionInfo(position);
        if(liquidity == 0) return (0, 0, 0, 0);
        return _burn(position, liquidity);
    }

    function _burn(
        Position memory position,
        uint128 liquidity
    ) internal returns(uint256 amount0, uint256 amount1, uint256 fee0, uint256 fee1) {
        // Burn
        (fee0, fee1) = _burnLiquidity(position, liquidity);
        // Collect
        (amount0, amount1) = _collect(position, address(this), type(uint128).max, type(uint128).max);
        fee0 = amount0 - fee0;
        fee1 = amount1 - fee1;
    }

    function _getReBalanceTicks(
        Position memory position,
        int24 reBalanceThreshold,
        int24 band
    ) internal view returns (bool status, int24 lowerTick, int24 upperTick) {
        // get Current Tick
        IUniswapV3Pool pool = IUniswapV3Pool(position.poolAddress);
        ( , int24 tick, , , , , ) = pool.slot0();
        bool lowerRebalance;
        // Check status
        if (position.status) {
            int24 middleTick = (position.lowerTick + position.upperTick) / 2;
            if (middleTick - tick >= reBalanceThreshold) {
                status = true;
                lowerRebalance = true;
            }else if(tick - middleTick >= reBalanceThreshold){
                status = true;
            }
        } else {
            status = true;
        }
        // get new ticks
        if (status) {
            if(lowerRebalance && (tick % position.tickSpacing != 0)){
                tick = _floor(tick, position.tickSpacing) + position.tickSpacing ;
            }else{
                tick = _floor(tick, position.tickSpacing);
            }
            band = _floor(band, position.tickSpacing);
            lowerTick = tick - band;
            upperTick = tick + band;
        }
    }

    function checkDiffTick(Position memory position, int24 _tick, uint24 _diffTick) internal view {
        // get Current Tick
        IUniswapV3Pool pool = IUniswapV3Pool(position.poolAddress);
        ( , int24 tick, , , , , ) = pool.slot0();
        require(tick - _tick < int24(_diffTick) && _tick - tick < int24(_diffTick), "DIFF TICK");
    }

    function _floor(int24 tick, int24 _tickSpacing) internal pure returns (int24) {
        int24 compressed = tick / _tickSpacing;
        if (tick < 0 && tick % _tickSpacing != 0) compressed--;
        return compressed * _tickSpacing;
    }

}

// 
pragma solidity ^0.7.0;





/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// 
pragma solidity ^0.7.0;

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

    function add128(uint128 a, uint128 b) internal pure returns (uint128) {
        uint128 c = a + b;
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
pragma solidity >=0.5.0;



/// prices between 2**-128 and 2**128
library TickMath {
    
    int24 internal constant MIN_TICK = -887272;
    
    int24 internal constant MAX_TICK = -MIN_TICK;

    
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    
    
    
    
    /// at the given tick
    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
        require(absTick <= uint256(int256(MAX_TICK)), 'T');

        uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
        if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
        if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
        if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
        if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
        if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

        if (tick > 0) ratio = type(uint256).max / ratio;

        // this divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
        // we then downcast because we know the result always fits within 160 bits due to our tick input constraint
        // we round up in the division so getTickAtSqrtRatio of the output price is always consistent
        sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
    }

    
    
    /// ever return.
    
    
    function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {
        // second inequality must be < because the price can never reach the price at the max tick
        require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, 'R');
        uint256 ratio = uint256(sqrtPriceX96) << 32;

        uint256 r = ratio;
        uint256 msb = 0;

        assembly {
            let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(5, gt(r, 0xFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(4, gt(r, 0xFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(3, gt(r, 0xFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(2, gt(r, 0xF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(1, gt(r, 0x3))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := gt(r, 0x1)
            msb := or(msb, f)
        }

        if (msb >= 128) r = ratio >> (msb - 127);
        else r = ratio << (127 - msb);

        int256 log_2 = (int256(msb) - 128) << 64;

        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(63, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(62, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(61, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(60, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(59, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(58, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(57, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(56, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(55, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(54, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(53, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(52, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(51, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(50, f))
        }

        int256 log_sqrt10001 = log_2 * 255738958999603826347141; // 128.128 number

        int24 tickLow = int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128);
        int24 tickHi = int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128);

        tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96 ? tickHi : tickLow;
    }
}

// 
pragma solidity 0.7.6;



contract UToken is ERC20 {

    address private _owner;

    constructor(string memory _symbol, uint8 _decimals) ERC20(_symbol, _symbol, _decimals) {
        _owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == _owner, 'Only Owner!');
        _;
    }

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
        emit Mint(msg.sender, account, amount);
    }

    function burn(address account, uint256 value) external onlyOwner {
        _burn(account, value);
        emit Burn(msg.sender, account, value);
    }

    event Mint(address sender, address account, uint amount);
    event Burn(address sender, address account, uint amount);

}

// 
pragma solidity 0.7.6;

















contract UniverseVaultV3 is IUniverseVaultV3, Ownable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using SafeMath for uint128;
    using PositionHelperV3 for PositionHelperV3.Position;

    // Uni POOL
    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    // Important Addresses
    address immutable uniFactory;
    address operator;
    
    IERC20 public immutable override token0;
    
    IERC20 public immutable override token1;
    mapping(address => bool) poolMap;

    // Core Params
    address swapPool;
    uint8 performanceFee;
    
    uint24 diffTick;
    
    uint8 profitScale = 100;
    
    uint32 safetyParam = 99700;

    struct MaxShares {
        uint256 maxToken0Amt;
        uint256 maxToken1Amt;
        uint256 maxSingeDepositAmt0;
        uint256 maxSingeDepositAmt1;
    }

    
    MaxShares public override maxShares;

    
    struct ProtocolFees {
        uint128 fee0;
        uint128 fee1;
    }
    
    ProtocolFees public override protocolFees;

    
    PositionHelperV3.Position public override position;

    
    UToken immutable uToken0;
    
    UToken immutable uToken1;

    
    mapping(address => bool) contractWhiteLists;

    constructor(
        address _uniFactory,
        address _poolAddress,
        address _operator,
        address _swapPool,
        uint8 _performanceFee,
        uint24 _diffTick,
        uint256 _maxToken0,
        uint256 _maxToken1,
        uint256 _maxSingeDepositAmt0,
        uint256 _maxSingeDepositAmt1
    ) {
        require(_uniFactory != address(0), 'set _uniFactory to the zero address');
        require(_poolAddress != address(0), 'set _poolAddress to the zero address');
        require(_operator != address(0), 'set _operator to the zero address');
        require(_swapPool != address(0), 'set _swapPool to the zero address');
        uniFactory = _uniFactory;
        // pool info
        IUniswapV3Pool pool = IUniswapV3Pool(_poolAddress);
        IERC20 _token0 = IERC20(pool.token0());
        IERC20 _token1 = IERC20(pool.token1());
        poolMap[_poolAddress] = true;
        // variable
        operator = _operator;
        swapPool = _swapPool;
        if (_poolAddress != _swapPool) {
            poolMap[_swapPool] = true;
        }
        performanceFee = _performanceFee;
        diffTick = _diffTick;
        // Share Token
        uToken0 = new UToken(string(abi.encodePacked('U', _token0.symbol())), _token0.decimals());
        uToken1 = new UToken(string(abi.encodePacked('U', _token1.symbol())), _token1.decimals());
        token0 = _token0;
        token1 = _token1;
        // Control Param
        maxShares = MaxShares({
            maxToken0Amt : _maxToken0,
            maxToken1Amt : _maxToken1,
            maxSingeDepositAmt0 : _maxSingeDepositAmt0,
            maxSingeDepositAmt1 : _maxSingeDepositAmt1
        });
    }

    /* ========== MODIFIERS ========== */

    
    modifier onlyManager {
        require(tx.origin == operator, "OM");
        _;
    }

    /* ========== ONLY OWNER ========== */

    
    function changeManager(address _operator) external override onlyOwner {
        require(_operator != address(0), "ZERO ADDRESS");
        operator = _operator;
        emit ChangeManger(_operator);
    }

    
    function updateWhiteList(address _address, bool status) external override onlyOwner {
        require(_address != address(0), "ar");
        contractWhiteLists[_address] = status;
        emit UpdateWhiteList(_address, status);
    }

    
    function withdrawPerformanceFee(address to) external override onlyOwner {
        require(to != address(0), "ar");
        ProtocolFees memory pf = protocolFees;
        if(pf.fee0 > 1){
            token0.transfer(to, pf.fee0 - 1);
            pf.fee0 = 1;
        }
        if(pf.fee1 > 1){
            token1.transfer(to, pf.fee1 - 1);
            pf.fee1 = 1;
        }
        protocolFees = pf;
    }

    /* ========== PURE ========== */

    function _min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        if (x > y) {
            z = y;
        } else {
            z = x;
        }
    }

    function _max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        if (x > y) {
            z = x;
        } else {
            z = y;
        }
    }

    function _toUint128(uint256 x) internal pure returns (uint128) {
        assert(x <= type(uint128).max);
        return uint128(x);
    }

    
    function netValueToken1(
        uint256 amount0,
        uint256 amount1,
        uint256 priceX96
    ) internal pure returns (uint256 netValue) {
        netValue = FullMath.mulDiv(amount0, priceX96, FixedPoint96.Q96).add(amount1);
    }

    
    function tickRegulate(
        int24 _lowerTick,
        int24 _upperTick,
        int24 tickSpacing
    ) internal pure returns (int24 lowerTick, int24 upperTick) {
        lowerTick = PositionHelperV3._floor(_lowerTick, tickSpacing);
        upperTick = PositionHelperV3._floor(_upperTick, tickSpacing);
        require(_upperTick > _lowerTick, "Bad Ticks");
    }

    
    function _quantityTransform(
        uint256 newAmt,
        uint256 totalShare,
        uint256 totalAmt
    ) internal pure returns(uint256 newShare){
        if (newAmt != 0) {
            if (totalShare == 0) {
                newShare = newAmt;
            } else {
                newShare = FullMath.mulDiv(newAmt, totalShare, totalAmt);
            }
        }
    }

    /* ========== VIEW ========== */

    
    function _changeProfitScale(uint8 _profitScale) internal {
        if (_profitScale >= 50 && _profitScale <= 150) {
            profitScale = _profitScale;
        }
    }

    
    function _computeAddress(uint24 fee) internal view returns (address pool) {
        pool = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex'ff',
                        uniFactory,
                        keccak256(abi.encode(address(token0), address(token1), fee)),
                        POOL_INIT_CODE_HASH
                    )
                )
            )
        );
    }

    
    function _balance0() internal view returns (uint256) {
        return token0.balanceOf(address(this)) - protocolFees.fee0;
    }

    
    function _balance1() internal view returns (uint256) {
        return token1.balanceOf(address(this)) - protocolFees.fee1;
    }

    
    function _calcShare(
        uint256 amount0Desired,
        uint256 amount1Desired
    ) internal view returns (uint256 share0, uint256 share1, uint256 total0, uint256 total1) {
        // read Current Status
        (total0, total1, , ) = _getTotalAmounts(true);
        uint256 ts0 = uToken0.totalSupply();
        uint256 ts1 = uToken1.totalSupply();
        share0 = _quantityTransform(amount0Desired, ts0, total0);
        share1 = _quantityTransform(amount1Desired, ts1, total1);
    }

    
    function _calcBal(
        uint256 share0,
        uint256 share1
    ) internal view returns (
        uint256 bal0,
        uint256 bal1,
        uint256 free0,
        uint256 free1,
        uint256 rate,
        bool zeroBig
    ) {
        uint256 total0;
        uint256 total1;
        // read Current Status
        (total0, total1, free0, free1) = _getTotalAmounts(false);
        // Calculate the amount to withdraw
        bal0 = _quantityTransform(share0, total0, uToken0.totalSupply());
        bal1 = _quantityTransform(share1, total1, uToken1.totalSupply());
        // calc burn liq rate
        uint256 rate0;
        uint256 rate1;
        if(bal0 > free0){
            rate0 = FullMath.mulDiv(bal0.sub(free0), 1e5, total0.sub(free0));
        }
        if(bal1 > free1){
            rate1 = FullMath.mulDiv(bal1.sub(free1), 1e5, total1.sub(free1));
        }
        if(rate0 >= rate1){
            zeroBig = true;
        }
        rate = _max(rate0, rate1);
    }

    function _getTotalAmounts(bool forDeposit) internal view returns (
        uint256 total0,
        uint256 total1,
        uint256 free0,
        uint256 free1
    ) {
        // read in memory
        PositionHelperV3.Position memory pos = position;
        free0 = _balance0();
        free1 = _balance1();
        total0 = free0;
        total1 = free1;
        if (pos.status) {
            // get amount in Uniswap
            (uint256 now0, uint256 now1) = pos._getTotalAmounts(performanceFee);
            if(now0 > 0 || now1 > 0){ //
                // profit distribution
                uint256 priceX96 = _priceX96(pos.poolAddress);
                (now0, now1) = _getTargetToken(pos.principal0, pos.principal1, now0, now1, priceX96, forDeposit);
                // get Total
                total0 = total0.add(now0);
                total1 = total1.add(now1);
            }
        }
    }

    
    
    function getTotalAmounts() external view override returns (
        uint256 total0,
        uint256 total1,
        uint256 free0,
        uint256 free1,
        uint256 utilizationRate0,
        uint256 utilizationRate1
    ) {
        (total0, total1, free0, free1) = _getTotalAmounts(false);
        if (total0 > 0) {utilizationRate0 = 1e5 - free0.mul(1e5).div(total0);}
        if (total1 > 0) {utilizationRate1 = 1e5 - free1.mul(1e5).div(total1);}
    }

    
    
    function getPNL() external view override returns (uint256 rate, uint256 param) {
        param = safetyParam;
        // read in memory
        PositionHelperV3.Position memory pos = position;
        if (pos.status) {
            // total in v3
            (uint256 total0, uint256 total1) = pos._getTotalAmounts(performanceFee);
            // _priceX96
            uint256 priceX96 = _priceX96(pos.poolAddress);
            // calculate rate
            uint256 start_nv = netValueToken1(pos.principal0, pos.principal1, priceX96);
            uint256 end_nv = netValueToken1(total0, total1, priceX96);
            rate = end_nv.mul(1e5).div(start_nv);
        }
    }

    
    
    function getShares(
        uint256 amount0Desired,
        uint256 amount1Desired
    ) external view override returns (uint256 share0, uint256 share1) {
        (share0, share1, , ) = _calcShare(amount0Desired, amount1Desired);
    }

    
    
    function getBals(
        uint256 share0,
        uint256 share1
    ) external view override returns (uint256 amount0, uint256 amount1) {
        (amount0, amount1, , , ,) = _calcBal(share0, share1);
    }

    
    
    function getUserShares(address user) external view override returns (uint256 share0, uint256 share1) {
        share0 = uToken0.balanceOf(user);
        share1 = uToken1.balanceOf(user);
    }

    
    
    function getUserBals(address user) external view override returns (uint256 amount0, uint256 amount1) {
        uint256 share0 = uToken0.balanceOf(user);
        uint256 share1 = uToken1.balanceOf(user);
        (amount0, amount1, , , ,) = _calcBal(share0, share1);
    }

    
    
    function totalShare0() external view override returns (uint256) {
        return uToken0.totalSupply();
    }

    
    
    function totalShare1() external view override returns (uint256) {
        return uToken1.totalSupply();
    }

    /* ========== INTERNAL ========== */

    
    
    function _addAll(PositionHelperV3.Position memory pos) internal {
        // Read Fee Token Amount
        uint256 add0 = _balance0();
        uint256 add1 = _balance1();
        if(add0 > 0 && add1 > 0){
            // add liquidity
            (add0, add1) = pos._addAll(add0, add1);
            // increase principal
            pos.principal0 = pos.principal0.add128(_toUint128(add0));
            pos.principal1 = pos.principal1.add128(_toUint128(add1));
            // update Status
            pos.status = true;
        }
        // upadate position
        position = pos;
    }

    
    function _stopAll() internal {
        // burn all liquidity
        (uint256 collect0, uint256 collect1, uint256 fee0, uint256 fee1) = position._burnAll();
        // collect fee
        (uint256 feesToProtocol0, uint256 feesToProtocol1) = _collectPerformanceFee(fee0, fee1);
        _trim(collect0.sub(feesToProtocol0), collect1.sub(feesToProtocol1), 0, true);
    }

    
    function _stopPart(uint128 liq, bool withdrawZero) internal returns(int256 amtSelfDiff) {
        // burn liquidity
        (uint256 collect0, uint256 collect1, uint256 fee0, uint256 fee1) = position._burn(liq);
        // collect fee
        (uint256 feesToProtocol0, uint256 feesToProtocol1) = _collectPerformanceFee(fee0, fee1);
        //
        (amtSelfDiff) = _trim(collect0.sub(feesToProtocol0), collect1.sub(feesToProtocol1), liq, withdrawZero);
    }

    
    function _trim(
        uint256 stop0,
        uint256 stop1,
        uint128 liq,
        bool withdrawZero
    ) internal returns(int256 amtSelfDiff) {
        if(stop0 == 0 && stop1 == 0) return (0); //
        // read position in memory
        PositionHelperV3.Position memory pos = position;
        // calculate
        uint256 priceX96 = _priceX96(pos.poolAddress);
        uint256 start0 = pos.principal0;
        uint256 start1 = pos.principal1;
        if (liq != 0) { // Liquidate Part, Update Principal
            (uint128 total_liq, , , , ) = pos._positionInfo();
            start0 = FullMath.mulDiv(start0, liq, total_liq + liq);
            start1 = FullMath.mulDiv(start1, liq, total_liq + liq);
            pos.principal0 = pos.principal0 - _toUint128(start0);
            pos.principal1 = pos.principal1 - _toUint128(start1);
            position = pos;
        }
        (uint256 target0 , uint256 target1) = _getTargetToken(start0, start1, stop0, stop1, priceX96, false); // Use if always for withdraw
        int256 amt;
        bool zeroForOne;
        if(withdrawZero) {
            amt = int256(stop1) - int256(target1);
            if (amt < 0) zeroForOne = true;
            amtSelfDiff = int256(stop0) - int256(target0) ;
        }else{
            amt = int256(stop0) - int256(target0);
            if (amt > 0) zeroForOne = true;
            amtSelfDiff = int256(stop1) - int(target1) ;
        }
        if(amt != 0){
            uint160 sqrtPriceLimitX96 = (zeroForOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1);
            (int256 amount0, int256 amount1) = IUniswapV3Pool(swapPool).swap(address(this), zeroForOne, amt, sqrtPriceLimitX96, '');
            amtSelfDiff = amtSelfDiff - (withdrawZero ? amount0 : amount1);
        }
    }

    
    function _getTargetToken(
        uint256 start0,
        uint256 start1,
        uint256 end0,
        uint256 end1,
        uint256 priceX96,
        bool forDeposit
    ) internal view returns (uint256 target0, uint256 target1){
        uint256 start_nv = netValueToken1(start0, start1, priceX96);
        uint256 end_nv = netValueToken1(end0, end1, priceX96);
        uint256 rate = end_nv.mul(1e5).div(start_nv);
        // For safe when deposit
        if (forDeposit && rate < safetyParam) {
            rate = safetyParam;
        }
        // profit distribution
        if (rate > 1e5 && profitScale != 100) {
            rate = rate.sub(1e5).mul(profitScale).div(1e2).add(1e5);
            target0 = FullMath.mulDiv(start0, rate, 1e5);
            target1 = end_nv.sub(FullMath.mulDiv(target0, priceX96, FixedPoint96.Q96));
        } else {
            target0 = FullMath.mulDiv(start0, rate, 1e5);
            target1 = FullMath.mulDiv(start1, rate, 1e5);
        }
    }

    function _collectPerformanceFee(
        uint256 feesFromPool0,
        uint256 feesFromPool1
    ) internal returns (uint256 feesToProtocol0, uint256 feesToProtocol1){
        uint256 rate = performanceFee;
        if (rate != 0) {
            ProtocolFees memory pf = protocolFees;
            if (feesFromPool0 > 0) {
                feesToProtocol0 = feesFromPool0.div(rate);
                pf.fee0 = pf.fee0.add128(_toUint128(feesToProtocol0));
            }
            if (feesFromPool1 > 0) {
                feesToProtocol1 = feesFromPool1.div(rate);
                pf.fee1 = pf.fee1.add128(_toUint128(feesToProtocol1));
            }
            protocolFees = pf;
            emit CollectFees(feesFromPool0, feesFromPool1);
        }
    }

    function _priceX96(address poolAddress) internal view returns(uint256 priceX96){
        (uint160 sqrtRatioX96, , , , , , ) = IUniswapV3Pool(poolAddress).slot0();
        priceX96 = FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, FixedPoint96.Q96);
    }

    
    function _deposit(
        uint256 amount0Desired,
        uint256 amount1Desired,
        address to
    ) internal returns(uint256 share0, uint256 share1) {
        // Check Params
        require(amount0Desired > 0 || amount1Desired > 0, "Deposit Zero!");
        // Read Control Param
        MaxShares memory _maxShares = maxShares;
        require(amount0Desired <= _maxShares.maxSingeDepositAmt0 && amount1Desired <= _maxShares.maxSingeDepositAmt1, "Too Much Deposit!");
        uint256 total0;
        uint256 total1;
        // Cal Share
        (share0, share1, total0, total1) = _calcShare(amount0Desired, amount1Desired);
        // check max share
        require(total0.add(amount0Desired) <= _maxShares.maxToken0Amt
                && total1.add(amount1Desired) <= _maxShares.maxToken1Amt, "exceed total limit");
        // transfer
        if (amount0Desired > 0) token0.safeTransferFrom(msg.sender, address(this), amount0Desired);
        if (amount1Desired > 0) token1.safeTransferFrom(msg.sender, address(this), amount1Desired);
        // add share
        if (share0 > 0) {
            uToken0.mint(to, share0);
        }
        if (share1 > 0) {
            uToken1.mint(to, share1);
        }
        // Invest All
        if (position.status) {
            _addAll(position);
        }
        // EVENT
        emit Deposit(to, share0, share1, amount0Desired, amount1Desired);
    }

    /* ========== EXTERNAL ========== */

    
    
    function deposit(
        uint256 amount0Desired,
        uint256 amount1Desired
    ) external override returns(uint256, uint256) {
        require(tx.origin == msg.sender || contractWhiteLists[msg.sender], "only for verified contract!");
        return _deposit(amount0Desired, amount1Desired, msg.sender);
    }

    
    
    function deposit(
        uint256 amount0Desired,
        uint256 amount1Desired,
        address to
    ) external override returns(uint256, uint256) {
        require(contractWhiteLists[msg.sender], "only for verified contract!");
        return _deposit(amount0Desired, amount1Desired, to);
    }

    
    function withdraw(uint256 share0, uint256 share1) external override returns(uint256, uint256){
        require(share0 !=0 || share1 !=0, "Withdraw Zero Share!");
        if (share0 > 0) {
            share0 = _min(share0, uToken0.balanceOf(msg.sender));
        }
        if (share1 > 0) {
            share1 = _min(share1, uToken1.balanceOf(msg.sender));
        }
        (uint256 withdraw0, uint256 withdraw1, , , uint256 rate, bool withdrawZero) = _calcBal(share0, share1);
        // Burn
        if (share0 > 0) {uToken0.burn(msg.sender, share0);}
        if (share1 > 0) {uToken1.burn(msg.sender, share1);}
        // swap
        if (rate > 0 && position.status) {
            (uint128 liq, , , , ) = position._positionInfo();
            if (rate < 1e5) {liq = (liq * _toUint128(rate) / 1e5);}
            // all fees related to transaction
            (int256 amtSelfDiff) = _stopPart(liq, withdrawZero);
            if(amtSelfDiff < 0){
                if(withdrawZero){
                    withdraw0 = withdraw0.sub(uint(-amtSelfDiff));
                }else{
                    withdraw1 = withdraw1.sub(uint(-amtSelfDiff));
                }
            }
        }
        if (withdraw0 > 0) {
            withdraw0 = _min(withdraw0, _balance0());
            token0.safeTransfer(msg.sender, withdraw0);
        }
        if (withdraw1 > 0) {
            withdraw1 = _min(withdraw1, _balance1());
            token1.safeTransfer(msg.sender, withdraw1);
        }

        emit Withdraw(msg.sender, share0, share1, withdraw0, withdraw1);

        return (withdraw0, withdraw1);
    }

    /* ========== ONLY MANAGER ========== */

    
    function initPosition(
        address _poolAddress,
        int24 _lowerTick,
        int24 _upperTick
    ) external override onlyManager {
        require(poolMap[_poolAddress], 'add Pool First');
        require(!position.status, 'position is working, cannot init!');
        IUniswapV3Pool pool = IUniswapV3Pool(_poolAddress);
        int24 tickSpacing = pool.tickSpacing();
        (_lowerTick, _upperTick) = tickRegulate(_lowerTick, _upperTick, tickSpacing);
        position = PositionHelperV3.Position({
            principal0 : 0,
            principal1 : 0,
            poolAddress : _poolAddress,
            tickSpacing : tickSpacing,
            lowerTick : _lowerTick,
            upperTick : _upperTick,
            status: true
        });
    }

    
    function addPool(uint24 _poolFee) external override onlyManager {
        require(_poolFee == 3000 || _poolFee == 500 || _poolFee == 10000, "Wrong poolFee!");
        address poolAddress = _computeAddress(_poolFee);
        poolMap[poolAddress] = true;
    }

    
    function changeConfig(
        address _swapPool,
        uint8 _performanceFee,
        uint24 _diffTick,
        uint32 _safetyParam
    ) external override onlyManager {
        require(_performanceFee == 0 || _performanceFee > 4, "20Percent MAX!");
        require(_safetyParam <= 1e5, 'Wrong safety param!');
        if (_swapPool != address(0) && poolMap[_swapPool]) {swapPool = _swapPool;}
        if (performanceFee != _performanceFee) {performanceFee = _performanceFee;}
        if (diffTick != _diffTick) {diffTick = _diffTick;}
        if (safetyParam != _safetyParam) {safetyParam = _safetyParam;}
    }

    
    function changeMaxShare(
        uint256 _maxShare0,
        uint256 _maxShare1,
        uint256 _maxSingeDepositAmt0,
        uint256 _maxSingeDepositAmt1
    ) external override onlyManager {
        MaxShares memory _maxShares = maxShares;
        if (_maxShare0 != _maxShares.maxToken0Amt) {_maxShares.maxToken0Amt = _maxShare0;}
        if (_maxShare1 != _maxShares.maxToken1Amt) {_maxShares.maxToken1Amt = _maxShare1;}
        if (_maxSingeDepositAmt0 != _maxShares.maxSingeDepositAmt0) {_maxShares.maxSingeDepositAmt0 = _maxSingeDepositAmt0;}
        if (_maxSingeDepositAmt1 != _maxShares.maxSingeDepositAmt1) {_maxShares.maxSingeDepositAmt1 = _maxSingeDepositAmt1;}
        maxShares = _maxShares;
    }

    
    function avoidRisk(uint8 _profitScale) external override onlyManager {
        if (position.status) {
            _stopAll();
            position.status = false;
        }
        _changeProfitScale(_profitScale);
    }

    
    function changePool(
        address newPoolAddress,
        int24 _lowerTick,
        int24 _upperTick,
        int24 _spotTick, // the tick when decide to send the transaction
        uint8 _profitScale
    ) external override onlyManager {
        // Check
        require(poolMap[newPoolAddress], 'Add Pool First!');
        // read in memory
        PositionHelperV3.Position memory pos = position;
        // check attack
        pos.checkDiffTick(_spotTick, diffTick);
        require(pos.status && pos.poolAddress != newPoolAddress, "CAN NOT CHANGE POOL!");
        // stop current pool & change profit config
        _stopAll();
        pos.status = false;
        _changeProfitScale(_profitScale);
        // new pool info
        int24 tickSpacing = IUniswapV3Pool(newPoolAddress).tickSpacing();
        (_lowerTick, _upperTick) = tickRegulate(_lowerTick, _upperTick, tickSpacing);
        pos.principal0 = 0;
        pos.principal1 = 0;
        pos.poolAddress = newPoolAddress;
        pos.tickSpacing = tickSpacing;
        pos.upperTick = _upperTick;
        pos.lowerTick = _lowerTick;
        // add liquidity
        _addAll(pos);
    }

    
    function forceReBalance(
        int24 _lowerTick,
        int24 _upperTick,
        int24 _spotTick,
        uint8 _profitScale
    ) public override onlyManager{
        // read in memory
        PositionHelperV3.Position memory pos = position;
        // Check Status
        (_lowerTick, _upperTick) = tickRegulate(_lowerTick, _upperTick, pos.tickSpacing);
        if (pos.lowerTick == _lowerTick && pos.upperTick == _upperTick) {
            return;
        }
        pos.checkDiffTick(_spotTick, diffTick);
        // stopAll & change profit config
        if (pos.status) {
            _stopAll();
            pos.status = false;
        }
        _changeProfitScale(_profitScale);
        // new pool info
        pos.principal0 = 0;
        pos.principal1 = 0;
        pos.upperTick = _upperTick;
        pos.lowerTick = _lowerTick;
        // add liquidity
        _addAll(pos);
    }

    
    function reBalance(
        int24 reBalanceThreshold,
        int24 band,
        int24 _spotTick,
        uint8 _profitScale
    ) external override onlyManager {
        require(band > 0 && reBalanceThreshold > 0, "Bad params!");
        (bool status, int24 lowerTick, int24 upperTick) = position._getReBalanceTicks(reBalanceThreshold, band);
        if (status) {
            forceReBalance(lowerTick, upperTick, _spotTick, _profitScale);
        }
    }

    /* ========== CALL BACK ========== */

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata
    ) external override {
        require(amount0Delta > 0 || amount1Delta > 0, 'Zero');
        require(swapPool == msg.sender, "wrong address");
        if (amount0Delta > 0) {
            token0.transfer(msg.sender, uint256(amount0Delta));
        }
        if (amount1Delta > 0) {
            token1.transfer(msg.sender, uint256(amount1Delta));
        }
    }

    function uniswapV3MintCallback(
        uint256 amount0,
        uint256 amount1,
        bytes calldata
    ) external override {
        require(poolMap[msg.sender], "wrong address");
        // transfer
        if (amount0 > 0) {token0.safeTransfer(msg.sender, amount0);}
        if (amount1 > 0) {token1.safeTransfer(msg.sender, amount1);}
    }

}