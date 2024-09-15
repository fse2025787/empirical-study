// SPDX-License-Identifier: AGPL-3.0-or-later

/**
 *Submitted for verification at Etherscan.io on 2022-04-04
*/

// 
// Copyright (C) 2018 Rain <[email protected]>
// Copyright (C) 2018 Lev Livnev <[email protected]>
// Copyright (C) 2020-2021 Maker Ecosystem Growth Holdings, INC.
pragma solidity ^0.8.4;

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
}interface IPriceCalculator {
    // 1st arg: initial price [wad]
    // 2nd arg: seconds since auction start [seconds]
    // returns: current auction price [wad]
    function price(uint256, uint256) external view returns (uint256);
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
}interface ITenebrae {
    function codex() external view returns (ICodex);

    function limes() external view returns (ILimes);

    function aer() external view returns (IAer);

    function collybus() external view returns (ICollybus);

    function live() external view returns (uint256);

    function lockedAt() external view returns (uint256);

    function cooldownDuration() external view returns (uint256);

    function debt() external view returns (uint256);

    function lostCollateral(address, uint256) external view returns (uint256);

    function normalDebtByTokenId(address, uint256) external view returns (uint256);

    function claimed(
        address,
        uint256,
        address
    ) external view returns (uint256);

    function setParam(bytes32 param, address data) external;

    function setParam(bytes32 param, uint256 data) external;

    function lockPrice(address vault, uint256 tokenId) external view returns (uint256);

    function redemptionPrice(address vault, uint256 tokenId) external view returns (uint256);

    function lock() external;

    function skipAuction(address vault, uint256 auctionId) external;

    function offsetPosition(
        address vault,
        uint256 tokenId,
        address user
    ) external;

    function closePosition(address vault, uint256 tokenId) external;

    function fixGlobalDebt() external;

    function redeem(
        address vault,
        uint256 tokenId,
        uint256 credit
    ) external;
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


/// place over nine steps.
///
/// Uses End.sol from DSS (MakerDAO) / GlobalSettlement SafeEngine.sol from GEB (Reflexer Labs) as a blueprint
/// Changes from End.sol / GlobalSettlement.sol:
/// - only WAD precision is used (no RAD and RAY)
/// - uses a method signature based authentication scheme
/// - supports ERC1155, ERC721 style assets by TokenId
///

/// First we freeze the system and lock the prices for each vault and TokenId.
///
/// 1. `lock()`:
///     - freezes user entrypoints
///     - cancels debtAuction/surplusAuction auctions
///     - starts cooldown period
///
/// We must process some system state before it is possible to calculate
/// the final credit / collateral price. In particular, we need to determine
///
///     a. `debt`, the outstanding credit supply after including system surplus / deficit
///
///     b. `lostCollateral`, the collateral shortfall per collateral type by
///     considering under-collateralised Positions.
///
/// We determine (a) by processing ongoing credit generating processes,
/// i.e. auctions. We need to ensure that auctions will not generate any
/// further credit income.
///
/// In the case of the Dutch Auctions model (CollateralAuction) they keep recovering
/// debt during the whole lifetime and there isn't a max duration time
/// guaranteed for the auction to end.
/// So the way to ensure the protocol will not receive extra credit income is:
///
///     2a. i) `skipAuctions`: cancel all ongoing auctions and seize the collateral.
///
///         `skipAuctions(vault, id)`:
///          - cancel individual running collateralAuction auctions
///          - retrieves remaining collateral and debt (including penalty) to owner's Position
///
/// We determine (b) by processing all under-collateralised Positions with `offsetPosition`:
///
/// 3. `offsetPosition(vault, tokenId, position)`:
///     - cancels the Position's debt with an equal amount of collateral
///
/// When a Position has been processed and has no debt remaining, the
/// remaining collateral can be removed.
///
/// 4. `closePosition(vault)`:
///     - remove collateral from the caller's Position
///     - owner can call as needed
///
/// After the processing period has elapsed, we enable calculation of
/// the final price for each collateral type.
///
/// 5. `fixGlobalDebt()`:
///     - only callable after processing time period elapsed
///     - assumption that all under-collateralised Positions are processed
///     - fixes the total outstanding supply of credit
///     - may also require extra Position processing to cover aer surplus
///
/// At this point we have computed the final price for each collateral
/// type and credit holders can now turn their credit into collateral. Each
/// unit credit can claim a fixed basket of collateral.
///
/// Finally, collateral can be obtained with `redeem`.
///
/// 6. `redeem(vault, tokenId wad)`:
///     - exchange some credit for collateral tokens from a specific vault and tokenId
contract Tenebrae is Guarded, ITenebrae {
    /// ======== Custom Errors ======== ///

    error Tenebrae__setParam_notLive();
    error Tenebrae__setParam_unknownParam();
    error Tenebrae__lock_notLive();
    error Tenebrae__skipAuction_debtNotZero();
    error Tenebrae__skipAuction_overflow();
    error Tenebrae__offsetPosition_debtNotZero();
    error Tenebrae__offsetPosition_overflow();
    error Tenebrae__closePosition_stillLive();
    error Tenebrae__closePosition_debtNotZero();
    error Tenebrae__closePosition_normalDebtNotZero();
    error Tenebrae__closePosition_overflow();
    error Tenebrae__fixGlobalDebt_stillLive();
    error Tenebrae__fixGlobalDebt_debtNotZero();
    error Tenebrae__fixGlobalDebt_surplusNotZero();
    error Tenebrae__fixGlobalDebt_cooldownNotFinished();
    error Tenebrae__redeem_redemptionPriceZero();

    /// ======== Storage ======== ///

    
    ICodex public override codex;
    
    ILimes public override limes;
    
    IAer public override aer;
    
    ICollybus public override collybus;

    
    uint256 public override lockedAt;
    
    uint256 public override cooldownDuration;
    
    uint256 public override debt;

    
    uint256 public override live;

    
    
    mapping(address => mapping(uint256 => uint256)) public override lostCollateral;
    
    
    mapping(address => mapping(uint256 => uint256)) public override normalDebtByTokenId;
    
    
    mapping(address => mapping(uint256 => mapping(address => uint256))) public override claimed;

    /// ======== Events ======== ///

    event SetParam(bytes32 indexed param, uint256 data);
    event SetParam(bytes32 indexed param, address data);

    event Lock();
    event SkipAuction(
        uint256 indexed auctionId,
        address vault,
        uint256 tokenId,
        address indexed user,
        uint256 debt,
        uint256 collateralToSell,
        uint256 normalDebt
    );
    event SettlePosition(
        address indexed vault,
        uint256 indexed tokenId,
        address indexed user,
        uint256 settledCollateral,
        uint256 normalDebt
    );
    event ClosePosition(
        address indexed vault,
        uint256 indexed tokenId,
        address indexed user,
        uint256 collateral,
        uint256 normalDebt
    );
    event FixGlobalDebt();
    event Redeem(address indexed vault, uint256 indexed tokenId, address indexed user, uint256 credit);

    constructor() Guarded() {
        live = 1;
    }

    /// ======== Configuration ======== ///

    
    
    
    
    function setParam(bytes32 param, address data) external override checkCaller {
        if (live == 0) revert Tenebrae__setParam_notLive();
        if (param == "codex") codex = ICodex(data);
        else if (param == "limes") limes = ILimes(data);
        else if (param == "aer") aer = IAer(data);
        else if (param == "collybus") collybus = ICollybus(data);
        else revert Tenebrae__setParam_unknownParam();
        emit SetParam(param, data);
    }

    
    
    
    
    function setParam(bytes32 param, uint256 data) external override checkCaller {
        if (live == 0) revert Tenebrae__setParam_notLive();
        if (param == "cooldownDuration") cooldownDuration = data;
        else revert Tenebrae__setParam_unknownParam();
        emit SetParam(param, data);
    }

    /// ======== Shutdown ======== ///

    
    
    
    
    
    function lockPrice(address vault, uint256 tokenId) public view override returns (uint256) {
        return wdiv(collybus.redemptionPrice(), IVault(vault).fairPrice(tokenId, false, true));
    }

    
    
    
    
    function redemptionPrice(address vault, uint256 tokenId) public view override returns (uint256) {
        if (debt == 0) return 0;
        (, uint256 rate, , ) = codex.vaults(vault);
        uint256 collateral = wmul(wmul(normalDebtByTokenId[vault][tokenId], rate), lockPrice(vault, tokenId));
        return wdiv(sub(collateral, lostCollateral[vault][tokenId]), wmul(debt, WAD));
    }

    
    
    function lock() external override checkCaller {
        if (live == 0) revert Tenebrae__lock_notLive();
        live = 0;
        lockedAt = block.timestamp;
        codex.lock();
        limes.lock();
        aer.lock();
        collybus.lock();
        emit Lock();
    }

    
    
    
    
    function skipAuction(address vault, uint256 auctionId) external override {
        if (debt != 0) revert Tenebrae__skipAuction_debtNotZero();
        (address _collateralAuction, , , ) = limes.vaults(vault);
        ICollateralAuction collateralAuction = ICollateralAuction(_collateralAuction);
        (, uint256 rate, , ) = codex.vaults(vault);
        (, uint256 debt_, uint256 collateralToSell, , uint256 tokenId, address user, , ) = collateralAuction.auctions(
            auctionId
        );
        codex.createUnbackedDebt(address(aer), address(aer), debt_);
        collateralAuction.cancelAuction(auctionId);
        uint256 normalDebt = wdiv(debt_, rate);
        if (!(int256(collateralToSell) >= 0 && int256(normalDebt) >= 0)) revert Tenebrae__skipAuction_overflow();
        codex.confiscateCollateralAndDebt(
            vault,
            tokenId,
            user,
            address(this),
            address(aer),
            int256(collateralToSell),
            int256(normalDebt)
        );
        emit SkipAuction(auctionId, vault, tokenId, user, debt_, collateralToSell, normalDebt);
    }

    
    
    
    
    
    function offsetPosition(
        address vault,
        uint256 tokenId,
        address user
    ) external override {
        if (debt != 0) revert Tenebrae__offsetPosition_debtNotZero();
        (, uint256 rate, , ) = codex.vaults(vault);
        (uint256 collateral, uint256 normalDebt) = codex.positions(vault, tokenId, user);
        // get price at maturity
        uint256 owedCollateral = wdiv(wmul(normalDebt, rate), IVault(vault).fairPrice(tokenId, false, true));
        uint256 offsetCollateral;
        if (owedCollateral > collateral) {
            // owing more collateral than the Position has
            lostCollateral[vault][tokenId] = add(lostCollateral[vault][tokenId], sub(owedCollateral, collateral));
            offsetCollateral = collateral;
        } else {
            offsetCollateral = owedCollateral;
        }
        normalDebtByTokenId[vault][tokenId] = add(normalDebtByTokenId[vault][tokenId], normalDebt);
        if (!(offsetCollateral <= 2**255 && normalDebt <= 2**255)) revert Tenebrae__offsetPosition_overflow();
        codex.confiscateCollateralAndDebt(
            vault,
            tokenId,
            user,
            address(this),
            address(aer),
            -int256(offsetCollateral),
            -int256(normalDebt)
        );
        emit SettlePosition(vault, tokenId, user, offsetCollateral, normalDebt);
    }

    
    
    
    
    function closePosition(address vault, uint256 tokenId) external override {
        if (live != 0) revert Tenebrae__closePosition_stillLive();
        if (debt != 0) revert Tenebrae__closePosition_debtNotZero();
        (uint256 collateral, uint256 normalDebt) = codex.positions(vault, tokenId, msg.sender);
        if (normalDebt != 0) revert Tenebrae__closePosition_normalDebtNotZero();
        normalDebtByTokenId[vault][tokenId] = add(normalDebtByTokenId[vault][tokenId], normalDebt);
        if (collateral > 2**255) revert Tenebrae__closePosition_overflow();
        codex.confiscateCollateralAndDebt(vault, tokenId, msg.sender, msg.sender, address(aer), -int256(collateral), 0);
        emit ClosePosition(vault, tokenId, msg.sender, collateral, normalDebt);
    }

    
    
    function fixGlobalDebt() external override {
        if (live != 0) revert Tenebrae__fixGlobalDebt_stillLive();
        if (debt != 0) revert Tenebrae__fixGlobalDebt_debtNotZero();
        if (codex.credit(address(aer)) != 0) revert Tenebrae__fixGlobalDebt_surplusNotZero();
        if (block.timestamp < add(lockedAt, cooldownDuration)) revert Tenebrae__fixGlobalDebt_cooldownNotFinished();
        debt = codex.globalDebt();
        emit FixGlobalDebt();
    }

    
    
    
    
    
    function redeem(
        address vault,
        uint256 tokenId,
        uint256 credit // credit amount
    ) external override {
        uint256 price = redemptionPrice(vault, tokenId);
        if (price == 0) revert Tenebrae__redeem_redemptionPriceZero();
        codex.transferCredit(msg.sender, address(aer), credit);
        aer.settleDebtWithSurplus(credit);
        codex.transferBalance(vault, tokenId, address(this), msg.sender, wmul(credit, price));
        claimed[vault][tokenId][msg.sender] = add(claimed[vault][tokenId][msg.sender], credit);
        emit Redeem(vault, tokenId, msg.sender, credit);
    }
}