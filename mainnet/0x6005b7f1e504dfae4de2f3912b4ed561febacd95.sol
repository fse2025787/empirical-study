// SPDX-License-Identifier: AGPL-3.0-or-later

/**
 *Submitted for verification at Etherscan.io on 2022-04-13
*/

// 
pragma solidity ^0.8.4;

// Copyright (C) 2020-2021 Maker Ecosystem Growth Holdings, INC.

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


/// putting the Position's collateral up for auction
/// Uses Dog.sol from DSS (MakerDAO) as a blueprint
/// Changes from Dog.sol:
/// - only WAD precision is used (no RAD and RAY)
/// - uses a method signature based authentication scheme
/// - supports ERC1155, ERC721 style assets by TokenId
contract Limes is Guarded, ILimes {
    /// ======== Custom Errors ======== ///

    error Limes__setParam_liquidationPenaltyLtWad();
    error Limes__setParam_unrecognizedParam();
    error Limes__liquidate_notLive();
    error Limes__liquidate_notUnsafe();
    error Limes__liquidate_maxDebtOnAuction();
    error Limes__liquidate_dustyAuctionFromPartialLiquidation();
    error Limes__liquidate_nullAuction();
    error Limes__liquidate_overflow();

    /// ======== Storage ======== ///

    // Vault specific configuration data
    struct VaultConfig {
        // Auction contract for collateral
        address collateralAuction;
        // Liquidation penalty [wad]
        uint256 liquidationPenalty;
        // Max credit needed to cover debt+fees of active auctions per vault [wad]
        uint256 maxDebtOnAuction;
        // Amount of credit needed to cover debt+fees for all active auctions per vault [wad]
        uint256 debtOnAuction;
    }

    
    
    mapping(address => VaultConfig) public override vaults;

    
    ICodex public immutable override codex;
    
    IAer public override aer;

    
    uint256 public override globalMaxDebtOnAuction;
    
    uint256 public override globalDebtOnAuction;

    
    uint256 public override live;

    /// ======== Events ======== ///

    event SetParam(bytes32 indexed param, uint256 data);
    event SetParam(bytes32 indexed param, address data);
    event SetParam(address indexed vault, bytes32 indexed param, uint256 data);
    event SetParam(address indexed vault, bytes32 indexed param, address collateralAuction);

    event Liquidate(
        address indexed vault,
        uint256 indexed tokenId,
        address position,
        uint256 collateral,
        uint256 normalDebt,
        uint256 due,
        address collateralAuction,
        uint256 indexed auctionId
    );
    event Liquidated(address indexed vault, uint256 indexed tokenId, uint256 debt);
    event Lock();

    constructor(address codex_) Guarded() {
        codex = ICodex(codex_);
        live = 1;
    }

    /// ======== Configuration ======== ///

    
    
    
    
    function setParam(bytes32 param, address data) external override checkCaller {
        if (param == "aer") aer = IAer(data);
        else revert Limes__setParam_unrecognizedParam();
        emit SetParam(param, data);
    }

    
    
    
    
    function setParam(bytes32 param, uint256 data) external override checkCaller {
        if (param == "globalMaxDebtOnAuction") globalMaxDebtOnAuction = data;
        else revert Limes__setParam_unrecognizedParam();
        emit SetParam(param, data);
    }

    
    
    
    
    
    function setParam(
        address vault,
        bytes32 param,
        uint256 data
    ) external override checkCaller {
        if (param == "liquidationPenalty") {
            if (data < WAD) revert Limes__setParam_liquidationPenaltyLtWad();
            vaults[vault].liquidationPenalty = data;
        } else if (param == "maxDebtOnAuction") vaults[vault].maxDebtOnAuction = data;
        else revert Limes__setParam_unrecognizedParam();
        emit SetParam(vault, param, data);
    }

    
    
    
    
    
    function setParam(
        address vault,
        bytes32 param,
        address data
    ) external override checkCaller {
        if (param == "collateralAuction") {
            vaults[vault].collateralAuction = data;
        } else revert Limes__setParam_unrecognizedParam();
        emit SetParam(vault, param, data);
    }

    /// ======== Liquidations ======== ///

    
    
    
    function liquidationPenalty(address vault) external view override returns (uint256) {
        return vaults[vault].liquidationPenalty;
    }

    
    
    /// The entire Position will be liquidated except when the target amount of credit to be raised in
    /// the resulting auction (debt of Position + liquidation penalty) causes either globalDebtOnAuction to exceed
    /// globalMaxDebtOnAuction or vault.debtOnAuction to exceed vault.maxDebtOnAuction by an economically
    /// significant amount. In that case, a partial liquidation is performed to respect the global and per-vault limits
    /// on outstanding credit target. The one exception is if the resulting auction would likely
    /// have too little collateral to be of interest to Keepers (debt taken from Position < vault.debtFloor),
    /// in which case the function reverts. Please refer to the code and comments within if more detail is desired.
    
    
    
    
    
    function liquidate(
        address vault,
        uint256 tokenId,
        address position,
        address keeper
    ) external override returns (uint256 auctionId) {
        if (live == 0) revert Limes__liquidate_notLive();

        VaultConfig memory mvault = vaults[vault];
        uint256 deltaNormalDebt;
        uint256 rate;
        uint256 debtFloor;
        uint256 deltaCollateral;
        unchecked {
            {
                (uint256 collateral, uint256 normalDebt) = codex.positions(vault, tokenId, position);
                uint256 price = IVault(vault).fairPrice(tokenId, true, false);
                (, rate, , debtFloor) = codex.vaults(vault);
                if (price == 0 || mul(collateral, price) >= mul(normalDebt, rate)) revert Limes__liquidate_notUnsafe();

                // Get the minimum value between:
                // 1) Remaining space in the globalMaxDebtOnAuction
                // 2) Remaining space in the vault.maxDebtOnAuction
                if (!(globalMaxDebtOnAuction > globalDebtOnAuction && mvault.maxDebtOnAuction > mvault.debtOnAuction))
                    revert Limes__liquidate_maxDebtOnAuction();

                uint256 room = min(
                    globalMaxDebtOnAuction - globalDebtOnAuction,
                    mvault.maxDebtOnAuction - mvault.debtOnAuction
                );

                // normalize room by subtracting rate and liquidationPenalty
                deltaNormalDebt = min(normalDebt, (((room * WAD) / rate) * WAD) / mvault.liquidationPenalty);

                // Partial liquidation edge case logic
                if (normalDebt > deltaNormalDebt) {
                    if (wmul(normalDebt - deltaNormalDebt, rate) < debtFloor) {
                        // If the leftover Position would be dusty, just liquidate it entirely.
                        // This will result in at least one of v.debtOnAuction > v.maxDebtOnAuction or
                        // globalDebtOnAuction > globalMaxDebtOnAuction becoming true. The amount of excess will
                        // be bounded above by ceiling(v.debtFloor * v.liquidationPenalty / WAD). This deviation is
                        // assumed to be small compared to both v.maxDebtOnAuction and globalMaxDebtOnAuction, so that
                        // the extra amount of credit is not of economic concern.
                        deltaNormalDebt = normalDebt;
                    } else {
                        // In a partial liquidation, the resulting auction should also be non-dusty.
                        if (wmul(deltaNormalDebt, rate) < debtFloor)
                            revert Limes__liquidate_dustyAuctionFromPartialLiquidation();
                    }
                }

                deltaCollateral = mul(collateral, deltaNormalDebt) / normalDebt;
            }
        }

        if (deltaCollateral == 0) revert Limes__liquidate_nullAuction();
        if (!(deltaNormalDebt <= 2**255 && deltaCollateral <= 2**255)) revert Limes__liquidate_overflow();

        codex.confiscateCollateralAndDebt(
            vault,
            tokenId,
            position,
            mvault.collateralAuction,
            address(aer),
            -int256(deltaCollateral),
            -int256(deltaNormalDebt)
        );

        uint256 due = wmul(deltaNormalDebt, rate);
        aer.queueDebt(due);

        {
            // Avoid stack too deep
            // This calcuation will overflow if deltaNormalDebt*rate exceeds ~10^14
            uint256 debt = wmul(due, mvault.liquidationPenalty);
            globalDebtOnAuction = add(globalDebtOnAuction, debt);
            vaults[vault].debtOnAuction = add(mvault.debtOnAuction, debt);

            auctionId = ICollateralAuction(mvault.collateralAuction).startAuction({
                debt: debt,
                collateralToSell: deltaCollateral,
                vault: vault,
                tokenId: tokenId,
                user: position,
                keeper: keeper
            });
        }

        emit Liquidate(
            vault,
            tokenId,
            position,
            deltaCollateral,
            deltaNormalDebt,
            due,
            mvault.collateralAuction,
            auctionId
        );
    }

    
    
    
    
    
    function liquidated(
        address vault,
        uint256 tokenId,
        uint256 debt
    ) external override checkCaller {
        globalDebtOnAuction = sub(globalDebtOnAuction, debt);
        vaults[vault].debtOnAuction = sub(vaults[vault].debtOnAuction, debt);
        emit Liquidated(vault, tokenId, debt);
    }

    /// ======== Shutdown ======== ///

    
    
    function lock() external override checkCaller {
        live = 0;
        emit Lock();
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

    
    address public senatus;
    
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

    
    
    
    function setSenatus(address senatus_) external isSenatus {
        senatus = senatus_;
    }

    
    
    
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


contract LimesGuard is BaseGuard {
    /// ======== Custom Errors ======== ///

    error LimesGuard__isGuard_cantCall();

    /// ======== Storage ======== ///

    
    Limes public immutable limes;

    constructor(
        address senatus,
        address guardian,
        uint256 delay,
        address limes_
    ) BaseGuard(senatus, guardian, delay) {
        limes = Limes(limes_);
    }

    
    function isGuard() external view override returns (bool) {
        if (!limes.canCall(limes.ANY_SIG(), address(this))) revert LimesGuard__isGuard_cantCall();
        return true;
    }

    /// ======== Capabilities ======== ///

    
    
    
    function setAer(address aer) external isDelayed {
        limes.setParam("aer", aer);
    }

    
    
    
    function setGlobalMaxDebtOnAuction(uint256 globalMaxDebtOnAuction) external isGuardian {
        _inRange(globalMaxDebtOnAuction, 0, 10_000_000 * WAD);
        limes.setParam("globalMaxDebtOnAuction", globalMaxDebtOnAuction);
    }

    
    
    
    
    function setLiquidationPenalty(address vault, uint256 liquidationPenalty) external isGuardian {
        _inRange(liquidationPenalty, WAD, 2 * WAD);
        limes.setParam(vault, "liquidationPenalty", liquidationPenalty);
    }

    
    
    
    
    function setMaxDebtOnAuction(address vault, uint256 maxDebtOnAuction) external isGuardian {
        _inRange(maxDebtOnAuction, 0, 5_000_000 * WAD);
        limes.setParam(vault, "maxDebtOnAuction", maxDebtOnAuction);
    }

    
    
    
    
    function setCollateralAuction(address vault, address collateralAuction) external isDelayed {
        limes.setParam(vault, "collateralAuction", collateralAuction);
        limes.allowCaller(limes.liquidated.selector, collateralAuction);
    }
}