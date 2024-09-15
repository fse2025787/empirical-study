// SPDX-License-Identifier: AGPL-3.0-or-later

/**
 *Submitted for verification at Etherscan.io on 2022-04-04
*/

// 
pragma solidity ^0.8.4;

interface IPriceCalculator {
    // 1st arg: initial price [wad]
    // 2nd arg: seconds since auction start [seconds]
    // returns: current auction price [wad]
    function price(uint256, uint256) external view returns (uint256);
}// Copyright (C) 2020-2021 Maker Ecosystem Growth Holdings, INC.

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
}interface IPriceFeed {
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

interface CollateralAuctionCallee {
    function collateralAuctionCall(
        address,
        uint256,
        uint256,
        bytes calldata
    ) external;
}

interface ICollateralAuction {
    function vaults(address)
        external
        view
        returns (
            uint256,
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
}interface INoLossCollateralAuction {
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
}interface IVault {
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


/// Uses Clip.sol from DSS (MakerDAO) as a blueprint
/// Changes from Clip.sol:
/// - only WAD precision is used (no RAD and RAY)
/// - uses a method signature based authentication scheme
/// - supports ERC1155, ERC721 style assets by TokenId
contract NoLossCollateralAuction is Guarded, INoLossCollateralAuction {
    /// ======== Custom Errors ======== ///

    error NoLossCollateralAuction__init_vaultAlreadyInit();
    error NoLossCollateralAuction__checkReentrancy_reentered();
    error NoLossCollateralAuction__isStopped_stoppedIncorrect();
    error NoLossCollateralAuction__setParam_unrecognizedParam();
    error NoLossCollateralAuction__startAuction_zeroDebt();
    error NoLossCollateralAuction__startAuction_zeroCollateralToSell();
    error NoLossCollateralAuction__startAuction_zeroUser();
    error NoLossCollateralAuction__startAuction_overflow();
    error NoLossCollateralAuction__startAuction_zeroStartPrice();
    error NoLossCollateralAuction__redoAuction_notRunningAuction();
    error NoLossCollateralAuction__redoAuction_cannotReset();
    error NoLossCollateralAuction__redoAuction_zeroStartPrice();
    error NoLossCollateralAuction__takeCollateral_notRunningAuction();
    error NoLossCollateralAuction__takeCollateral_needsReset();
    error NoLossCollateralAuction__takeCollateral_tooExpensive();
    error NoLossCollateralAuction__takeCollateral_noPartialPurchase();
    error NoLossCollateralAuction__cancelAuction_notRunningAction();

    /// ======== Storage ======== ///

    // Vault specific configuration data
    struct VaultConfig {
        // Multiplicative factor to increase start price [wad]
        uint256 multiplier;
        // Time elapsed before auction reset [seconds]
        uint256 maxAuctionDuration;
        // Cache (v.debtFloor * v.liquidationPenalty) to prevent excessive SLOADs [wad]
        uint256 auctionDebtFloor;
        // Collateral price module
        ICollybus collybus;
        // Current price calculator
        IPriceCalculator calculator;
    }

    
    
    mapping(address => VaultConfig) public override vaults;

    
    ICodex public immutable override codex;
    
    ILimes public override limes;
    
    IAer public override aer;
    
    uint64 public override feeTip;
    
    uint192 public override flatTip;
    
    uint256 public override auctionCounter;
    
    uint256[] public override activeAuctions;

    // Auction State
    struct Auction {
        // Index in activeAuctions array
        uint256 index;
        // Debt to sell == Credit to raise [wad]
        uint256 debt;
        // collateral to sell [wad]
        uint256 collateralToSell;
        // Vault of the liquidated Positions collateral
        address vault;
        // TokenId of the liquidated Positions collateral
        uint256 tokenId;
        // Owner of the liquidated Position
        address user;
        // Auction start time
        uint96 startsAt;
        // Starting price [wad]
        uint256 startPrice;
    }
    
    
    mapping(uint256 => Auction) public override auctions;

    // reentrancy guard
    uint256 private entered;

    
    /// Levels for circuit breaker
    /// 0: no breaker
    /// 1: no new startAuction()
    /// 2: no new startAuction() or redoAuction()
    /// 3: no new startAuction(), redoAuction(), or takeCollateral()
    uint256 public override stopped = 0;

    /// ======== Events ======== ///

    event Init(address vault);

    event SetParam(bytes32 indexed param, uint256 data);
    event SetParam(bytes32 indexed param, address data);

    event StartAuction(
        uint256 indexed auctionId,
        uint256 startPrice,
        uint256 debt,
        uint256 collateralToSell,
        address vault,
        uint256 tokenId,
        address user,
        address indexed keeper,
        uint256 tip
    );
    event TakeCollateral(
        uint256 indexed auctionId,
        uint256 maxPrice,
        uint256 price,
        uint256 owe,
        uint256 debt,
        uint256 collateralToSell,
        address vault,
        uint256 tokenId,
        address indexed user
    );
    event RedoAuction(
        uint256 indexed auctionId,
        uint256 startPrice,
        uint256 debt,
        uint256 collateralToSell,
        address vault,
        uint256 tokenId,
        address user,
        address indexed keeper,
        uint256 tip
    );

    event StopAuction(uint256 auctionId);

    event UpdateAuctionDebtFloor(address indexed vault, uint256 auctionDebtFloor);

    constructor(address codex_, address limes_) Guarded() {
        codex = ICodex(codex_);
        limes = ILimes(limes_);
    }

    modifier checkReentrancy() {
        if (entered == 0) {
            entered = 1;
            _;
            entered = 0;
        } else revert NoLossCollateralAuction__checkReentrancy_reentered();
    }

    modifier isStopped(uint256 level) {
        if (stopped < level) {
            _;
        } else revert NoLossCollateralAuction__isStopped_stoppedIncorrect();
    }

    /// ======== Configuration ======== ///

    
    
    
    
    function init(address vault, address collybus) external override checkCaller {
        if (vaults[vault].calculator != IPriceCalculator(address(0)))
            revert NoLossCollateralAuction__init_vaultAlreadyInit();
        vaults[vault].multiplier = WAD;
        vaults[vault].collybus = ICollybus(collybus);

        emit Init(vault);
    }

    
    
    
    
    function setParam(bytes32 param, uint256 data) external override checkCaller checkReentrancy {
        if (param == "feeTip")
            feeTip = uint64(data); // Percentage of debt to incentivize (max: 2^64 - 1 => 18.xxx WAD = 18xx%)
        else if (param == "flatTip")
            flatTip = uint192(data); // Flat fee to incentivize keepers (max: 2^192 - 1 => 6.277T WAD)
        else if (param == "stopped")
            stopped = data; // Set breaker (0, 1, 2, or 3)
        else revert NoLossCollateralAuction__setParam_unrecognizedParam();
        emit SetParam(param, data);
    }

    
    
    
    
    function setParam(bytes32 param, address data) external override checkCaller checkReentrancy {
        if (param == "limes") limes = ILimes(data);
        else if (param == "aer") aer = IAer(data);
        else revert NoLossCollateralAuction__setParam_unrecognizedParam();
        emit SetParam(param, data);
    }

    
    
    
    
    
    function setParam(
        address vault,
        bytes32 param,
        uint256 data
    ) external override checkCaller checkReentrancy {
        if (param == "multiplier") vaults[vault].multiplier = data;
        else if (param == "maxAuctionDuration")
            vaults[vault].maxAuctionDuration = data; // Time elapsed before auction reset
        else revert NoLossCollateralAuction__setParam_unrecognizedParam();
        emit SetParam(param, data);
    }

    
    
    
    
    
    function setParam(
        address vault,
        bytes32 param,
        address data
    ) external override checkCaller checkReentrancy {
        if (param == "collybus") vaults[vault].collybus = ICollybus(data);
        else if (param == "calculator") vaults[vault].calculator = IPriceCalculator(data);
        else revert NoLossCollateralAuction__setParam_unrecognizedParam();
        emit SetParam(param, data);
    }

    /// ======== No Loss Collateral Auction ======== ///

    // get price at maturity
    function _getPrice(address vault, uint256 tokenId) internal view returns (uint256) {
        return IVault(vault).fairPrice(tokenId, false, true);
    }

    
    /// The start price `startPrice` is obtained as follows:
    ///     startPrice = val * multiplier / redemptionPrice
    /// Where `val` is the collateral's unitary value in USD, `multiplier` is a
    /// multiplicative factor to increase the start price, and `redemptionPrice` is a reference per Credit.
    
    /// - trusts the caller to transfer collateral to the contract
    /// - reverts if circuit breaker is set to 1 (no new auctions)
    
    
    
    
    
    
    
    function startAuction(
        uint256 debt,
        uint256 collateralToSell,
        address vault,
        uint256 tokenId,
        address user,
        address keeper
    ) external override checkCaller checkReentrancy isStopped(1) returns (uint256 auctionId) {
        // Input validation
        if (debt == 0) revert NoLossCollateralAuction__startAuction_zeroDebt();
        if (collateralToSell == 0) revert NoLossCollateralAuction__startAuction_zeroCollateralToSell();
        if (user == address(0)) revert NoLossCollateralAuction__startAuction_zeroUser();
        unchecked {
            auctionId = ++auctionCounter;
        }
        if (auctionId == 0) revert NoLossCollateralAuction__startAuction_overflow();

        activeAuctions.push(auctionId);

        auctions[auctionId].index = activeAuctions.length - 1;

        auctions[auctionId].debt = debt;
        auctions[auctionId].collateralToSell = collateralToSell;
        auctions[auctionId].vault = vault;
        auctions[auctionId].tokenId = tokenId;
        auctions[auctionId].user = user;
        auctions[auctionId].startsAt = uint96(block.timestamp);

        uint256 startPrice;
        startPrice = wmul(_getPrice(vault, tokenId), vaults[vault].multiplier);
        if (startPrice <= 0) revert NoLossCollateralAuction__startAuction_zeroStartPrice();
        auctions[auctionId].startPrice = startPrice;

        // incentive to startAuction auction
        uint256 _tip = flatTip;
        uint256 _feeTip = feeTip;
        uint256 tip;
        if (_tip > 0 || _feeTip > 0) {
            tip = add(_tip, wmul(debt, _feeTip));
            codex.createUnbackedDebt(address(aer), keeper, tip);
        }

        emit StartAuction(auctionId, startPrice, debt, collateralToSell, vault, tokenId, user, keeper, tip);
    }

    
    /// See `startAuction` above for an explanation of the computation of `startPrice`.
    /// multiplicative factor to increase the start price, and `redemptionPrice` is a reference per Credit.
    
    
    
    function redoAuction(uint256 auctionId, address keeper) external override checkReentrancy isStopped(2) {
        // Read auction data
        Auction memory auction = auctions[auctionId];

        if (auction.user == address(0)) revert NoLossCollateralAuction__redoAuction_notRunningAuction();

        // Check that auction needs reset
        // and compute current price [wad]
        {
            (bool done, ) = status(auction);
            if (!done) revert NoLossCollateralAuction__redoAuction_cannotReset();
        }

        uint256 debt = auctions[auctionId].debt;
        uint256 collateralToSell = auctions[auctionId].collateralToSell;
        auctions[auctionId].startsAt = uint96(block.timestamp);

        uint256 price = _getPrice(auction.vault, auction.tokenId);
        uint256 startPrice = wmul(price, vaults[auction.vault].multiplier);
        if (startPrice <= 0) revert NoLossCollateralAuction__redoAuction_zeroStartPrice();
        auctions[auctionId].startPrice = startPrice;

        // incentive to redoAuction auction
        uint256 tip;
        {
            uint256 _tip = flatTip;
            uint256 _feeTip = feeTip;
            if (_tip > 0 || _feeTip > 0) {
                uint256 _auctionDebtFloor = vaults[auction.vault].auctionDebtFloor;
                if (debt >= _auctionDebtFloor && wmul(collateralToSell, price) >= _auctionDebtFloor) {
                    tip = add(_tip, wmul(debt, _feeTip));
                    codex.createUnbackedDebt(address(aer), keeper, tip);
                }
            }
        }

        emit RedoAuction(
            auctionId,
            startPrice,
            debt,
            collateralToSell,
            auction.vault,
            auction.tokenId,
            auction.user,
            keeper,
            tip
        );
    }

    
    ///
    /// Auctions will not collect more Credit than their assigned Credit target,`debt`;
    /// thus, if `collateralAmount` would cost more Credit than `debt` at the current price, the
    /// amount of collateral purchased will instead be just enough to collect `debt` in Credit.
    ///
    /// To avoid partial purchases resulting in very small leftover auctions that will
    /// never be cleared, any partial purchase must leave at least `CollateralAuction.auctionDebtFloor`
    /// remaining Credit target. `auctionDebtFloor` is an asynchronously updated value equal to
    /// (Codex.debtFloor * Limes.liquidationPenalty(vault) / WAD) where the values are understood to be determined
    /// by whatever they were when CollateralAuction.updateAuctionDebtFloor() was last called. Purchase amounts
    /// will be minimally decreased when necessary to respect this limit; i.e., if the
    /// specified `collateralAmount` would leave `debt < auctionDebtFloor` but `debt > 0`, the amount actually
    /// purchased will be such that `debt == auctionDebtFloor`.
    ///
    /// If `debt <= auctionDebtFloor`, partial purchases are no longer possible; that is, the remaining
    /// collateral can only be purchased entirely, or not at all.
    ///
    /// Enforces a price floor of debt / collateral
    ///
    
    
    
    
    
    
    function takeCollateral(
        uint256 auctionId, // Auction id
        uint256 collateralAmount, // Upper limit on amount of collateral to buy [wad]
        uint256 maxPrice, // Maximum acceptable price (Credit / collateral) [wad]
        address recipient, // Receiver of collateral and external call address
        bytes calldata data // Data to pass in external call; if length 0, no call is done
    ) external override checkReentrancy isStopped(3) {
        Auction memory auction = auctions[auctionId];

        if (auction.user == address(0)) revert NoLossCollateralAuction__takeCollateral_notRunningAuction();

        uint256 price;
        {
            bool done;
            (done, price) = status(auction);

            // Check that auction doesn't need reset
            if (done) revert NoLossCollateralAuction__takeCollateral_needsReset();
            // Ensure price is acceptable to buyer
            if (maxPrice < price) revert NoLossCollateralAuction__takeCollateral_tooExpensive();
        }

        uint256 collateralToSell = auction.collateralToSell;
        uint256 debt = auction.debt;
        uint256 owe;

        unchecked {
            {
                // Purchase as much as possible, up to collateralAmount
                // collateralSlice <= collateralToSell
                uint256 collateralSlice = min(collateralToSell, collateralAmount);

                // Credit needed to buy a collateralSlice of this auction
                owe = wmul(collateralSlice, price);

                // owe can be greater than debt and thus user would pay a premium to the recipient

                if (owe < debt && collateralSlice < collateralToSell) {
                    // If collateralSlice == collateralToSell => auction completed => debtFloor doesn't matter
                    uint256 _auctionDebtFloor = vaults[auction.vault].auctionDebtFloor;
                    if (debt - owe < _auctionDebtFloor) {
                        // safe as owe < debt
                        // If debt <= auctionDebtFloor, buyers have to take the entire collateralToSell.
                        if (debt <= _auctionDebtFloor)
                            revert NoLossCollateralAuction__takeCollateral_noPartialPurchase();
                        // Adjust amount to pay
                        owe = debt - _auctionDebtFloor; // owe' <= owe
                        // Adjust collateralSlice
                        // collateralSlice' = owe' / price < owe / price == collateralSlice < collateralToSell
                        collateralSlice = wdiv(owe, price);
                    }
                }

                // Calculate remaining collateralToSell after operation
                collateralToSell = collateralToSell - collateralSlice;

                // Send collateral to recipient
                codex.transferBalance(auction.vault, auction.tokenId, address(this), recipient, collateralSlice);

                // Do external call (if data is defined) but to be
                // extremely careful we don't allow to do it to the two
                // contracts which the CollateralAuction needs to be authorized
                ILimes limes_ = limes;
                if (data.length > 0 && recipient != address(codex) && recipient != address(limes_)) {
                    CollateralAuctionCallee(recipient).collateralAuctionCall(msg.sender, owe, collateralSlice, data);
                }

                // Get Credit from caller
                codex.transferCredit(msg.sender, address(aer), owe);

                // Removes Credit out for liquidation from accumulator
                // if all collateral has been sold or owe is larger than remaining debt
                //  then just remove the remaining debt from the accumulator
                limes_.liquidated(auction.vault, auction.tokenId, (collateralToSell == 0 || debt < owe) ? debt : owe);

                // Calculate remaining debt after operation
                debt = (owe < debt) ? debt - owe : 0; // safe since owe <= debt
            }
        }

        if (collateralToSell == 0) {
            _remove(auctionId);
        } else if (debt == 0) {
            codex.transferBalance(auction.vault, auction.tokenId, address(this), auction.user, collateralToSell);
            _remove(auctionId);
        } else {
            auctions[auctionId].debt = debt;
            auctions[auctionId].collateralToSell = collateralToSell;
        }

        emit TakeCollateral(
            auctionId,
            maxPrice,
            price,
            owe,
            debt,
            collateralToSell,
            auction.vault,
            auction.tokenId,
            auction.user
        );
    }

    // Removes an auction from the active auctions array
    function _remove(uint256 auctionId) internal {
        uint256 _move = activeAuctions[activeAuctions.length - 1];
        if (auctionId != _move) {
            uint256 _index = auctions[auctionId].index;
            activeAuctions[_index] = _move;
            auctions[_move].index = _index;
        }
        activeAuctions.pop();
        delete auctions[auctionId];
    }

    
    
    function count() external view override returns (uint256) {
        return activeAuctions.length;
    }

    
    
    function list() external view override returns (uint256[] memory) {
        return activeAuctions;
    }

    
    
    
    
    
    
    function getStatus(uint256 auctionId)
        external
        view
        override
        returns (
            bool needsRedo,
            uint256 price,
            uint256 collateralToSell,
            uint256 debt
        )
    {
        Auction memory auction = auctions[auctionId];

        bool done;
        (done, price) = status(auction);

        needsRedo = auction.user != address(0) && done;
        collateralToSell = auction.collateralToSell;
        debt = auction.debt;
    }

    // Internally returns boolean for if an auction needs a redo
    function status(Auction memory auction) internal view returns (bool done, uint256 price) {
        uint256 floorPrice = wdiv(auction.debt, auction.collateralToSell);
        price = max(
            floorPrice,
            vaults[auction.vault].calculator.price(auction.startPrice, sub(block.timestamp, auction.startsAt))
        );
        done = (sub(block.timestamp, auction.startsAt) > vaults[auction.vault].maxAuctionDuration ||
            price == floorPrice);
    }

    
    
    function updateAuctionDebtFloor(address vault) external override {
        (, , , uint256 _debtFloor) = ICodex(codex).vaults(vault);
        uint256 auctionDebtFloor = wmul(_debtFloor, limes.liquidationPenalty(vault));
        vaults[vault].auctionDebtFloor = auctionDebtFloor;
        emit UpdateAuctionDebtFloor(vault, auctionDebtFloor);
    }

    /// ======== Shutdown ======== ///

    
    
    
    function cancelAuction(uint256 auctionId) external override checkCaller checkReentrancy {
        if (auctions[auctionId].user == address(0)) revert NoLossCollateralAuction__cancelAuction_notRunningAction();
        address vault = auctions[auctionId].vault;
        uint256 tokenId = auctions[auctionId].tokenId;
        limes.liquidated(vault, tokenId, auctions[auctionId].debt);
        codex.transferBalance(vault, tokenId, address(this), msg.sender, auctions[auctionId].collateralToSell);
        _remove(auctionId);
        emit StopAuction(auctionId);
    }
}// Copyright (C) 2020 Maker Ecosystem Growth Holdings, INC.





/// Uses LinearDecrease.sol from DSS (MakerDAO) as a blueprint
/// Changes from LinearDecrease.sol /:
/// - only WAD precision is used (no RAD and RAY)
/// - uses a method signature based authentication scheme
/// - supports ERC1155, ERC721 style assets by TokenId
contract LinearDecrease is Guarded, IPriceCalculator {
    /// ======== Custom Errors ======== ///

    error LinearDecrease__setParam_unrecognizedParam();

    /// ======== Storage ======== ///

    
    uint256 public duration;

    /// ======== Events ======== ///

    event SetParam(bytes32 indexed param, uint256 data);

    constructor() Guarded() {}

    /// ======== Configuration ======== ///

    
    
    
    
    function setParam(bytes32 param, uint256 data) external checkCaller {
        if (param == "duration") duration = data;
        else revert LinearDecrease__setParam_unrecognizedParam();
        emit SetParam(param, data);
    }

    /// ======== Pricing ======== ///

    
    
    /// Note the internal call to mul multiples by WAD, thereby ensuring that the wmul calculation
    /// which utilizes startPrice and duration (WAD values) is also a WAD value.
    
    
    
    function price(uint256 startPrice, uint256 time) external view override returns (uint256) {
        if (time >= duration) return 0;
        return wmul(startPrice, wdiv(sub(duration, time), duration));
    }
}



/// Uses StairstepExponentialDecrease.sol from DSS (MakerDAO) as a blueprint
/// Changes from StairstepExponentialDecrease.sol /:
/// - only WAD precision is used (no RAD and RAY)
/// - uses a method signature based authentication scheme
/// - supports ERC1155, ERC721 style assets by TokenId
contract StairstepExponentialDecrease is Guarded, IPriceCalculator {
    /// ======== Custom Errors ======== ///

    error StairstepExponentialDecrease__setParam_factorGtWad();
    error StairstepExponentialDecrease__setParam_unrecognizedParam();

    /// ======== Storage ======== ///
    
    uint256 public step;
    
    uint256 public factor;

    /// ======== Events ======== ///

    event SetParam(bytes32 indexed param, uint256 data);

    // `factor` and `step` values must be correctly set for this contract to return a valid price
    constructor() Guarded() {}

    /// ======== Configuration ======== ///

    
    
    
    
    function setParam(bytes32 param, uint256 data) external checkCaller {
        if (param == "factor") {
            if (data > WAD) revert StairstepExponentialDecrease__setParam_factorGtWad();
            factor = data;
        } else if (param == "step") step = data;
        else revert StairstepExponentialDecrease__setParam_unrecognizedParam();
        emit SetParam(param, data);
    }

    /// ======== Pricing ======== ///

    
    
    /// `factor` factor encodes the percentage to decrease per step.
    ///   For efficiency, the values is set as (1 - (% value / 100)) * WAD
    ///   So, for a 1% decrease per step, factor would be (1 - 0.01) * WAD
    
    
    
    function price(uint256 startPrice, uint256 time) external view override returns (uint256) {
        return wmul(startPrice, wpow(factor, time / step, WAD));
    }
}



/// While an equivalent function can be obtained by setting step = 1 in StairstepExponentialDecrease,
/// this continous (i.e. per-second) exponential decrease has be implemented as it is more gas-efficient
/// than using the stairstep version with step = 1 (primarily due to 1 fewer SLOAD per price calculation).
///
/// Uses ExponentialDecrease.sol from DSS (MakerDAO) as a blueprint
/// Changes from ExponentialDecrease.sol /:
/// - only WAD precision is used (no RAD and RAY)
/// - uses a method signature based authentication scheme
/// - supports ERC1155, ERC721 style assets by TokenId
contract ExponentialDecrease is Guarded, IPriceCalculator {
    /// ======== Custom Errors ======== ///

    error ExponentialDecrease__setParam_factorGtWad();
    error ExponentialDecrease__setParam_unrecognizedParam();

    /// ======== Storage ======== ///

    
    uint256 public factor;

    /// ======== Events ======== ///

    event SetParam(bytes32 indexed param, uint256 data);

    // `factor` value must be correctly set for this contract to return a valid price
    constructor() Guarded() {}

    /// ======== Configuration ======== ///

    
    
    
    
    function setParam(bytes32 param, uint256 data) external checkCaller {
        if (param == "factor") {
            if (data > WAD) revert ExponentialDecrease__setParam_factorGtWad();
            factor = data;
        } else revert ExponentialDecrease__setParam_unrecognizedParam();
        emit SetParam(param, data);
    }

    /// ======== Pricing ======== ///

    
    
    ///   For efficiency, the values is set as (1 - (% value / 100)) * WAD
    ///   So, for a 1% decrease per second, factor would be (1 - 0.01) * WAD
    
    
    
    function price(uint256 startPrice, uint256 time) external view override returns (uint256) {
        return wmul(startPrice, wpow(factor, time, WAD));
    }
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
}interface IGuard {
    function isGuard() external view returns (bool);
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


contract AuctionGuard is BaseGuard {
    /// ======== Custom Errors ======== ///

    error AuctionGuard__isGuard_cantCall();

    /// ======== Storage ======== ///

    
    NoLossCollateralAuction public immutable collateralAuction;

    constructor(
        address senatus,
        address guardian,
        uint256 delay,
        address collateralAuction_
    ) BaseGuard(senatus, guardian, delay) {
        collateralAuction = NoLossCollateralAuction(collateralAuction_);
    }

    function isGuard() external view override returns (bool) {
        if (!collateralAuction.canCall(collateralAuction.ANY_SIG(), address(this)))
            revert AuctionGuard__isGuard_cantCall();
        return true;
    }

    /// ======== Capabilities ======== ///

    
    
    
    function setFeeTip(uint256 feeTip) external isGuardian {
        _inRange(feeTip, 0, 1 * WAD);
        collateralAuction.setParam("feeTip", feeTip);
    }

    
    
    
    function setFlatTip(uint256 flatTip) external isGuardian {
        _inRange(flatTip, 0, 10_000 * WAD);
        collateralAuction.setParam("flatTip", flatTip);
    }

    
    
    
    function setStopped(uint256 level) external isGuardian {
        _inRange(level, 0, 3);
        collateralAuction.setParam("stopped", level);
    }

    
    
    
    function setLimes(address limes) external isDelayed {
        collateralAuction.setParam("limes", limes);
    }

    
    
    
    function setAer(address aer) external isDelayed {
        collateralAuction.setParam("aer", aer);
    }

    
    
    
    function setMultiplier(address vault, uint256 multiplier) external isGuardian {
        _inRange(multiplier, 0.9e18, 2 * WAD);
        collateralAuction.setParam(vault, "multiplier", multiplier);
    }

    
    /// on corresponding PriceCalculator
    
    
    function setMaxAuctionDuration(address vault, uint256 maxAuctionDuration) external isGuardian {
        _inRange(maxAuctionDuration, 3 hours, 5 days);
        collateralAuction.setParam(vault, "maxAuctionDuration", maxAuctionDuration);
        (, , , , IPriceCalculator calculator) = collateralAuction.vaults(vault);
        LinearDecrease(address(calculator)).setParam("duration", maxAuctionDuration);
    }

    
    
    
    
    function setCollybus(address vault, address collybus) external isDelayed {
        collateralAuction.setParam(vault, "collybus", collybus);
    }

    
    
    
    
    function setCalculator(address vault, address calculator) external isDelayed {
        collateralAuction.setParam(vault, "calculator", calculator);
    }
}