// SPDX-License-Identifier: AGPL-3.0-or-later

/**
 *Submitted for verification at Etherscan.io on 2022-04-04
*/

// 
// Copyright (C) 2018-2020 Maker Ecosystem Growth Holdings, INC.
pragma solidity ^0.8.4;

interface IPriceCalculator {
    // 1st arg: initial price [wad]
    // 2nd arg: seconds since auction start [seconds]
    // returns: current auction price [wad]
    function price(uint256, uint256) external view returns (uint256);
}
interface ICodex {
    function init(address vault) external;

    function setParam(bytes32 param, uint256 data) external;

    function setParam(
        address,
        bytes32,
        uint256
    ) external;

    function credit(address) external view returns (uint256);

    function unbackedDebt(address) external view returns (uint256);

    function balances(
        address,
        uint256,
        address
    ) external view returns (uint256);

    function vaults(address vault)
        external
        view
        returns (
            uint256 totalNormalDebt,
            uint256 rate,
            uint256 debtCeiling,
            uint256 debtFloor
        );

    function positions(
        address vault,
        uint256 tokenId,
        address position
    ) external view returns (uint256 collateral, uint256 normalDebt);

    function globalDebt() external view returns (uint256);

    function globalUnbackedDebt() external view returns (uint256);

    function globalDebtCeiling() external view returns (uint256);

    function delegates(address, address) external view returns (uint256);

    function grantDelegate(address) external;

    function revokeDelegate(address) external;

    function modifyBalance(
        address,
        uint256,
        address,
        int256
    ) external;

    function transferBalance(
        address vault,
        uint256 tokenId,
        address src,
        address dst,
        uint256 amount
    ) external;

    function transferCredit(
        address src,
        address dst,
        uint256 amount
    ) external;

    function modifyCollateralAndDebt(
        address vault,
        uint256 tokenId,
        address user,
        address collateralizer,
        address debtor,
        int256 deltaCollateral,
        int256 deltaNormalDebt
    ) external;

    function transferCollateralAndDebt(
        address vault,
        uint256 tokenId,
        address src,
        address dst,
        int256 deltaCollateral,
        int256 deltaNormalDebt
    ) external;

    function confiscateCollateralAndDebt(
        address vault,
        uint256 tokenId,
        address user,
        address collateralizer,
        address debtor,
        int256 deltaCollateral,
        int256 deltaNormalDebt
    ) external;

    function settleUnbackedDebt(uint256 debt) external;

    function createUnbackedDebt(
        address debtor,
        address creditor,
        uint256 debt
    ) external;

    function modifyRate(
        address vault,
        address creditor,
        int256 rate
    ) external;

    function lock() external;
}
interface IPriceFeed {
    function peek() external returns (bytes32, bool);

    function read() external view returns (bytes32);
}

interface ICollybus {
    function vaults(address) external view returns (uint128, uint128);

    function spots(address) external view returns (uint256);

    function rates(uint256) external view returns (uint256);

    function rateIds(address, uint256) external view returns (uint256);

    function redemptionPrice() external view returns (uint256);

    function live() external view returns (uint256);

    function setParam(bytes32 param, uint256 data) external;

    function setParam(
        address vault,
        bytes32 param,
        uint128 data
    ) external;

    function setParam(
        address vault,
        uint256 tokenId,
        bytes32 param,
        uint256 data
    ) external;

    function updateDiscountRate(uint256 rateId, uint256 rate) external;

    function updateSpot(address token, uint256 spot) external;

    function read(
        address vault,
        address underlier,
        uint256 tokenId,
        uint256 maturity,
        bool net
    ) external view returns (uint256 price);

    function lock() external;
}
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)



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



interface IDebtAuction {
    function auctions(uint256)
        external
        view
        returns (
            uint256,
            uint256,
            address,
            uint48,
            uint48
        );

    function codex() external view returns (ICodex);

    function token() external view returns (IERC20);

    function minBidBump() external view returns (uint256);

    function tokenToSellBump() external view returns (uint256);

    function bidDuration() external view returns (uint48);

    function auctionDuration() external view returns (uint48);

    function auctionCounter() external view returns (uint256);

    function live() external view returns (uint256);

    function aer() external view returns (address);

    function setParam(bytes32 param, uint256 data) external;

    function startAuction(
        address recipient,
        uint256 tokensToSell,
        uint256 bid
    ) external returns (uint256 id);

    function redoAuction(uint256 id) external;

    function submitBid(
        uint256 id,
        uint256 tokensToSell,
        uint256 bid
    ) external;

    function closeAuction(uint256 id) external;

    function lock() external;

    function cancelAuction(uint256 id) external;
}
interface ISurplusAuction {
    function auctions(uint256)
        external
        view
        returns (
            uint256,
            uint256,
            address,
            uint48,
            uint48
        );

    function codex() external view returns (ICodex);

    function token() external view returns (IERC20);

    function minBidBump() external view returns (uint256);

    function bidDuration() external view returns (uint48);

    function auctionDuration() external view returns (uint48);

    function auctionCounter() external view returns (uint256);

    function live() external view returns (uint256);

    function setParam(bytes32 param, uint256 data) external;

    function startAuction(uint256 creditToSell, uint256 bid) external returns (uint256 id);

    function redoAuction(uint256 id) external;

    function submitBid(
        uint256 id,
        uint256 creditToSell,
        uint256 bid
    ) external;

    function closeAuction(uint256 id) external;

    function lock(uint256 credit) external;

    function cancelAuction(uint256 id) external;
}

interface IAer {
    function codex() external view returns (ICodex);

    function surplusAuction() external view returns (ISurplusAuction);

    function debtAuction() external view returns (IDebtAuction);

    function debtQueue(uint256) external view returns (uint256);

    function queuedDebt() external view returns (uint256);

    function debtOnAuction() external view returns (uint256);

    function auctionDelay() external view returns (uint256);

    function debtAuctionSellSize() external view returns (uint256);

    function debtAuctionBidSize() external view returns (uint256);

    function surplusAuctionSellSize() external view returns (uint256);

    function surplusBuffer() external view returns (uint256);

    function live() external view returns (uint256);

    function setParam(bytes32 param, uint256 data) external;

    function setParam(bytes32 param, address data) external;

    function queueDebt(uint256 debt) external;

    function unqueueDebt(uint256 queuedAt) external;

    function settleDebtWithSurplus(uint256 debt) external;

    function settleAuctionedDebt(uint256 debt) external;

    function startDebtAuction() external returns (uint256 auctionId);

    function startSurplusAuction() external returns (uint256 auctionId);

    function transferCredit(address to, uint256 credit) external;

    function lock() external;
}
interface ILimes {
    function codex() external view returns (ICodex);

    function aer() external view returns (IAer);

    function vaults(address)
        external
        view
        returns (
            address,
            uint256,
            uint256,
            uint256
        );

    function live() external view returns (uint256);

    function globalMaxDebtOnAuction() external view returns (uint256);

    function globalDebtOnAuction() external view returns (uint256);

    function setParam(bytes32 param, address data) external;

    function setParam(bytes32 param, uint256 data) external;

    function setParam(
        address vault,
        bytes32 param,
        uint256 data
    ) external;

    function setParam(
        address vault,
        bytes32 param,
        address collateralAuction
    ) external;

    function liquidationPenalty(address vault) external view returns (uint256);

    function liquidate(
        address vault,
        uint256 tokenId,
        address position,
        address keeper
    ) external returns (uint256 auctionId);

    function liquidated(
        address vault,
        uint256 tokenId,
        uint256 debt
    ) external;

    function lock() external;
}

interface INoLossCollateralAuction {
    function vaults(address)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            ICollybus,
            IPriceCalculator
        );

    function codex() external view returns (ICodex);

    function limes() external view returns (ILimes);

    function aer() external view returns (IAer);

    function feeTip() external view returns (uint64);

    function flatTip() external view returns (uint192);

    function auctionCounter() external view returns (uint256);

    function activeAuctions(uint256) external view returns (uint256);

    function auctions(uint256)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            address,
            uint256,
            address,
            uint96,
            uint256
        );

    function stopped() external view returns (uint256);

    function init(address vault, address collybus) external;

    function setParam(bytes32 param, uint256 data) external;

    function setParam(bytes32 param, address data) external;

    function setParam(
        address vault,
        bytes32 param,
        uint256 data
    ) external;

    function setParam(
        address vault,
        bytes32 param,
        address data
    ) external;

    function startAuction(
        uint256 debt,
        uint256 collateralToSell,
        address vault,
        uint256 tokenId,
        address user,
        address keeper
    ) external returns (uint256 auctionId);

    function redoAuction(uint256 auctionId, address keeper) external;

    function takeCollateral(
        uint256 auctionId,
        uint256 collateralAmount,
        uint256 maxPrice,
        address recipient,
        bytes calldata data
    ) external;

    function count() external view returns (uint256);

    function list() external view returns (uint256[] memory);

    function getStatus(uint256 auctionId)
        external
        view
        returns (
            bool needsRedo,
            uint256 price,
            uint256 collateralToSell,
            uint256 debt
        );

    function updateAuctionDebtFloor(address vault) external;

    function cancelAuction(uint256 auctionId) external;
}// Copyright (C) 2018 Rain <[email protected]>

interface IVault {
    function codex() external view returns (ICodex);

    function collybus() external view returns (ICollybus);

    function token() external view returns (address);

    function tokenScale() external view returns (uint256);

    function underlierToken() external view returns (address);

    function underlierScale() external view returns (uint256);

    function vaultType() external view returns (bytes32);

    function live() external view returns (uint256);

    function lock() external;

    function setParam(bytes32 param, address data) external;

    function maturity(uint256 tokenId) external returns (uint256);

    function fairPrice(
        uint256 tokenId,
        bool net,
        bool face
    ) external view returns (uint256);

    function enter(
        uint256 tokenId,
        address user,
        uint256 amount
    ) external;

    function exit(
        uint256 tokenId,
        address user,
        uint256 amount
    ) external;
}
interface IGuarded {
    function ANY_SIG() external view returns (bytes32);

    function ANY_CALLER() external view returns (address);

    function allowCaller(bytes32 sig, address who) external;

    function blockCaller(bytes32 sig, address who) external;

    function canCall(bytes32 sig, address who) external view returns (bool);
}


abstract contract Guarded is IGuarded {
    /// ======== Custom Errors ======== ///

    error Guarded__notRoot();
    error Guarded__notGranted();

    /// ======== Storage ======== ///

    
    bytes32 public constant override ANY_SIG = keccak256("ANY_SIG");
    
    address public constant override ANY_CALLER = address(uint160(uint256(bytes32(keccak256("ANY_CALLER")))));

    
    
    mapping(bytes32 => mapping(address => bool)) private _canCall;

    /// ======== Events ======== ///

    event AllowCaller(bytes32 sig, address who);
    event BlockCaller(bytes32 sig, address who);

    constructor() {
        // set root
        _setRoot(msg.sender);
    }

    /// ======== Auth ======== ///

    modifier callerIsRoot() {
        if (_canCall[ANY_SIG][msg.sender]) {
            _;
        } else revert Guarded__notRoot();
    }

    modifier checkCaller() {
        if (canCall(msg.sig, msg.sender)) {
            _;
        } else revert Guarded__notGranted();
    }

    
    
    
    
    function allowCaller(bytes32 sig, address who) public override callerIsRoot {
        _canCall[sig][who] = true;
        emit AllowCaller(sig, who);
    }

    
    
    
    
    function blockCaller(bytes32 sig, address who) public override callerIsRoot {
        _canCall[sig][who] = false;
        emit BlockCaller(sig, who);
    }

    
    
    
    function canCall(bytes32 sig, address who) public view override returns (bool) {
        return (_canCall[sig][who] || _canCall[ANY_SIG][who] || _canCall[sig][ANY_CALLER]);
    }

    
    
    function _setRoot(address root) internal {
        _canCall[ANY_SIG][root] = true;
        emit AllowCaller(ANY_SIG, root);
    }

    
    
    function _unsetRoot(address root) internal {
        _canCall[ANY_SIG][root] = false;
        emit AllowCaller(ANY_SIG, root);
    }
}// Copyright (C) 2020 Maker Ecosystem Growth Holdings, INC.

uint256 constant MLN = 10**6;
uint256 constant BLN = 10**9;
uint256 constant WAD = 10**18;
uint256 constant RAY = 10**18;
uint256 constant RAD = 10**18;

/* solhint-disable func-visibility, no-inline-assembly */

error Math__toInt256_overflow(uint256 x);

function toInt256(uint256 x) pure returns (int256) {
    if (x > uint256(type(int256).max)) revert Math__toInt256_overflow(x);
    return int256(x);
}

function min(uint256 x, uint256 y) pure returns (uint256 z) {
    unchecked {
        z = x <= y ? x : y;
    }
}

function max(uint256 x, uint256 y) pure returns (uint256 z) {
    unchecked {
        z = x >= y ? x : y;
    }
}

error Math__diff_overflow(uint256 x, uint256 y);

function diff(uint256 x, uint256 y) pure returns (int256 z) {
    unchecked {
        z = int256(x) - int256(y);
        if (!(int256(x) >= 0 && int256(y) >= 0)) revert Math__diff_overflow(x, y);
    }
}

error Math__add_overflow(uint256 x, uint256 y);

function add(uint256 x, uint256 y) pure returns (uint256 z) {
    unchecked {
        if ((z = x + y) < x) revert Math__add_overflow(x, y);
    }
}

error Math__add48_overflow(uint256 x, uint256 y);

function add48(uint48 x, uint48 y) pure returns (uint48 z) {
    unchecked {
        if ((z = x + y) < x) revert Math__add48_overflow(x, y);
    }
}

error Math__add_overflow_signed(uint256 x, int256 y);

function add(uint256 x, int256 y) pure returns (uint256 z) {
    unchecked {
        z = x + uint256(y);
        if (!(y >= 0 || z <= x)) revert Math__add_overflow_signed(x, y);
        if (!(y <= 0 || z >= x)) revert Math__add_overflow_signed(x, y);
    }
}

error Math__sub_overflow(uint256 x, uint256 y);

function sub(uint256 x, uint256 y) pure returns (uint256 z) {
    unchecked {
        if ((z = x - y) > x) revert Math__sub_overflow(x, y);
    }
}

error Math__sub_overflow_signed(uint256 x, int256 y);

function sub(uint256 x, int256 y) pure returns (uint256 z) {
    unchecked {
        z = x - uint256(y);
        if (!(y <= 0 || z <= x)) revert Math__sub_overflow_signed(x, y);
        if (!(y >= 0 || z >= x)) revert Math__sub_overflow_signed(x, y);
    }
}

error Math__mul_overflow(uint256 x, uint256 y);

function mul(uint256 x, uint256 y) pure returns (uint256 z) {
    unchecked {
        if (!(y == 0 || (z = x * y) / y == x)) revert Math__mul_overflow(x, y);
    }
}

error Math__mul_overflow_signed(uint256 x, int256 y);

function mul(uint256 x, int256 y) pure returns (int256 z) {
    unchecked {
        z = int256(x) * y;
        if (int256(x) < 0) revert Math__mul_overflow_signed(x, y);
        if (!(y == 0 || z / y == int256(x))) revert Math__mul_overflow_signed(x, y);
    }
}

function wmul(uint256 x, uint256 y) pure returns (uint256 z) {
    unchecked {
        z = mul(x, y) / WAD;
    }
}

function wmul(uint256 x, int256 y) pure returns (int256 z) {
    unchecked {
        z = mul(x, y) / int256(WAD);
    }
}

error Math__div_overflow(uint256 x, uint256 y);

function div(uint256 x, uint256 y) pure returns (uint256 z) {
    unchecked {
        if (y == 0) revert Math__div_overflow(x, y);
        return x / y;
    }
}

function wdiv(uint256 x, uint256 y) pure returns (uint256 z) {
    unchecked {
        z = mul(x, WAD) / y;
    }
}

// optimized version from dss PR #78
function wpow(
    uint256 x,
    uint256 n,
    uint256 b
) pure returns (uint256 z) {
    unchecked {
        assembly {
            switch n
            case 0 {
                z := b
            }
            default {
                switch x
                case 0 {
                    z := 0
                }
                default {
                    switch mod(n, 2)
                    case 0 {
                        z := b
                    }
                    default {
                        z := x
                    }
                    let half := div(b, 2) // for rounding.
                    for {
                        n := div(n, 2)
                    } n {
                        n := div(n, 2)
                    } {
                        let xx := mul(x, x)
                        if shr(128, x) {
                            revert(0, 0)
                        }
                        let xxRound := add(xx, half)
                        if lt(xxRound, xx) {
                            revert(0, 0)
                        }
                        x := div(xxRound, b)
                        if mod(n, 2) {
                            let zx := mul(z, x)
                            if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) {
                                revert(0, 0)
                            }
                            let zxRound := add(zx, half)
                            if lt(zxRound, zx) {
                                revert(0, 0)
                            }
                            z := div(zxRound, b)
                        }
                    }
                }
            }
        }
    }
}

/* solhint-disable func-visibility, no-inline-assembly */


/// Uses Vat.sol from DSS (MakerDAO) / SafeEngine.sol from GEB (Reflexer Labs) as a blueprint
/// Changes from Vat.sol / SafeEngine.sol:
/// - only WAD precision is used (no RAD and RAY)
/// - uses a method signature based authentication scheme
/// - supports ERC1155, ERC721 style assets by TokenId
contract Codex is Guarded, ICodex {
    /// ======== Custom Errors ======== ///

    error Codex__init_vaultAlreadyInit();
    error Codex__setParam_notLive();
    error Codex__setParam_unrecognizedParam();
    error Codex__transferBalance_notAllowed();
    error Codex__transferCredit_notAllowed();
    error Codex__modifyCollateralAndDebt_notLive();
    error Codex__modifyCollateralAndDebt_vaultNotInit();
    error Codex__modifyCollateralAndDebt_ceilingExceeded();
    error Codex__modifyCollateralAndDebt_notSafe();
    error Codex__modifyCollateralAndDebt_notAllowedSender();
    error Codex__modifyCollateralAndDebt_notAllowedCollateralizer();
    error Codex__modifyCollateralAndDebt_notAllowedDebtor();
    error Codex__modifyCollateralAndDebt_debtFloor();
    error Codex__transferCollateralAndDebt_notAllowed();
    error Codex__transferCollateralAndDebt_notSafeSrc();
    error Codex__transferCollateralAndDebt_notSafeDst();
    error Codex__transferCollateralAndDebt_debtFloorSrc();
    error Codex__transferCollateralAndDebt_debtFloorDst();
    error Codex__modifyRate_notLive();

    /// ======== Storage ======== ///

    // Vault Data
    struct Vault {
        // Total Normalised Debt in Vault [wad]
        uint256 totalNormalDebt;
        // Vault's Accumulation Rate [wad]
        uint256 rate;
        // Vault's Debt Ceiling [wad]
        uint256 debtCeiling;
        // Debt Floor for Positions corresponding to this Vault [wad]
        uint256 debtFloor;
    }
    // Position Data
    struct Position {
        // Locked Collateral in Position [wad]
        uint256 collateral;
        // Normalised Debt (gross debt before rate is applied) generated by Position [wad]
        uint256 normalDebt;
    }

    
    
    mapping(address => mapping(address => uint256)) public override delegates;
    
    
    mapping(address => Vault) public override vaults;
    
    
    mapping(address => mapping(uint256 => mapping(address => Position))) public override positions;
    
    
    mapping(address => mapping(uint256 => mapping(address => uint256))) public override balances;
    
    
    mapping(address => uint256) public override credit;
    
    
    mapping(address => uint256) public override unbackedDebt;

    
    uint256 public override globalDebt;
    
    uint256 public override globalUnbackedDebt;
    
    uint256 public override globalDebtCeiling;

    
    uint256 public live;

    /// ======== Events ======== ///
    event Init(address indexed vault);
    event SetParam(address indexed vault, bytes32 indexed param, uint256 data);
    event GrantDelegate(address indexed delegator, address indexed delegatee);
    event RevokeDelegate(address indexed delegator, address indexed delegatee);
    event ModifyBalance(
        address indexed vault,
        uint256 indexed tokenId,
        address indexed user,
        int256 amount,
        uint256 balance
    );
    event TransferBalance(
        address indexed vault,
        uint256 indexed tokenId,
        address indexed src,
        address dst,
        uint256 amount,
        uint256 srcBalance,
        uint256 dstBalance
    );
    event TransferCredit(
        address indexed src,
        address indexed dst,
        uint256 amount,
        uint256 srcCredit,
        uint256 dstCredit
    );
    event ModifyCollateralAndDebt(
        address indexed vault,
        uint256 indexed tokenId,
        address indexed user,
        address collateralizer,
        address creditor,
        int256 deltaCollateral,
        int256 deltaNormalDebt
    );
    event TransferCollateralAndDebt(
        address indexed vault,
        uint256 indexed tokenId,
        address indexed src,
        address dst,
        int256 deltaCollateral,
        int256 deltaNormalDebt
    );
    event ConfiscateCollateralAndDebt(
        address indexed vault,
        uint256 indexed tokenId,
        address indexed user,
        address collateralizer,
        address debtor,
        int256 deltaCollateral,
        int256 deltaNormalDebt
    );
    event SettleUnbackedDebt(address indexed debtor, uint256 debt);
    event CreateUnbackedDebt(address indexed debtor, address indexed creditor, uint256 debt);
    event ModifyRate(address indexed vault, address indexed creditor, int256 deltaRate);
    event Lock();

    constructor() Guarded() {
        live = 1;
    }

    /// ======== Configuration ======== ///

    
    
    
    function init(address vault) external override checkCaller {
        if (vaults[vault].rate != 0) revert Codex__init_vaultAlreadyInit();
        vaults[vault].rate = WAD;
        emit Init(vault);
    }

    
    
    
    
    function setParam(bytes32 param, uint256 data) external override checkCaller {
        if (live == 0) revert Codex__setParam_notLive();
        if (param == "globalDebtCeiling") globalDebtCeiling = data;
        else revert Codex__setParam_unrecognizedParam();
        emit SetParam(address(0), param, data);
    }

    
    
    
    
    
    function setParam(
        address vault,
        bytes32 param,
        uint256 data
    ) external override checkCaller {
        if (live == 0) revert Codex__setParam_notLive();
        if (param == "debtCeiling") vaults[vault].debtCeiling = data;
        else if (param == "debtFloor") vaults[vault].debtFloor = data;
        else revert Codex__setParam_unrecognizedParam();
        emit SetParam(vault, param, data);
    }

    /// ======== Caller Delegation ======== ///

    
    
    function grantDelegate(address delegatee) external override {
        delegates[msg.sender][delegatee] = 1;
        emit GrantDelegate(msg.sender, delegatee);
    }

    
    
    function revokeDelegate(address delegatee) external override {
        delegates[msg.sender][delegatee] = 0;
        emit RevokeDelegate(msg.sender, delegatee);
    }

    
    
    
    
    function hasDelegate(address delegator, address delegatee) internal view returns (bool) {
        return delegator == delegatee || delegates[delegator][delegatee] == 1;
    }

    /// ======== Credit and Token Balance Administration ======== ///

    
    
    
    
    
    
    function modifyBalance(
        address vault,
        uint256 tokenId,
        address user,
        int256 amount
    ) external override checkCaller {
        balances[vault][tokenId][user] = add(balances[vault][tokenId][user], amount);
        emit ModifyBalance(vault, tokenId, user, amount, balances[vault][tokenId][user]);
    }

    
    
    
    
    
    
    
    function transferBalance(
        address vault,
        uint256 tokenId,
        address src,
        address dst,
        uint256 amount
    ) external override {
        if (!hasDelegate(src, msg.sender)) revert Codex__transferBalance_notAllowed();
        balances[vault][tokenId][src] = sub(balances[vault][tokenId][src], amount);
        balances[vault][tokenId][dst] = add(balances[vault][tokenId][dst], amount);
        emit TransferBalance(
            vault,
            tokenId,
            src,
            dst,
            amount,
            balances[vault][tokenId][src],
            balances[vault][tokenId][dst]
        );
    }

    
    
    
    
    
    function transferCredit(
        address src,
        address dst,
        uint256 amount
    ) external override {
        if (!hasDelegate(src, msg.sender)) revert Codex__transferCredit_notAllowed();
        credit[src] = sub(credit[src], amount);
        credit[dst] = add(credit[dst], amount);
        emit TransferCredit(src, dst, amount, credit[src], credit[dst]);
    }

    /// ======== Position Administration ======== ///

    
    
    /// that the Position is still safe after the modification,
    /// that the sender is delegated by the owner if the collateral-to-debt ratio decreased,
    /// that the sender is delegated by the collateralizer if new collateral is put up,
    /// that the sender is delegated by the creditor if debt is settled,
    /// and that the vault debt floor is exceeded
    
    
    
    
    
    
    
    /// settle (-) on this Position [wad]
    function modifyCollateralAndDebt(
        address vault,
        uint256 tokenId,
        address user,
        address collateralizer,
        address creditor,
        int256 deltaCollateral,
        int256 deltaNormalDebt
    ) external override {
        // system is live
        if (live == 0) revert Codex__modifyCollateralAndDebt_notLive();

        Position memory p = positions[vault][tokenId][user];
        Vault memory v = vaults[vault];
        // vault has been initialised
        if (v.rate == 0) revert Codex__modifyCollateralAndDebt_vaultNotInit();

        p.collateral = add(p.collateral, deltaCollateral);
        p.normalDebt = add(p.normalDebt, deltaNormalDebt);
        v.totalNormalDebt = add(v.totalNormalDebt, deltaNormalDebt);

        int256 deltaDebt = wmul(v.rate, deltaNormalDebt);
        uint256 debt = wmul(v.rate, p.normalDebt);
        globalDebt = add(globalDebt, deltaDebt);

        // either debt has decreased, or debt ceilings are not exceeded
        if (deltaNormalDebt > 0 && (wmul(v.totalNormalDebt, v.rate) > v.debtCeiling || globalDebt > globalDebtCeiling))
            revert Codex__modifyCollateralAndDebt_ceilingExceeded();
        // position is either less risky than before, or it is safe
        if (
            (deltaNormalDebt > 0 || deltaCollateral < 0) &&
            debt > wmul(p.collateral, IVault(vault).fairPrice(tokenId, true, false))
        ) revert Codex__modifyCollateralAndDebt_notSafe();

        // position is either more safe, or the owner consents
        if ((deltaNormalDebt > 0 || deltaCollateral < 0) && !hasDelegate(user, msg.sender))
            revert Codex__modifyCollateralAndDebt_notAllowedSender();
        // collateralizer consents if new collateral is put up
        if (deltaCollateral > 0 && !hasDelegate(collateralizer, msg.sender))
            revert Codex__modifyCollateralAndDebt_notAllowedCollateralizer();

        // creditor consents if debt is settled with credit
        if (deltaNormalDebt < 0 && !hasDelegate(creditor, msg.sender))
            revert Codex__modifyCollateralAndDebt_notAllowedDebtor();

        // position has no debt, or a non-dusty amount
        if (p.normalDebt != 0 && debt < v.debtFloor) revert Codex__modifyCollateralAndDebt_debtFloor();

        balances[vault][tokenId][collateralizer] = sub(balances[vault][tokenId][collateralizer], deltaCollateral);
        credit[creditor] = add(credit[creditor], deltaDebt);

        positions[vault][tokenId][user] = p;
        vaults[vault] = v;

        emit ModifyCollateralAndDebt(vault, tokenId, user, collateralizer, creditor, deltaCollateral, deltaNormalDebt);
    }

    
    
    /// that the `src` and `dst` Positions are still safe after the transfer,
    /// and that the `src` and `dst` Positions' debt exceed the vault's debt floor
    
    
    
    
    
    
    /// from (-) the `dst` Position [wad]
    function transferCollateralAndDebt(
        address vault,
        uint256 tokenId,
        address src,
        address dst,
        int256 deltaCollateral,
        int256 deltaNormalDebt
    ) external override {
        Position storage pSrc = positions[vault][tokenId][src];
        Position storage pDst = positions[vault][tokenId][dst];
        Vault storage v = vaults[vault];

        pSrc.collateral = sub(pSrc.collateral, deltaCollateral);
        pSrc.normalDebt = sub(pSrc.normalDebt, deltaNormalDebt);
        pDst.collateral = add(pDst.collateral, deltaCollateral);
        pDst.normalDebt = add(pDst.normalDebt, deltaNormalDebt);

        uint256 debtSrc = wmul(pSrc.normalDebt, v.rate);
        uint256 debtDst = wmul(pDst.normalDebt, v.rate);

        // both sides consent
        if (!hasDelegate(src, msg.sender) || !hasDelegate(dst, msg.sender))
            revert Codex__transferCollateralAndDebt_notAllowed();

        // both sides safe
        if (debtSrc > wmul(pSrc.collateral, IVault(vault).fairPrice(tokenId, true, false)))
            revert Codex__transferCollateralAndDebt_notSafeSrc();
        if (debtDst > wmul(pDst.collateral, IVault(vault).fairPrice(tokenId, true, false)))
            revert Codex__transferCollateralAndDebt_notSafeDst();

        // both sides non-dusty
        if (pSrc.normalDebt != 0 && debtSrc < v.debtFloor) revert Codex__transferCollateralAndDebt_debtFloorSrc();
        if (pDst.normalDebt != 0 && debtDst < v.debtFloor) revert Codex__transferCollateralAndDebt_debtFloorDst();

        emit TransferCollateralAndDebt(vault, tokenId, src, dst, deltaCollateral, deltaNormalDebt);
    }

    
    
    
    
    
    
    
    
    
    /// settle (-) on this Position [wad]
    function confiscateCollateralAndDebt(
        address vault,
        uint256 tokenId,
        address user,
        address collateralizer,
        address debtor,
        int256 deltaCollateral,
        int256 deltaNormalDebt
    ) external override checkCaller {
        Position storage position = positions[vault][tokenId][user];
        Vault storage v = vaults[vault];

        position.collateral = add(position.collateral, deltaCollateral);
        position.normalDebt = add(position.normalDebt, deltaNormalDebt);
        v.totalNormalDebt = add(v.totalNormalDebt, deltaNormalDebt);

        int256 deltaDebt = wmul(v.rate, deltaNormalDebt);

        balances[vault][tokenId][collateralizer] = sub(balances[vault][tokenId][collateralizer], deltaCollateral);
        unbackedDebt[debtor] = sub(unbackedDebt[debtor], deltaDebt);
        globalUnbackedDebt = sub(globalUnbackedDebt, deltaDebt);

        emit ConfiscateCollateralAndDebt(
            vault,
            tokenId,
            user,
            collateralizer,
            debtor,
            deltaCollateral,
            deltaNormalDebt
        );
    }

    /// ======== Unbacked Debt ======== ///

    
    
    
    function settleUnbackedDebt(uint256 debt) external override {
        address debtor = msg.sender;
        unbackedDebt[debtor] = sub(unbackedDebt[debtor], debt);
        credit[debtor] = sub(credit[debtor], debt);
        globalUnbackedDebt = sub(globalUnbackedDebt, debt);
        globalDebt = sub(globalDebt, debt);
        emit SettleUnbackedDebt(debtor, debt);
    }

    
    
    
    
    
    function createUnbackedDebt(
        address debtor,
        address creditor,
        uint256 debt
    ) external override checkCaller {
        unbackedDebt[debtor] = add(unbackedDebt[debtor], debt);
        credit[creditor] = add(credit[creditor], debt);
        globalUnbackedDebt = add(globalUnbackedDebt, debt);
        globalDebt = add(globalDebt, debt);
        emit CreateUnbackedDebt(debtor, creditor, debt);
    }

    /// ======== Debt Interest Rates ======== ///

    
    
    
    
    
    function modifyRate(
        address vault,
        address creditor,
        int256 deltaRate
    ) external override checkCaller {
        if (live == 0) revert Codex__modifyRate_notLive();
        Vault storage v = vaults[vault];
        v.rate = add(v.rate, deltaRate);
        int256 wad = wmul(v.totalNormalDebt, deltaRate);
        credit[creditor] = add(credit[creditor], wad);
        globalDebt = add(globalDebt, wad);
        emit ModifyRate(vault, creditor, deltaRate);
    }

    /// ======== Shutdown ======== ///

    
    
    function lock() external override checkCaller {
        live = 0;
        emit Lock();
    }
}
interface IGuard {
    function isGuard() external view returns (bool);
}
contract Delayed {
    error Delayed__setParam_notDelayed();
    error Delayed__delay_invalidEta();
    error Delayed__execute_unknown();
    error Delayed__execute_stillDelayed();
    error Delayed__execute_executionError();

    mapping(bytes32 => bool) public queue;
    uint256 public delay;

    event SetParam(bytes32 param, uint256 data);
    event Queue(address target, bytes data, uint256 eta);
    event Unqueue(address target, bytes data, uint256 eta);
    event Execute(address target, bytes data, uint256 eta);

    constructor(uint256 delay_) {
        delay = delay_;
        emit SetParam("delay", delay_);
    }

    function _setParam(bytes32 param, uint256 data) internal {
        if (param == "delay") delay = data;
        emit SetParam(param, data);
    }

    function _delay(
        address target,
        bytes memory data,
        uint256 eta
    ) internal {
        if (eta < block.timestamp + delay) revert Delayed__delay_invalidEta();
        queue[keccak256(abi.encode(target, data, eta))] = true;
        emit Queue(target, data, eta);
    }

    function _skip(
        address target,
        bytes memory data,
        uint256 eta
    ) internal {
        queue[keccak256(abi.encode(target, data, eta))] = false;
        emit Unqueue(target, data, eta);
    }

    function execute(
        address target,
        bytes calldata data,
        uint256 eta
    ) external returns (bytes memory out) {
        bytes32 callHash = keccak256(abi.encode(target, data, eta));

        if (!queue[callHash]) revert Delayed__execute_unknown();
        if (block.timestamp < eta) revert Delayed__execute_stillDelayed();

        queue[callHash] = false;

        bool ok;
        (ok, out) = target.call(data);
        if (!ok) revert Delayed__execute_executionError();

        emit Execute(target, data, eta);
    }
}
abstract contract BaseGuard is Delayed, IGuard {
    /// ======== Custom Errors ======== ///

    error BaseGuard__isSenatus_notSenatus();
    error BaseGuard__isGuardian_notGuardian();
    error BaseGuard__isDelayed_notSelf(address, address);
    error BaseGuard__inRange_notInRange();

    /// ======== Storage ======== ///

    
    address public immutable senatus;
    
    address public guardian;

    constructor(
        address senatus_,
        address guardian_,
        uint256 delay
    ) Delayed(delay) {
        senatus = senatus_;
        guardian = guardian_;
    }

    modifier isSenatus() {
        if (msg.sender != senatus) revert BaseGuard__isSenatus_notSenatus();
        _;
    }

    modifier isGuardian() {
        if (msg.sender != guardian) revert BaseGuard__isGuardian_notGuardian();
        _;
    }

    modifier isDelayed() {
        if (msg.sender != address(this)) revert BaseGuard__isDelayed_notSelf(msg.sender, address(this));
        _;
    }

    
    
    function isGuard() external view virtual override returns (bool);

    
    
    
    function setGuardian(address guardian_) external isSenatus {
        guardian = guardian_;
    }

    /// ======== Capabilities ======== ///

    
    
    
    function setDelay(uint256 delay) external isSenatus {
        _setParam("delay", delay);
    }

    
    
    
    function schedule(bytes calldata data) external isGuardian {
        _delay(address(this), data, block.timestamp + delay);
    }

    /// ======== Helper Methods ======== ///

    
    
    
    
    
    function _inRange(
        uint256 value,
        uint256 min_,
        uint256 max
    ) internal pure {
        if (max < value || value < min_) revert BaseGuard__inRange_notInRange();
    }
}


contract CodexGuard is BaseGuard {
    /// ======== Custom Errors ======== ///

    error CodexGuard__isGuard_cantCall();
    error CodexGuard__addDebtCeilingAdjuster_invalidDelay();

    /// ======== Storage ======== ///

    struct DebtCeilingAdjuster {
        // Max. ceiling possible [wad]
        uint256 maxDebtCeiling;
        // Max. value between current debt and maxDebtCeiling to be set [wad]
        uint256 maxDelta;
        // Min. time to pass before a new increase [seconds]
        uint48 delay;
        // Last block the ceiling was updated [blocks]
        uint48 last;
        // Last time the ceiling was increased compared to its previous value [seconds]
        uint48 lastInc;
    }
    
    /// Address of Vault => DebtCeilingAdjuster
    mapping(address => DebtCeilingAdjuster) public debtCeilingAdjusters;

    
    Codex public immutable codex;

    constructor(
        address senatus,
        address guardian,
        uint256 delay,
        address codex_
    ) BaseGuard(senatus, guardian, delay) {
        codex = Codex(codex_);
    }

    
    function isGuard() external view override returns (bool) {
        if (!codex.canCall(codex.ANY_SIG(), address(this))) revert CodexGuard__isGuard_cantCall();
        return true;
    }

    /// ======== Capabilities ======== ///

    
    
    
    
    
    function setDebtCeilingAdjuster(
        address vault,
        uint256 maxDebtCeiling,
        uint256 maxDelta,
        uint256 delay
    ) external isSenatus {
        if (maxDebtCeiling == 0) maxDebtCeiling = 10_000_000 * WAD;
        if (delay >= type(uint48).max) revert CodexGuard__addDebtCeilingAdjuster_invalidDelay();
        debtCeilingAdjusters[vault] = DebtCeilingAdjuster(maxDebtCeiling, maxDelta, uint48(delay), 0, 0);
    }

    
    
    
    function removeDebtCeilingAdjuster(address vault) external isSenatus {
        delete debtCeilingAdjusters[vault];
    }

    
    
    
    function setDebtCeiling(address vault) external returns (uint256) {
        (uint256 totalNormalDebt, uint256 rate, uint256 currentDebtCeiling, ) = codex.vaults(vault);
        DebtCeilingAdjuster memory dca = debtCeilingAdjusters[vault];

        // return if the vault is not enabled
        if (dca.maxDebtCeiling == 0) return currentDebtCeiling;
        // return if there was already an update in the same block
        if (dca.last == block.number) return currentDebtCeiling;

        // calculate debt
        uint256 debt = wmul(totalNormalDebt, rate);
        // calculate new debtCeiling based on the minimum between maxDebtCeiling and actual debt + maxDelta
        uint256 debtCeiling = min(add(debt, dca.maxDelta), dca.maxDebtCeiling);

        // short-circuit if there wasn't an update or if the time since last increment has not passed
        if (
            debtCeiling == currentDebtCeiling ||
            (debtCeiling > currentDebtCeiling && block.timestamp < add(dca.lastInc, dca.delay))
        ) return currentDebtCeiling;

        // set debt ceiling
        codex.setParam(vault, "debtCeiling", debtCeiling);
        // set global debt ceiling
        codex.setParam("globalDebtCeiling", add(sub(codex.globalDebtCeiling(), currentDebtCeiling), debtCeiling));

        // update lastInc if it is an increment in the debt ceiling
        // and update last whatever the update is
        if (debtCeiling > currentDebtCeiling) {
            debtCeilingAdjusters[vault].lastInc = uint48(block.timestamp);
            debtCeilingAdjusters[vault].last = uint48(block.number);
        } else {
            debtCeilingAdjusters[vault].last = uint48(block.number);
        }

        return debtCeiling;
    }

    
    
    
    
    
    function setDebtFloor(
        address vault,
        uint256 debtFloor,
        address[] calldata collateralAuctions
    ) external isGuardian {
        _inRange(debtFloor, 0, 10_000 * WAD);
        codex.setParam(vault, "debtFloor", debtFloor);
        // update auctionDebtFloor for the provided collateral auction contracts
        for (uint256 i = 0; i < collateralAuctions.length; i++) {
            INoLossCollateralAuction(collateralAuctions[i]).updateAuctionDebtFloor(vault);
        }
    }
}