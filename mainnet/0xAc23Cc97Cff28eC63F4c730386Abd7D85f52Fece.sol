// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;


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

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;



/// Provides an interface to get the externalPositionLib for a given type from the Vault
interface IExternalPositionVault {
    function getExternalPositionLibForType(uint256) external view returns (address);
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;




/// are guaranteed to be freely transferable.

interface IFreelyTransferableSharesVault {
    function sharesAreFreelyTransferable()
        external
        view
        returns (bool sharesAreFreelyTransferable_);
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;




interface IMigratableVault {
    function canMigrate(address _who) external view returns (bool canMigrate_);

    function init(
        address _owner,
        address _accessor,
        string calldata _fundName
    ) external;

    function setAccessor(address _nextAccessor) external;

    function setVaultLib(address _nextVaultLib) external;
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;





interface IComptroller {
    function activate(bool) external;

    function calcGav() external returns (uint256);

    function calcGrossShareValue() external returns (uint256);

    function callOnExtension(
        address,
        uint256,
        bytes calldata
    ) external;

    function destructActivated(uint256, uint256) external;

    function destructUnactivated() external;

    function getDenominationAsset() external view returns (address);

    function getExternalPositionManager() external view returns (address);

    function getFeeManager() external view returns (address);

    function getFundDeployer() external view returns (address);

    function getGasRelayPaymaster() external view returns (address);

    function getIntegrationManager() external view returns (address);

    function getPolicyManager() external view returns (address);

    function getVaultProxy() external view returns (address);

    function init(address, uint256) external;

    function permissionedVaultAction(IVault.VaultAction, bytes calldata) external;

    function preTransferSharesHook(
        address,
        address,
        uint256
    ) external;

    function preTransferSharesHookFreelyTransferable(address) external view;

    function setGasRelayPaymaster(address) external;

    function setVaultProxy(address) external;
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/




pragma solidity 0.6.12;





/// unless it is no longer inherited by the VaultLib
abstract contract GasRelayRecipientMixin {
    address internal immutable GAS_RELAY_PAYMASTER_FACTORY;

    constructor(address _gasRelayPaymasterFactory) internal {
        GAS_RELAY_PAYMASTER_FACTORY = _gasRelayPaymasterFactory;
    }

    
    function __msgSender() internal view returns (address payable canonicalSender_) {
        if (msg.data.length >= 24 && msg.sender == getGasRelayTrustedForwarder()) {
            assembly {
                canonicalSender_ := shr(96, calldataload(sub(calldatasize(), 20)))
            }

            return canonicalSender_;
        }

        return msg.sender;
    }

    ///////////////////
    // STATE GETTERS //
    ///////////////////

    
    
    function getGasRelayPaymasterFactory()
        public
        view
        returns (address gasRelayPaymasterFactory_)
    {
        return GAS_RELAY_PAYMASTER_FACTORY;
    }

    
    
    function getGasRelayTrustedForwarder() public view returns (address trustedForwarder_) {
        return
            IGasRelayPaymaster(
                IBeaconProxyFactory(getGasRelayPaymasterFactory()).getCanonicalLib()
            )
                .trustedForwarder();
    }
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;



interface IGasRelayPaymasterDepositor {
    function pullWethForGasRelayer(uint256) external;
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;






interface IGsnPaymaster {
    struct GasAndDataLimits {
        uint256 acceptanceBudget;
        uint256 preRelayedCallGasLimit;
        uint256 postRelayedCallGasLimit;
        uint256 calldataSizeLimit;
    }

    function getGasAndDataLimits() external view returns (GasAndDataLimits memory limits);

    function getHubAddr() external view returns (address);

    function getRelayHubDeposit() external view returns (uint256);

    function preRelayedCall(
        IGsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature,
        bytes calldata approvalData,
        uint256 maxPossibleGas
    ) external returns (bytes memory context, bool rejectOnRecipientRevert);

    function postRelayedCall(
        bytes calldata context,
        bool success,
        uint256 gasUseWithoutPost,
        IGsnTypes.RelayData calldata relayData
    ) external;

    function trustedForwarder() external view returns (address);

    function versionPaymaster() external view returns (string memory);
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;








abstract contract AssetHelpers {
    using SafeERC20 for ERC20;
    using SafeMath for uint256;

    
    /// This is helpful for fully trusted contracts, such as adapters that
    /// interact with external protocol like Uniswap, Compound, etc.
    function __approveAssetMaxAsNeeded(
        address _asset,
        address _target,
        uint256 _neededAmount
    ) internal {
        uint256 allowance = ERC20(_asset).allowance(address(this), _target);
        if (allowance < _neededAmount) {
            if (allowance > 0) {
                ERC20(_asset).safeApprove(_target, 0);
            }
            ERC20(_asset).safeApprove(_target, type(uint256).max);
        }
    }

    
    function __pushFullAssetBalances(address _target, address[] memory _assets)
        internal
        returns (uint256[] memory amountsTransferred_)
    {
        amountsTransferred_ = new uint256[](_assets.length);
        for (uint256 i; i < _assets.length; i++) {
            ERC20 assetContract = ERC20(_assets[i]);
            amountsTransferred_[i] = assetContract.balanceOf(address(this));
            if (amountsTransferred_[i] > 0) {
                assetContract.safeTransfer(_target, amountsTransferred_[i]);
            }
        }

        return amountsTransferred_;
    }
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;



interface IBeacon {
    function getCanonicalLib() external view returns (address);
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

pragma solidity >=0.6.0 <0.8.0;





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
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
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
    function symbol() public view virtual returns (string memory) {
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
    function decimals() public view virtual returns (uint8) {
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

pragma solidity >=0.6.0 <0.8.0;





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

pragma solidity >=0.6.2 <0.8.0;

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

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;



interface IDispatcher {
    function cancelMigration(address _vaultProxy, bool _bypassFailure) external;

    function claimOwnership() external;

    function deployVaultProxy(
        address _vaultLib,
        address _owner,
        address _vaultAccessor,
        string calldata _fundName
    ) external returns (address vaultProxy_);

    function executeMigration(address _vaultProxy, bool _bypassFailure) external;

    function getCurrentFundDeployer() external view returns (address currentFundDeployer_);

    function getFundDeployerForVaultProxy(address _vaultProxy)
        external
        view
        returns (address fundDeployer_);

    function getMigrationRequestDetailsForVaultProxy(address _vaultProxy)
        external
        view
        returns (
            address nextFundDeployer_,
            address nextVaultAccessor_,
            address nextVaultLib_,
            uint256 executableTimestamp_
        );

    function getMigrationTimelock() external view returns (uint256 migrationTimelock_);

    function getNominatedOwner() external view returns (address nominatedOwner_);

    function getOwner() external view returns (address owner_);

    function getSharesTokenSymbol() external view returns (string memory sharesTokenSymbol_);

    function getTimelockRemainingForMigrationRequest(address _vaultProxy)
        external
        view
        returns (uint256 secondsRemaining_);

    function hasExecutableMigrationRequest(address _vaultProxy)
        external
        view
        returns (bool hasExecutableRequest_);

    function hasMigrationRequest(address _vaultProxy)
        external
        view
        returns (bool hasMigrationRequest_);

    function removeNominatedOwner() external;

    function setCurrentFundDeployer(address _nextFundDeployer) external;

    function setMigrationTimelock(uint256 _nextTimelock) external;

    function setNominatedOwner(address _nextNominatedOwner) external;

    function setSharesTokenSymbol(string calldata _nextSymbol) external;

    function signalMigration(
        address _vaultProxy,
        address _nextVaultAccessor,
        address _nextVaultLib,
        bool _bypassFailure
    ) external;
}

// 

/*
    This file is part of the Enzyme Protocol.
    (c) Enzyme Council <[email protected]>
    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;



interface IExternalPosition {
    function getDebtAssets() external returns (address[] memory, uint256[] memory);

    function getManagedAssets() external returns (address[] memory, uint256[] memory);

    function init(bytes memory) external;

    function receiveCallFromVault(bytes memory) external;
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;



interface IFundDeployer {
    function getOwner() external view returns (address);

    function hasReconfigurationRequest(address) external view returns (bool);

    function isAllowedBuySharesOnBehalfCaller(address) external view returns (bool);

    function isAllowedVaultCall(
        address,
        bytes4,
        bytes32
    ) external view returns (bool);
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;






















contract ComptrollerLib is IComptroller, IGasRelayPaymasterDepositor, GasRelayRecipientMixin {
    using AddressArrayLib for address[];
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    event AutoProtocolFeeSharesBuybackSet(bool autoProtocolFeeSharesBuyback);

    event BuyBackMaxProtocolFeeSharesFailed(
        bytes indexed failureReturnData,
        uint256 sharesAmount,
        uint256 buybackValueInMln,
        uint256 gav
    );
    event DeactivateFeeManagerFailed();

    event GasRelayPaymasterSet(address gasRelayPaymaster);

    event MigratedSharesDuePaid(uint256 sharesDue);

    event PayProtocolFeeDuringDestructFailed();

    event PreRedeemSharesHookFailed(
        bytes indexed failureReturnData,
        address indexed redeemer,
        uint256 sharesAmount
    );

    event RedeemSharesInKindCalcGavFailed();

    event SharesBought(
        address indexed buyer,
        uint256 investmentAmount,
        uint256 sharesIssued,
        uint256 sharesReceived
    );

    event SharesRedeemed(
        address indexed redeemer,
        address indexed recipient,
        uint256 sharesAmount,
        address[] receivedAssets,
        uint256[] receivedAssetAmounts
    );

    event VaultProxySet(address vaultProxy);

    // Constants and immutables - shared by all proxies
    uint256 private constant ONE_HUNDRED_PERCENT = 10000;
    uint256 private constant SHARES_UNIT = 10**18;
    address
        private constant SPECIFIC_ASSET_REDEMPTION_DUMMY_FORFEIT_ADDRESS = 0x000000000000000000000000000000000000aaaa;
    address private immutable DISPATCHER;
    address private immutable EXTERNAL_POSITION_MANAGER;
    address private immutable FUND_DEPLOYER;
    address private immutable FEE_MANAGER;
    address private immutable INTEGRATION_MANAGER;
    address private immutable MLN_TOKEN;
    address private immutable POLICY_MANAGER;
    address private immutable PROTOCOL_FEE_RESERVE;
    address private immutable VALUE_INTERPRETER;
    address private immutable WETH_TOKEN;

    // Pseudo-constants (can only be set once)

    address internal denominationAsset;
    address internal vaultProxy;
    // True only for the one non-proxy
    bool internal isLib;

    // Storage

    // Attempts to buy back protocol fee shares immediately after collection
    bool internal autoProtocolFeeSharesBuyback;
    // A reverse-mutex, granting atomic permission for particular contracts to make vault calls
    bool internal permissionedVaultActionAllowed;
    // A mutex to protect against reentrancy
    bool internal reentranceLocked;
    // A timelock after the last time shares were bought for an account
    // that must expire before that account transfers or redeems their shares
    uint256 internal sharesActionTimelock;
    mapping(address => uint256) internal acctToLastSharesBoughtTimestamp;
    // The contract which manages paying gas relayers
    address private gasRelayPaymaster;

    ///////////////
    // MODIFIERS //
    ///////////////

    modifier allowsPermissionedVaultAction {
        __assertPermissionedVaultActionNotAllowed();
        permissionedVaultActionAllowed = true;
        _;
        permissionedVaultActionAllowed = false;
    }

    modifier locksReentrance() {
        __assertNotReentranceLocked();
        reentranceLocked = true;
        _;
        reentranceLocked = false;
    }

    modifier onlyFundDeployer() {
        __assertIsFundDeployer();
        _;
    }
    modifier onlyGasRelayPaymaster() {
        __assertIsGasRelayPaymaster();
        _;
    }

    modifier onlyOwner() {
        __assertIsOwner(__msgSender());
        _;
    }

    modifier onlyOwnerNotRelayable() {
        __assertIsOwner(msg.sender);
        _;
    }

    // ASSERTION HELPERS

    // Modifiers are inefficient in terms of contract size,
    // so we use helper functions to prevent repetitive inlining of expensive string values.

    function __assertIsFundDeployer() private view {
        require(msg.sender == getFundDeployer(), "Only FundDeployer callable");
    }

    function __assertIsGasRelayPaymaster() private view {
        require(msg.sender == getGasRelayPaymaster(), "Only Gas Relay Paymaster callable");
    }

    function __assertIsOwner(address _who) private view {
        require(_who == IVault(getVaultProxy()).getOwner(), "Only fund owner callable");
    }

    function __assertNotReentranceLocked() private view {
        require(!reentranceLocked, "Re-entrance");
    }

    function __assertPermissionedVaultActionNotAllowed() private view {
        require(!permissionedVaultActionAllowed, "Vault action re-entrance");
    }

    function __assertSharesActionNotTimelocked(address _vaultProxy, address _account)
        private
        view
    {
        uint256 lastSharesBoughtTimestamp = getLastSharesBoughtTimestampForAccount(_account);

        require(
            lastSharesBoughtTimestamp == 0 ||
                block.timestamp.sub(lastSharesBoughtTimestamp) >= getSharesActionTimelock() ||
                __hasPendingMigrationOrReconfiguration(_vaultProxy),
            "Shares action timelocked"
        );
    }

    constructor(
        address _dispatcher,
        address _protocolFeeReserve,
        address _fundDeployer,
        address _valueInterpreter,
        address _externalPositionManager,
        address _feeManager,
        address _integrationManager,
        address _policyManager,
        address _gasRelayPaymasterFactory,
        address _mlnToken,
        address _wethToken
    ) public GasRelayRecipientMixin(_gasRelayPaymasterFactory) {
        DISPATCHER = _dispatcher;
        EXTERNAL_POSITION_MANAGER = _externalPositionManager;
        FEE_MANAGER = _feeManager;
        FUND_DEPLOYER = _fundDeployer;
        INTEGRATION_MANAGER = _integrationManager;
        MLN_TOKEN = _mlnToken;
        POLICY_MANAGER = _policyManager;
        PROTOCOL_FEE_RESERVE = _protocolFeeReserve;
        VALUE_INTERPRETER = _valueInterpreter;
        WETH_TOKEN = _wethToken;
        isLib = true;
    }

    /////////////
    // GENERAL //
    /////////////

    
    
    
    
    
    /// (for access control). Uses a mutex of sorts that allows "permissioned vault actions"
    /// during calls originating from this function.
    function callOnExtension(
        address _extension,
        uint256 _actionId,
        bytes calldata _callArgs
    ) external override locksReentrance allowsPermissionedVaultAction {
        require(
            _extension == getFeeManager() ||
                _extension == getIntegrationManager() ||
                _extension == getExternalPositionManager(),
            "callOnExtension: _extension invalid"
        );

        IExtension(_extension).receiveCallFromComptroller(__msgSender(), _actionId, _callArgs);
    }

    
    
    
    
    
    function vaultCallOnContract(
        address _contract,
        bytes4 _selector,
        bytes calldata _encodedArgs
    ) external onlyOwner returns (bytes memory returnData_) {
        require(
            IFundDeployer(getFundDeployer()).isAllowedVaultCall(
                _contract,
                _selector,
                keccak256(_encodedArgs)
            ),
            "vaultCallOnContract: Not allowed"
        );

        return
            IVault(getVaultProxy()).callOnContract(
                _contract,
                abi.encodePacked(_selector, _encodedArgs)
            );
    }

    
    function __hasPendingMigrationOrReconfiguration(address _vaultProxy)
        private
        view
        returns (bool hasPendingMigrationOrReconfiguration)
    {
        return
            IDispatcher(getDispatcher()).hasMigrationRequest(_vaultProxy) ||
            IFundDeployer(getFundDeployer()).hasReconfigurationRequest(_vaultProxy);
    }

    //////////////////
    // PROTOCOL FEE //
    //////////////////

    
    
    function buyBackProtocolFeeShares(uint256 _sharesAmount) external {
        address vaultProxyCopy = vaultProxy;
        require(
            IVault(vaultProxyCopy).canManageAssets(__msgSender()),
            "buyBackProtocolFeeShares: Unauthorized"
        );

        uint256 gav = calcGav();

        IVault(vaultProxyCopy).buyBackProtocolFeeShares(
            _sharesAmount,
            __getBuybackValueInMln(vaultProxyCopy, _sharesAmount, gav),
            gav
        );
    }

    
    
    /// to be bought back immediately when collected
    function setAutoProtocolFeeSharesBuyback(bool _nextAutoProtocolFeeSharesBuyback)
        external
        onlyOwner
    {
        autoProtocolFeeSharesBuyback = _nextAutoProtocolFeeSharesBuyback;

        emit AutoProtocolFeeSharesBuybackSet(_nextAutoProtocolFeeSharesBuyback);
    }

    
    function __buyBackMaxProtocolFeeShares(address _vaultProxy, uint256 _gav) private {
        uint256 sharesAmount = ERC20(_vaultProxy).balanceOf(getProtocolFeeReserve());
        uint256 buybackValueInMln = __getBuybackValueInMln(_vaultProxy, sharesAmount, _gav);

        try
            IVault(_vaultProxy).buyBackProtocolFeeShares(sharesAmount, buybackValueInMln, _gav)
         {} catch (bytes memory reason) {
            emit BuyBackMaxProtocolFeeSharesFailed(reason, sharesAmount, buybackValueInMln, _gav);
        }
    }

    
    function __getBuybackValueInMln(
        address _vaultProxy,
        uint256 _sharesAmount,
        uint256 _gav
    ) private returns (uint256 buybackValueInMln_) {
        address denominationAssetCopy = getDenominationAsset();

        uint256 grossShareValue = __calcGrossShareValue(
            _gav,
            ERC20(_vaultProxy).totalSupply(),
            10**uint256(ERC20(denominationAssetCopy).decimals())
        );

        uint256 buybackValueInDenominationAsset = grossShareValue.mul(_sharesAmount).div(
            SHARES_UNIT
        );

        return
            IValueInterpreter(getValueInterpreter()).calcCanonicalAssetValue(
                denominationAssetCopy,
                buybackValueInDenominationAsset,
                getMlnToken()
            );
    }

    ////////////////////////////////
    // PERMISSIONED VAULT ACTIONS //
    ////////////////////////////////

    
    
    
    function permissionedVaultAction(IVault.VaultAction _action, bytes calldata _actionData)
        external
        override
    {
        __assertPermissionedVaultAction(msg.sender, _action);

        // Validate action as needed
        if (_action == IVault.VaultAction.RemoveTrackedAsset) {
            require(
                abi.decode(_actionData, (address)) != getDenominationAsset(),
                "permissionedVaultAction: Cannot untrack denomination asset"
            );
        }

        IVault(getVaultProxy()).receiveValidatedVaultAction(_action, _actionData);
    }

    
    /// Uses this pattern rather than multiple `require` statements to save on contract size.
    function __assertPermissionedVaultAction(address _caller, IVault.VaultAction _action)
        private
        view
    {
        bool validAction;
        if (permissionedVaultActionAllowed) {
            // Calls are roughly ordered by likely frequency
            if (_caller == getIntegrationManager()) {
                if (
                    _action == IVault.VaultAction.AddTrackedAsset ||
                    _action == IVault.VaultAction.RemoveTrackedAsset ||
                    _action == IVault.VaultAction.WithdrawAssetTo ||
                    _action == IVault.VaultAction.ApproveAssetSpender
                ) {
                    validAction = true;
                }
            } else if (_caller == getFeeManager()) {
                if (
                    _action == IVault.VaultAction.MintShares ||
                    _action == IVault.VaultAction.BurnShares ||
                    _action == IVault.VaultAction.TransferShares
                ) {
                    validAction = true;
                }
            } else if (_caller == getExternalPositionManager()) {
                if (
                    _action == IVault.VaultAction.CallOnExternalPosition ||
                    _action == IVault.VaultAction.AddExternalPosition ||
                    _action == IVault.VaultAction.RemoveExternalPosition
                ) {
                    validAction = true;
                }
            }
        }

        require(validAction, "__assertPermissionedVaultAction: Action not allowed");
    }

    ///////////////
    // LIFECYCLE //
    ///////////////

    // Ordered by execution in the lifecycle

    
    
    
    /// (buying or selling shares) by the same user
    
    /// No need to assert access because this is called atomically on deployment,
    /// and once it's called, it cannot be called again.
    function init(address _denominationAsset, uint256 _sharesActionTimelock) external override {
        require(getDenominationAsset() == address(0), "init: Already initialized");
        require(
            IValueInterpreter(getValueInterpreter()).isSupportedPrimitiveAsset(_denominationAsset),
            "init: Bad denomination asset"
        );

        denominationAsset = _denominationAsset;
        sharesActionTimelock = _sharesActionTimelock;
    }

    
    
    
    /// Called atomically with init(), but after ComptrollerProxy has been deployed.
    function setVaultProxy(address _vaultProxy) external override onlyFundDeployer {
        vaultProxy = _vaultProxy;

        emit VaultProxySet(_vaultProxy);
    }

    
    
    
    function activate(bool _isMigration) external override onlyFundDeployer {
        address vaultProxyCopy = getVaultProxy();

        if (_isMigration) {
            // Distribute any shares in the VaultProxy to the fund owner.
            // This is a mechanism to ensure that even in the edge case of a fund being unable
            // to payout fee shares owed during migration, these shares are not lost.
            uint256 sharesDue = ERC20(vaultProxyCopy).balanceOf(vaultProxyCopy);
            if (sharesDue > 0) {
                IVault(vaultProxyCopy).transferShares(
                    vaultProxyCopy,
                    IVault(vaultProxyCopy).getOwner(),
                    sharesDue
                );

                emit MigratedSharesDuePaid(sharesDue);
            }
        }

        IVault(vaultProxyCopy).addTrackedAsset(getDenominationAsset());

        // Activate extensions
        IExtension(getFeeManager()).activateForFund(_isMigration);
        IExtension(getPolicyManager()).activateForFund(_isMigration);
    }

    
    
    
    
    /// Uses the try/catch pattern throughout out of an abundance of caution for the function's success.
    /// All external calls must use limited forwarded gas to ensure that a migration to another release
    /// does not get bricked by logic that consumes too much gas for the block limit.
    function destructActivated(
        uint256 _deactivateFeeManagerGasLimit,
        uint256 _payProtocolFeeGasLimit
    ) external override onlyFundDeployer allowsPermissionedVaultAction {
        // Forwarding limited gas here also protects fee recipients by guaranteeing that fee payout logic
        // will run in the next function call
        try IVault(getVaultProxy()).payProtocolFee{gas: _payProtocolFeeGasLimit}()  {} catch {
            emit PayProtocolFeeDuringDestructFailed();
        }

        // Do not attempt to auto-buyback protocol fee shares in this case,
        // as the call is gav-dependent and can consume too much gas

        // Deactivate extensions only as-necessary

        // Pays out shares outstanding for fees
        try
            IExtension(getFeeManager()).deactivateForFund{gas: _deactivateFeeManagerGasLimit}()
         {} catch {
            emit DeactivateFeeManagerFailed();
        }

        __selfDestruct();
    }

    
    function destructUnactivated() external override onlyFundDeployer {
        __selfDestruct();
    }

    
    /// There should never be ETH in the ComptrollerLib,
    /// so no need to waste gas to get the fund owner
    function __selfDestruct() private {
        // Not necessary, but failsafe to protect the lib against selfdestruct
        require(!isLib, "__selfDestruct: Only delegate callable");

        selfdestruct(payable(address(this)));
    }

    ////////////////
    // ACCOUNTING //
    ////////////////

    
    
    function calcGav() public override returns (uint256 gav_) {
        address vaultProxyAddress = getVaultProxy();
        address[] memory assets = IVault(vaultProxyAddress).getTrackedAssets();
        address[] memory externalPositions = IVault(vaultProxyAddress)
            .getActiveExternalPositions();

        if (assets.length == 0 && externalPositions.length == 0) {
            return 0;
        }

        uint256[] memory balances = new uint256[](assets.length);
        for (uint256 i; i < assets.length; i++) {
            balances[i] = ERC20(assets[i]).balanceOf(vaultProxyAddress);
        }

        gav_ = IValueInterpreter(getValueInterpreter()).calcCanonicalAssetsTotalValue(
            assets,
            balances,
            getDenominationAsset()
        );

        if (externalPositions.length > 0) {
            for (uint256 i; i < externalPositions.length; i++) {
                uint256 externalPositionValue = __calcExternalPositionValue(externalPositions[i]);

                gav_ = gav_.add(externalPositionValue);
            }
        }

        return gav_;
    }

    
    
    
    function calcGrossShareValue() external override returns (uint256 grossShareValue_) {
        uint256 gav = calcGav();

        grossShareValue_ = __calcGrossShareValue(
            gav,
            ERC20(getVaultProxy()).totalSupply(),
            10**uint256(ERC20(getDenominationAsset()).decimals())
        );

        return grossShareValue_;
    }

    // @dev Helper for calculating a external position value. Prevents from stack too deep
    function __calcExternalPositionValue(address _externalPosition)
        private
        returns (uint256 value_)
    {
        (address[] memory managedAssets, uint256[] memory managedAmounts) = IExternalPosition(
            _externalPosition
        )
            .getManagedAssets();

        uint256 managedValue = IValueInterpreter(getValueInterpreter())
            .calcCanonicalAssetsTotalValue(managedAssets, managedAmounts, getDenominationAsset());

        (address[] memory debtAssets, uint256[] memory debtAmounts) = IExternalPosition(
            _externalPosition
        )
            .getDebtAssets();

        uint256 debtValue = IValueInterpreter(getValueInterpreter()).calcCanonicalAssetsTotalValue(
            debtAssets,
            debtAmounts,
            getDenominationAsset()
        );

        if (managedValue > debtValue) {
            value_ = managedValue.sub(debtValue);
        }

        return value_;
    }

    
    function __calcGrossShareValue(
        uint256 _gav,
        uint256 _sharesSupply,
        uint256 _denominationAssetUnit
    ) private pure returns (uint256 grossShareValue_) {
        if (_sharesSupply == 0) {
            return _denominationAssetUnit;
        }

        return _gav.mul(SHARES_UNIT).div(_sharesSupply);
    }

    ///////////////////
    // PARTICIPATION //
    ///////////////////

    // BUY SHARES

    
    
    
    
    
    
    /// limited to a list of trusted callers otherwise, in order to prevent a griefing attack
    /// where the caller buys shares for a _buyer, thereby resetting their lastSharesBought value.
    function buySharesOnBehalf(
        address _buyer,
        uint256 _investmentAmount,
        uint256 _minSharesQuantity
    ) external returns (uint256 sharesReceived_) {
        bool hasSharesActionTimelock = getSharesActionTimelock() > 0;
        address canonicalSender = __msgSender();

        require(
            !hasSharesActionTimelock ||
                IFundDeployer(getFundDeployer()).isAllowedBuySharesOnBehalfCaller(canonicalSender),
            "buySharesOnBehalf: Unauthorized"
        );

        return
            __buyShares(
                _buyer,
                _investmentAmount,
                _minSharesQuantity,
                hasSharesActionTimelock,
                canonicalSender
            );
    }

    
    
    /// with which to buy shares
    
    
    function buyShares(uint256 _investmentAmount, uint256 _minSharesQuantity)
        external
        returns (uint256 sharesReceived_)
    {
        bool hasSharesActionTimelock = getSharesActionTimelock() > 0;
        address canonicalSender = __msgSender();

        return
            __buyShares(
                canonicalSender,
                _investmentAmount,
                _minSharesQuantity,
                hasSharesActionTimelock,
                canonicalSender
            );
    }

    
    function __buyShares(
        address _buyer,
        uint256 _investmentAmount,
        uint256 _minSharesQuantity,
        bool _hasSharesActionTimelock,
        address _canonicalSender
    ) private locksReentrance allowsPermissionedVaultAction returns (uint256 sharesReceived_) {
        // Enforcing a _minSharesQuantity also validates `_investmentAmount > 0`
        // and guarantees the function cannot succeed while minting 0 shares
        require(_minSharesQuantity > 0, "__buyShares: _minSharesQuantity must be >0");

        address vaultProxyCopy = getVaultProxy();
        require(
            !_hasSharesActionTimelock || !__hasPendingMigrationOrReconfiguration(vaultProxyCopy),
            "__buyShares: Pending migration or reconfiguration"
        );

        uint256 gav = calcGav();

        // Gives Extensions a chance to run logic prior to the minting of bought shares.
        // Fees implementing this hook should be aware that
        // it might be the case that _investmentAmount != actualInvestmentAmount,
        // if the denomination asset charges a transfer fee, for example.
        __preBuySharesHook(_buyer, _investmentAmount, gav);

        // Pay the protocol fee after running other fees, but before minting new shares
        IVault(vaultProxyCopy).payProtocolFee();
        if (doesAutoProtocolFeeSharesBuyback()) {
            __buyBackMaxProtocolFeeShares(vaultProxyCopy, gav);
        }

        // Transfer the investment asset to the fund.
        // Does not follow the checks-effects-interactions pattern, but it is necessary to
        // do this delta balance calculation before calculating shares to mint.
        uint256 receivedInvestmentAmount = __transferFromWithReceivedAmount(
            getDenominationAsset(),
            _canonicalSender,
            vaultProxyCopy,
            _investmentAmount
        );

        // Calculate the amount of shares to issue with the investment amount
        uint256 sharePrice = __calcGrossShareValue(
            gav,
            ERC20(vaultProxyCopy).totalSupply(),
            10**uint256(ERC20(getDenominationAsset()).decimals())
        );
        uint256 sharesIssued = receivedInvestmentAmount.mul(SHARES_UNIT).div(sharePrice);

        // Mint shares to the buyer
        uint256 prevBuyerShares = ERC20(vaultProxyCopy).balanceOf(_buyer);
        IVault(vaultProxyCopy).mintShares(_buyer, sharesIssued);

        // Gives Extensions a chance to run logic after shares are issued
        __postBuySharesHook(_buyer, receivedInvestmentAmount, sharesIssued, gav);

        // The number of actual shares received may differ from shares issued due to
        // how the PostBuyShares hooks are invoked by Extensions (i.e., fees)
        sharesReceived_ = ERC20(vaultProxyCopy).balanceOf(_buyer).sub(prevBuyerShares);
        require(
            sharesReceived_ >= _minSharesQuantity,
            "__buyShares: Shares received < _minSharesQuantity"
        );

        if (_hasSharesActionTimelock) {
            acctToLastSharesBoughtTimestamp[_buyer] = block.timestamp;
        }

        emit SharesBought(_buyer, receivedInvestmentAmount, sharesIssued, sharesReceived_);

        return sharesReceived_;
    }

    
    function __preBuySharesHook(
        address _buyer,
        uint256 _investmentAmount,
        uint256 _gav
    ) private {
        IFeeManager(getFeeManager()).invokeHook(
            IFeeManager.FeeHook.PreBuyShares,
            abi.encode(_buyer, _investmentAmount),
            _gav
        );
    }

    
    /// This could be cleaned up so both Extensions take the same encoded args and handle GAV
    /// in the same way, but there is not the obvious need for gas savings of recycling
    /// the GAV value for the current policies as there is for the fees.
    function __postBuySharesHook(
        address _buyer,
        uint256 _investmentAmount,
        uint256 _sharesIssued,
        uint256 _preBuySharesGav
    ) private {
        uint256 gav = _preBuySharesGav.add(_investmentAmount);
        IFeeManager(getFeeManager()).invokeHook(
            IFeeManager.FeeHook.PostBuyShares,
            abi.encode(_buyer, _investmentAmount, _sharesIssued),
            gav
        );

        IPolicyManager(getPolicyManager()).validatePolicies(
            address(this),
            IPolicyManager.PolicyHook.PostBuyShares,
            abi.encode(_buyer, _investmentAmount, _sharesIssued, gav)
        );
    }

    
    function __transferFromWithReceivedAmount(
        address _asset,
        address _sender,
        address _recipient,
        uint256 _transferAmount
    ) private returns (uint256 receivedAmount_) {
        uint256 preTransferRecipientBalance = ERC20(_asset).balanceOf(_recipient);

        ERC20(_asset).safeTransferFrom(_sender, _recipient, _transferAmount);

        return ERC20(_asset).balanceOf(_recipient).sub(preTransferRecipientBalance);
    }

    // REDEEM SHARES

    
    
    
    
    
    
    
    /// _payoutAssetPercentages must total exactly 100%. In order to specify less and forgo the
    /// remaining gav owed on the redeemed shares, pass in address(0) with the percentage to forego.
    /// Unlike redeemSharesInKind(), this function allows policies to run and prevent redemption.
    function redeemSharesForSpecificAssets(
        address _recipient,
        uint256 _sharesQuantity,
        address[] calldata _payoutAssets,
        uint256[] calldata _payoutAssetPercentages
    ) external locksReentrance returns (uint256[] memory payoutAmounts_) {
        address canonicalSender = __msgSender();
        require(
            _payoutAssets.length == _payoutAssetPercentages.length,
            "redeemSharesForSpecificAssets: Unequal arrays"
        );
        require(
            _payoutAssets.isUniqueSet(),
            "redeemSharesForSpecificAssets: Duplicate payout asset"
        );

        uint256 gav = calcGav();

        IVault vaultProxyContract = IVault(getVaultProxy());
        (uint256 sharesToRedeem, uint256 sharesSupply) = __redeemSharesSetup(
            vaultProxyContract,
            canonicalSender,
            _sharesQuantity,
            true,
            gav
        );

        payoutAmounts_ = __payoutSpecifiedAssetPercentages(
            vaultProxyContract,
            _recipient,
            _payoutAssets,
            _payoutAssetPercentages,
            gav.mul(sharesToRedeem).div(sharesSupply)
        );

        // Run post-redemption in order to have access to the payoutAmounts
        __postRedeemSharesForSpecificAssetsHook(
            canonicalSender,
            _recipient,
            sharesToRedeem,
            _payoutAssets,
            payoutAmounts_,
            gav
        );

        emit SharesRedeemed(
            canonicalSender,
            _recipient,
            sharesToRedeem,
            _payoutAssets,
            payoutAmounts_
        );

        return payoutAmounts_;
    }

    
    /// for a proportionate slice of the vault's assets
    
    
    
    
    
    
    
    /// Any claim to passed _assetsToSkip will be forfeited entirely. This should generally
    /// only be exercised if a bad asset is causing redemption to fail.
    /// This function should never fail without a way to bypass the failure, which is assured
    /// through two mechanisms:
    /// 1. The FeeManager is called with the try/catch pattern to assure that calls to it
    /// can never block redemption.
    /// 2. If a token fails upon transfer(), that token can be skipped (and its balance forfeited)
    /// by explicitly specifying _assetsToSkip.
    /// Because of these assurances, shares should always be redeemable, with the exception
    /// of the timelock period on shares actions that must be respected.
    function redeemSharesInKind(
        address _recipient,
        uint256 _sharesQuantity,
        address[] calldata _additionalAssets,
        address[] calldata _assetsToSkip
    )
        external
        locksReentrance
        returns (address[] memory payoutAssets_, uint256[] memory payoutAmounts_)
    {
        address canonicalSender = __msgSender();
        require(
            _additionalAssets.isUniqueSet(),
            "redeemSharesInKind: _additionalAssets contains duplicates"
        );
        require(
            _assetsToSkip.isUniqueSet(),
            "redeemSharesInKind: _assetsToSkip contains duplicates"
        );

        // Parse the payout assets given optional params to add or skip assets.
        // Note that there is no validation that the _additionalAssets are known assets to
        // the protocol. This means that the redeemer could specify a malicious asset,
        // but since all state-changing, user-callable functions on this contract share the
        // non-reentrant modifier, there is nowhere to perform a reentrancy attack.
        payoutAssets_ = __parseRedemptionPayoutAssets(
            IVault(vaultProxy).getTrackedAssets(),
            _additionalAssets,
            _assetsToSkip
        );

        // If protocol fee shares will be auto-bought back, attempt to calculate GAV to pass into fees,
        // as we will require GAV later during the buyback.
        uint256 gavOrZero;
        if (doesAutoProtocolFeeSharesBuyback()) {
            // Since GAV calculation can fail with a revering price or a no-longer-supported asset,
            // we must try/catch GAV calculation to ensure that in-kind redemption can still succeed
            try this.calcGav() returns (uint256 gav) {
                gavOrZero = gav;
            } catch {
                emit RedeemSharesInKindCalcGavFailed();
            }
        }

        (uint256 sharesToRedeem, uint256 sharesSupply) = __redeemSharesSetup(
            IVault(vaultProxy),
            canonicalSender,
            _sharesQuantity,
            false,
            gavOrZero
        );

        // Calculate and transfer payout asset amounts due to _recipient
        payoutAmounts_ = new uint256[](payoutAssets_.length);
        for (uint256 i; i < payoutAssets_.length; i++) {
            payoutAmounts_[i] = ERC20(payoutAssets_[i])
                .balanceOf(vaultProxy)
                .mul(sharesToRedeem)
                .div(sharesSupply);

            // Transfer payout asset to _recipient
            if (payoutAmounts_[i] > 0) {
                IVault(vaultProxy).withdrawAssetTo(
                    payoutAssets_[i],
                    _recipient,
                    payoutAmounts_[i]
                );
            }
        }

        emit SharesRedeemed(
            canonicalSender,
            _recipient,
            sharesToRedeem,
            payoutAssets_,
            payoutAmounts_
        );

        return (payoutAssets_, payoutAmounts_);
    }

    
    /// additional assets and assets to skip. _assetsToSkip ignores _additionalAssets.
    /// All input arrays are assumed to be unique.
    function __parseRedemptionPayoutAssets(
        address[] memory _trackedAssets,
        address[] memory _additionalAssets,
        address[] memory _assetsToSkip
    ) private pure returns (address[] memory payoutAssets_) {
        address[] memory trackedAssetsToPayout = _trackedAssets.removeItems(_assetsToSkip);
        if (_additionalAssets.length == 0) {
            return trackedAssetsToPayout;
        }

        // Add additional assets. Duplicates of trackedAssets are ignored.
        bool[] memory indexesToAdd = new bool[](_additionalAssets.length);
        uint256 additionalItemsCount;
        for (uint256 i; i < _additionalAssets.length; i++) {
            if (!trackedAssetsToPayout.contains(_additionalAssets[i])) {
                indexesToAdd[i] = true;
                additionalItemsCount++;
            }
        }
        if (additionalItemsCount == 0) {
            return trackedAssetsToPayout;
        }

        payoutAssets_ = new address[](trackedAssetsToPayout.length.add(additionalItemsCount));
        for (uint256 i; i < trackedAssetsToPayout.length; i++) {
            payoutAssets_[i] = trackedAssetsToPayout[i];
        }
        uint256 payoutAssetsIndex = trackedAssetsToPayout.length;
        for (uint256 i; i < _additionalAssets.length; i++) {
            if (indexesToAdd[i]) {
                payoutAssets_[payoutAssetsIndex] = _additionalAssets[i];
                payoutAssetsIndex++;
            }
        }

        return payoutAssets_;
    }

    
    function __payoutSpecifiedAssetPercentages(
        IVault vaultProxyContract,
        address _recipient,
        address[] calldata _payoutAssets,
        uint256[] calldata _payoutAssetPercentages,
        uint256 _owedGav
    ) private returns (uint256[] memory payoutAmounts_) {
        address denominationAssetCopy = getDenominationAsset();
        uint256 percentagesTotal;
        payoutAmounts_ = new uint256[](_payoutAssets.length);
        for (uint256 i; i < _payoutAssets.length; i++) {
            percentagesTotal = percentagesTotal.add(_payoutAssetPercentages[i]);

            // Used to explicitly specify less than 100% in total _payoutAssetPercentages
            if (_payoutAssets[i] == SPECIFIC_ASSET_REDEMPTION_DUMMY_FORFEIT_ADDRESS) {
                continue;
            }

            payoutAmounts_[i] = IValueInterpreter(getValueInterpreter()).calcCanonicalAssetValue(
                denominationAssetCopy,
                _owedGav.mul(_payoutAssetPercentages[i]).div(ONE_HUNDRED_PERCENT),
                _payoutAssets[i]
            );
            // Guards against corner case of primitive-to-derivative asset conversion that floors to 0,
            // or redeeming a very low shares amount and/or percentage where asset value owed is 0
            require(
                payoutAmounts_[i] > 0,
                "__payoutSpecifiedAssetPercentages: Zero amount for asset"
            );

            vaultProxyContract.withdrawAssetTo(_payoutAssets[i], _recipient, payoutAmounts_[i]);
        }

        require(
            percentagesTotal == ONE_HUNDRED_PERCENT,
            "__payoutSpecifiedAssetPercentages: Percents must total 100%"
        );

        return payoutAmounts_;
    }

    
    /// Policy validation is not currently allowed on redemption, to ensure continuous redeemability.
    function __preRedeemSharesHook(
        address _redeemer,
        uint256 _sharesToRedeem,
        bool _forSpecifiedAssets,
        uint256 _gavIfCalculated
    ) private allowsPermissionedVaultAction {
        try
            IFeeManager(getFeeManager()).invokeHook(
                IFeeManager.FeeHook.PreRedeemShares,
                abi.encode(_redeemer, _sharesToRedeem, _forSpecifiedAssets),
                _gavIfCalculated
            )
         {} catch (bytes memory reason) {
            emit PreRedeemSharesHookFailed(reason, _redeemer, _sharesToRedeem);
        }
    }

    
    /// Avoids stack-too-deep error.
    function __postRedeemSharesForSpecificAssetsHook(
        address _redeemer,
        address _recipient,
        uint256 _sharesToRedeemPostFees,
        address[] memory _assets,
        uint256[] memory _assetAmounts,
        uint256 _gavPreRedeem
    ) private {
        IPolicyManager(getPolicyManager()).validatePolicies(
            address(this),
            IPolicyManager.PolicyHook.RedeemSharesForSpecificAssets,
            abi.encode(
                _redeemer,
                _recipient,
                _sharesToRedeemPostFees,
                _assets,
                _assetAmounts,
                _gavPreRedeem
            )
        );
    }

    
    function __redeemSharesSetup(
        IVault vaultProxyContract,
        address _redeemer,
        uint256 _sharesQuantityInput,
        bool _forSpecifiedAssets,
        uint256 _gavIfCalculated
    ) private returns (uint256 sharesToRedeem_, uint256 sharesSupply_) {
        __assertSharesActionNotTimelocked(address(vaultProxyContract), _redeemer);

        ERC20 sharesContract = ERC20(address(vaultProxyContract));

        uint256 preFeesRedeemerSharesBalance = sharesContract.balanceOf(_redeemer);

        if (_sharesQuantityInput == type(uint256).max) {
            sharesToRedeem_ = preFeesRedeemerSharesBalance;
        } else {
            sharesToRedeem_ = _sharesQuantityInput;
        }
        require(sharesToRedeem_ > 0, "__redeemSharesSetup: No shares to redeem");

        __preRedeemSharesHook(_redeemer, sharesToRedeem_, _forSpecifiedAssets, _gavIfCalculated);

        // Update the redemption amount if fees were charged (or accrued) to the redeemer
        uint256 postFeesRedeemerSharesBalance = sharesContract.balanceOf(_redeemer);
        if (_sharesQuantityInput == type(uint256).max) {
            sharesToRedeem_ = postFeesRedeemerSharesBalance;
        } else if (postFeesRedeemerSharesBalance < preFeesRedeemerSharesBalance) {
            sharesToRedeem_ = sharesToRedeem_.sub(
                preFeesRedeemerSharesBalance.sub(postFeesRedeemerSharesBalance)
            );
        }

        // Pay the protocol fee after running other fees, but before burning shares
        vaultProxyContract.payProtocolFee();

        if (_gavIfCalculated > 0 && doesAutoProtocolFeeSharesBuyback()) {
            __buyBackMaxProtocolFeeShares(address(vaultProxyContract), _gavIfCalculated);
        }

        // Destroy the shares after getting the shares supply
        sharesSupply_ = sharesContract.totalSupply();
        vaultProxyContract.burnShares(_redeemer, sharesToRedeem_);

        return (sharesToRedeem_, sharesSupply_);
    }

    // TRANSFER SHARES

    
    
    
    
    function preTransferSharesHook(
        address _sender,
        address _recipient,
        uint256 _amount
    ) external override {
        address vaultProxyCopy = getVaultProxy();
        require(msg.sender == vaultProxyCopy, "preTransferSharesHook: Only VaultProxy callable");
        __assertSharesActionNotTimelocked(vaultProxyCopy, _sender);

        IPolicyManager(getPolicyManager()).validatePolicies(
            address(this),
            IPolicyManager.PolicyHook.PreTransferShares,
            abi.encode(_sender, _recipient, _amount)
        );
    }

    
    
    
    function preTransferSharesHookFreelyTransferable(address _sender) external view override {
        __assertSharesActionNotTimelocked(getVaultProxy(), _sender);
    }

    /////////////////
    // GAS RELAYER //
    /////////////////

    
    function deployGasRelayPaymaster() external onlyOwnerNotRelayable {
        require(
            getGasRelayPaymaster() == address(0),
            "deployGasRelayPaymaster: Paymaster already deployed"
        );

        bytes memory constructData = abi.encodeWithSignature("init(address)", getVaultProxy());
        address paymaster = IBeaconProxyFactory(getGasRelayPaymasterFactory()).deployProxy(
            constructData
        );

        __setGasRelayPaymaster(paymaster);

        __depositToGasRelayPaymaster(paymaster);
    }

    
    function depositToGasRelayPaymaster() external onlyOwner {
        __depositToGasRelayPaymaster(getGasRelayPaymaster());
    }

    
    
    function pullWethForGasRelayer(uint256 _amount) external override onlyGasRelayPaymaster {
        IVault(getVaultProxy()).withdrawAssetTo(getWethToken(), getGasRelayPaymaster(), _amount);
    }

    
    
    function setGasRelayPaymaster(address _nextGasRelayPaymaster)
        external
        override
        onlyFundDeployer
    {
        __setGasRelayPaymaster(_nextGasRelayPaymaster);
    }

    
    /// and disabling gas relaying
    function shutdownGasRelayPaymaster() external onlyOwnerNotRelayable {
        IGasRelayPaymaster(gasRelayPaymaster).withdrawBalance();

        IVault(vaultProxy).addTrackedAsset(getWethToken());

        delete gasRelayPaymaster;

        emit GasRelayPaymasterSet(address(0));
    }

    
    function __depositToGasRelayPaymaster(address _paymaster) private {
        IGasRelayPaymaster(_paymaster).deposit();
    }

    
    function __setGasRelayPaymaster(address _nextGasRelayPaymaster) private {
        gasRelayPaymaster = _nextGasRelayPaymaster;

        emit GasRelayPaymasterSet(_nextGasRelayPaymaster);
    }

    ///////////////////
    // STATE GETTERS //
    ///////////////////

    // LIB IMMUTABLES

    
    
    function getDispatcher() public view returns (address dispatcher_) {
        return DISPATCHER;
    }

    
    
    function getExternalPositionManager()
        public
        view
        override
        returns (address externalPositionManager_)
    {
        return EXTERNAL_POSITION_MANAGER;
    }

    
    
    function getFeeManager() public view override returns (address feeManager_) {
        return FEE_MANAGER;
    }

    
    
    function getFundDeployer() public view override returns (address fundDeployer_) {
        return FUND_DEPLOYER;
    }

    
    
    function getIntegrationManager() public view override returns (address integrationManager_) {
        return INTEGRATION_MANAGER;
    }

    
    
    function getMlnToken() public view returns (address mlnToken_) {
        return MLN_TOKEN;
    }

    
    
    function getPolicyManager() public view override returns (address policyManager_) {
        return POLICY_MANAGER;
    }

    
    
    function getProtocolFeeReserve() public view returns (address protocolFeeReserve_) {
        return PROTOCOL_FEE_RESERVE;
    }

    
    
    function getValueInterpreter() public view returns (address valueInterpreter_) {
        return VALUE_INTERPRETER;
    }

    
    
    function getWethToken() public view returns (address wethToken_) {
        return WETH_TOKEN;
    }

    // PROXY STORAGE

    
    /// while buying or redeeming shares
    
    function doesAutoProtocolFeeSharesBuyback() public view returns (bool doesAutoBuyback_) {
        return autoProtocolFeeSharesBuyback;
    }

    
    
    function getDenominationAsset() public view override returns (address denominationAsset_) {
        return denominationAsset;
    }

    
    
    function getGasRelayPaymaster() public view override returns (address gasRelayPaymaster_) {
        return gasRelayPaymaster;
    }

    
    
    
    function getLastSharesBoughtTimestampForAccount(address _who)
        public
        view
        returns (uint256 lastSharesBoughtTimestamp_)
    {
        return acctToLastSharesBoughtTimestamp[_who];
    }

    
    
    function getSharesActionTimelock() public view returns (uint256 sharesActionTimelock_) {
        return sharesActionTimelock;
    }

    
    
    function getVaultProxy() public view override returns (address vaultProxy_) {
        return vaultProxy;
    }
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;







interface IVault is IMigratableVault, IFreelyTransferableSharesVault, IExternalPositionVault {
    enum VaultAction {
        None,
        // Shares management
        BurnShares,
        MintShares,
        TransferShares,
        // Asset management
        AddTrackedAsset,
        ApproveAssetSpender,
        RemoveTrackedAsset,
        WithdrawAssetTo,
        // External position management
        AddExternalPosition,
        CallOnExternalPosition,
        RemoveExternalPosition
    }

    function addTrackedAsset(address) external;

    function burnShares(address, uint256) external;

    function buyBackProtocolFeeShares(
        uint256,
        uint256,
        uint256
    ) external;

    function callOnContract(address, bytes calldata) external returns (bytes memory);

    function canManageAssets(address) external view returns (bool);

    function canRelayCalls(address) external view returns (bool);

    function getAccessor() external view returns (address);

    function getOwner() external view returns (address);

    function getActiveExternalPositions() external view returns (address[] memory);

    function getTrackedAssets() external view returns (address[] memory);

    function isActiveExternalPosition(address) external view returns (bool);

    function isTrackedAsset(address) external view returns (bool);

    function mintShares(address, uint256) external;

    function payProtocolFee() external;

    function receiveValidatedVaultAction(VaultAction, bytes calldata) external;

    function setAccessorForFundReconfiguration(address) external;

    function setSymbol(string calldata) external;

    function transferShares(
        address,
        address,
        uint256
    ) external;

    function withdrawAssetTo(
        address,
        address,
        uint256
    ) external;
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;




interface IExtension {
    function activateForFund(bool _isMigration) external;

    function deactivateForFund() external;

    function receiveCallFromComptroller(
        address _caller,
        uint256 _actionId,
        bytes calldata _callArgs
    ) external;

    function setConfigForFund(
        address _comptrollerProxy,
        address _vaultProxy,
        bytes calldata _configData
    ) external;
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;





interface IFeeManager {
    // No fees for the current release are implemented post-redeemShares
    enum FeeHook {Continuous, PreBuyShares, PostBuyShares, PreRedeemShares}
    enum SettlementType {None, Direct, Mint, Burn, MintSharesOutstanding, BurnSharesOutstanding}

    function invokeHook(
        FeeHook,
        bytes calldata,
        uint256
    ) external;
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;





interface IPolicyManager {
    // When updating PolicyHook, also update these functions in PolicyManager:
    // 1. __getAllPolicyHooks()
    // 2. __policyHookRestrictsCurrentInvestorActions()
    enum PolicyHook {
        PostBuyShares,
        PostCallOnIntegration,
        PreTransferShares,
        RedeemSharesForSpecificAssets,
        AddTrackedAssets,
        RemoveTrackedAssets,
        CreateExternalPosition,
        PostCallOnExternalPosition,
        RemoveExternalPosition,
        ReactivateExternalPosition
    }

    function validatePolicies(
        address,
        PolicyHook,
        bytes calldata
    ) external;
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;






interface IGasRelayPaymaster is IGsnPaymaster {
    function deposit() external;

    function withdrawBalance() external;
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;




interface IValueInterpreter {
    function calcCanonicalAssetValue(
        address,
        uint256,
        address
    ) external returns (uint256);

    function calcCanonicalAssetsTotalValue(
        address[] calldata,
        uint256[] calldata,
        address
    ) external returns (uint256);

    function isSupportedAsset(address) external view returns (bool);

    function isSupportedDerivativeAsset(address) external view returns (bool);

    function isSupportedPrimitiveAsset(address) external view returns (bool);
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;



interface IGsnForwarder {
    struct ForwardRequest {
        address from;
        address to;
        uint256 value;
        uint256 gas;
        uint256 nonce;
        bytes data;
        uint256 validUntil;
    }
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;






interface IGsnTypes {
    struct RelayData {
        uint256 gasPrice;
        uint256 pctRelayFee;
        uint256 baseRelayFee;
        address relayWorker;
        address paymaster;
        address forwarder;
        bytes paymasterData;
        uint256 clientId;
    }

    struct RelayRequest {
        IGsnForwarder.ForwardRequest request;
        RelayData relayData;
    }
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;



interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;








contract DepositWrapper is AssetHelpers {
    address private immutable WETH_TOKEN;

    constructor(address _weth) public {
        WETH_TOKEN = _weth;
    }

    
    /// to unwrap into ETH and refund
    receive() external payable {}

    // EXTERNAL FUNCTIONS

    
    
    
    
    
    /// for the given _exchange
    
    /// to the denomination asset
    
    /// to receive in the trade for investment (not necessary for WETH)
    
    
    /// does not perform as expected (low incoming asset amount, blend of assets, etc).
    /// If the fund's denomination asset is WETH, _exchange, _exchangeApproveTarget, _exchangeData,
    /// and _minInvestmentAmount will be ignored.
    function exchangeEthAndBuyShares(
        address _comptrollerProxy,
        address _denominationAsset,
        uint256 _minSharesQuantity,
        address _exchange,
        address _exchangeApproveTarget,
        bytes calldata _exchangeData,
        uint256 _minInvestmentAmount
    ) external payable returns (uint256 sharesReceived_) {
        // Wrap ETH into WETH
        IWETH(payable(getWethToken())).deposit{value: msg.value}();

        // If denominationAsset is WETH, can just buy shares directly
        if (_denominationAsset == getWethToken()) {
            __approveAssetMaxAsNeeded(getWethToken(), _comptrollerProxy, msg.value);

            return __buyShares(_comptrollerProxy, msg.sender, msg.value, _minSharesQuantity);
        }

        // Exchange ETH to the fund's denomination asset
        __approveAssetMaxAsNeeded(getWethToken(), _exchangeApproveTarget, msg.value);
        (bool success, bytes memory returnData) = _exchange.call(_exchangeData);
        require(success, string(returnData));

        // Confirm the amount received in the exchange is above the min acceptable amount
        uint256 investmentAmount = ERC20(_denominationAsset).balanceOf(address(this));
        require(
            investmentAmount >= _minInvestmentAmount,
            "exchangeAndBuyShares: _minInvestmentAmount not met"
        );

        // Give the ComptrollerProxy max allowance for its denomination asset as necessary
        __approveAssetMaxAsNeeded(_denominationAsset, _comptrollerProxy, investmentAmount);

        // Buy fund shares
        sharesReceived_ = __buyShares(
            _comptrollerProxy,
            msg.sender,
            investmentAmount,
            _minSharesQuantity
        );

        // Unwrap and refund any remaining WETH not used in the exchange
        uint256 remainingWeth = ERC20(getWethToken()).balanceOf(address(this));
        if (remainingWeth > 0) {
            IWETH(payable(getWethToken())).withdraw(remainingWeth);
            (success, returnData) = msg.sender.call{value: remainingWeth}("");
            require(success, string(returnData));
        }

        return sharesReceived_;
    }

    // PRIVATE FUNCTIONS

    
    function __buyShares(
        address _comptrollerProxy,
        address _buyer,
        uint256 _investmentAmount,
        uint256 _minSharesQuantity
    ) private returns (uint256 sharesReceived_) {
        ComptrollerLib comptrollerProxyContract = ComptrollerLib(_comptrollerProxy);
        sharesReceived_ = comptrollerProxyContract.buySharesOnBehalf(
            _buyer,
            _investmentAmount,
            _minSharesQuantity
        );

        return sharesReceived_;
    }

    ///////////////////
    // STATE GETTERS //
    ///////////////////

    
    
    function getWethToken() public view returns (address wethToken_) {
        return WETH_TOKEN;
    }
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;




library AddressArrayLib {
    /////////////
    // STORAGE //
    /////////////

    
    function removeStorageItem(address[] storage _self, address _itemToRemove)
        internal
        returns (bool removed_)
    {
        uint256 itemCount = _self.length;
        for (uint256 i; i < itemCount; i++) {
            if (_self[i] == _itemToRemove) {
                if (i < itemCount - 1) {
                    _self[i] = _self[itemCount - 1];
                }
                _self.pop();
                removed_ = true;
                break;
            }
        }

        return removed_;
    }

    ////////////
    // MEMORY //
    ////////////

    
    function addItem(address[] memory _self, address _itemToAdd)
        internal
        pure
        returns (address[] memory nextArray_)
    {
        nextArray_ = new address[](_self.length + 1);
        for (uint256 i; i < _self.length; i++) {
            nextArray_[i] = _self[i];
        }
        nextArray_[_self.length] = _itemToAdd;

        return nextArray_;
    }

    
    function addUniqueItem(address[] memory _self, address _itemToAdd)
        internal
        pure
        returns (address[] memory nextArray_)
    {
        if (contains(_self, _itemToAdd)) {
            return _self;
        }

        return addItem(_self, _itemToAdd);
    }

    
    function contains(address[] memory _self, address _target)
        internal
        pure
        returns (bool doesContain_)
    {
        for (uint256 i; i < _self.length; i++) {
            if (_target == _self[i]) {
                return true;
            }
        }
        return false;
    }

    
    /// Does not consider uniqueness of either array, only relative uniqueness.
    /// Preserves ordering.
    function mergeArray(address[] memory _self, address[] memory _arrayToMerge)
        internal
        pure
        returns (address[] memory nextArray_)
    {
        uint256 newUniqueItemCount;
        for (uint256 i; i < _arrayToMerge.length; i++) {
            if (!contains(_self, _arrayToMerge[i])) {
                newUniqueItemCount++;
            }
        }

        if (newUniqueItemCount == 0) {
            return _self;
        }

        nextArray_ = new address[](_self.length + newUniqueItemCount);
        for (uint256 i; i < _self.length; i++) {
            nextArray_[i] = _self[i];
        }
        uint256 nextArrayIndex = _self.length;
        for (uint256 i; i < _arrayToMerge.length; i++) {
            if (!contains(_self, _arrayToMerge[i])) {
                nextArray_[nextArrayIndex] = _arrayToMerge[i];
                nextArrayIndex++;
            }
        }

        return nextArray_;
    }

    
    /// Does not assert length > 0.
    function isUniqueSet(address[] memory _self) internal pure returns (bool isUnique_) {
        if (_self.length <= 1) {
            return true;
        }

        uint256 arrayLength = _self.length;
        for (uint256 i; i < arrayLength; i++) {
            for (uint256 j = i + 1; j < arrayLength; j++) {
                if (_self[i] == _self[j]) {
                    return false;
                }
            }
        }

        return true;
    }

    
    /// Does not assert uniqueness of either array.
    function removeItems(address[] memory _self, address[] memory _itemsToRemove)
        internal
        pure
        returns (address[] memory nextArray_)
    {
        if (_itemsToRemove.length == 0) {
            return _self;
        }

        bool[] memory indexesToRemove = new bool[](_self.length);
        uint256 remainingItemsCount = _self.length;
        for (uint256 i; i < _self.length; i++) {
            if (contains(_itemsToRemove, _self[i])) {
                indexesToRemove[i] = true;
                remainingItemsCount--;
            }
        }

        if (remainingItemsCount == _self.length) {
            nextArray_ = _self;
        } else if (remainingItemsCount > 0) {
            nextArray_ = new address[](remainingItemsCount);
            uint256 nextArrayIndex;
            for (uint256 i; i < _self.length; i++) {
                if (!indexesToRemove[i]) {
                    nextArray_[nextArrayIndex] = _self[i];
                    nextArrayIndex++;
                }
            }
        }

        return nextArray_;
    }
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/



pragma solidity 0.6.12;



interface IBeaconProxyFactory is IBeacon {
    function deployProxy(bytes memory _constructData) external returns (address proxy_);

    function setCanonicalLib(address _canonicalLib) external;
}