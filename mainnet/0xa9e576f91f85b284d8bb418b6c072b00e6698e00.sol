// SPDX-License-Identifier: AGPL-3.0


// 

pragma solidity ^0.8.13;




// the behavioral Swivel Interface, Implemented by Swivel.sol
interface ISwivel {
    function initiate(
        Hash.Order[] calldata,
        uint256[] calldata,
        Sig.Components[] calldata
    ) external returns (bool);

    function exit(
        Hash.Order[] calldata,
        uint256[] calldata,
        Sig.Components[] calldata
    ) external returns (bool);

    function cancel(Hash.Order[] calldata) external returns (bool);

    function setAdmin(address) external returns (bool);

    function scheduleWithdrawal(address) external returns (bool);

    function scheduleFeeChange(uint16[4] calldata) external returns (bool);

    function blockWithdrawal(address) external returns (bool);

    function blockFeeChange() external returns (bool);

    function withdraw(address) external returns (bool);

    function changeFee(uint16[4] calldata) external returns (bool);

    function approveUnderlying(address[] calldata, address[] calldata)
        external
        returns (bool);

    function splitUnderlying(
        uint8,
        address,
        uint256,
        uint256
    ) external returns (bool);

    function combineTokens(
        uint8,
        address,
        uint256,
        uint256
    ) external returns (bool);

    function authRedeem(
        uint8,
        address,
        address,
        address,
        uint256
    ) external returns (bool);

    function redeemZcToken(
        uint8,
        address,
        uint256,
        uint256
    ) external returns (bool);

    function redeemVaultInterest(
        uint8,
        address,
        uint256
    ) external returns (bool);

    function redeemSwivelVaultInterest(
        uint8,
        address,
        uint256
    ) external returns (bool);
}
// 

pragma solidity 0.8.16;

















contract Swivel is ISwivel {
    
    /// an error code value whose string representation is documented <here>, and any possible other values
    /// that are pertinent to the error.
    error Exception(uint8, uint256, uint256, address, address);
    
    mapping(bytes32 => bool) public cancelled;
    
    mapping(bytes32 => uint256) public filled;
    
    mapping(address => uint256) public withdrawals;
    
    mapping(address => uint256) public approvals;

    string public constant NAME = 'Swivel Finance';
    string public constant VERSION = '3.0.0';
    uint256 public constant HOLD = 3 days;
    
    uint256 public feeChange;
    bytes32 public immutable domain;
    address public immutable marketPlace;
    address public admin;

    
    address public immutable aaveAddr;

    uint16 public constant MIN_FEENOMINATOR = 33;
    
    uint16[4] public feenominators = [200, 600, 400, 200];

    
    event Cancel(bytes32 indexed key, bytes32 hash);
    
    
    
    event Initiate(
        bytes32 indexed key,
        bytes32 hash,
        address indexed maker,
        bool vault,
        bool exit,
        address indexed sender,
        uint256 amount,
        uint256 filled
    );
    
    
    
    event Exit(
        bytes32 indexed key,
        bytes32 hash,
        address indexed maker,
        bool vault,
        bool exit,
        address indexed sender,
        uint256 amount,
        uint256 filled
    );
    
    event ScheduleWithdrawal(address indexed token, uint256 hold);
    
    event ScheduleApproval(address indexed token, uint256 hold);
    
    event ScheduleFeeChange(uint16[4] proposal, uint256 hold);
    
    event BlockWithdrawal(address indexed token);
    
    event BlockApproval(address indexed token);
    
    event BlockFeeChange();
    
    event ChangeFee(uint256 indexed index, uint256 indexed value);
    event SetAdmin(address indexed admin);

    
    
    constructor(address m, address a) {
        admin = msg.sender;
        domain = Hash.domain(NAME, VERSION, block.chainid, address(this));
        marketPlace = m;
        aaveAddr = a;
    }

    // ********* INITIATING *************

    
    
    
    
    function initiate(
        Hash.Order[] calldata o,
        uint256[] calldata a,
        Sig.Components[] calldata c
    ) external returns (bool) {
        // for each order filled, routes the order to the right interaction depending on its params
        for (uint256 i; i != o.length; ) {
            if (!o[i].exit) {
                if (!o[i].vault) {
                    initiateVaultFillingZcTokenInitiate(o[i], a[i], c[i]);
                } else {
                    initiateZcTokenFillingVaultInitiate(o[i], a[i], c[i]);
                }
            } else {
                if (!o[i].vault) {
                    initiateZcTokenFillingZcTokenExit(o[i], a[i], c[i]);
                } else {
                    initiateVaultFillingVaultExit(o[i], a[i], c[i]);
                }
            }

            unchecked {
                ++i;
            }
        }

        return true;
    }

    
    
    
    
    
    function initiateVaultFillingZcTokenInitiate(
        Hash.Order calldata o,
        uint256 a,
        Sig.Components calldata c
    ) internal {
        // checks order signature, order cancellation and order expiry
        bytes32 hash = validOrderHash(o, c);

        // checks the side, and the amount compared to available
        uint256 amount = a + filled[hash];

        if (amount > o.premium) {
            revert Exception(5, amount, o.premium, address(0), address(0));
        }

        filled[hash] = amount;

        // transfer underlying tokens
        IERC20 uToken = IERC20(o.underlying);
        Safe.transferFrom(uToken, msg.sender, o.maker, a);

        uint256 principalFilled = (a * o.principal) / o.premium;
        Safe.transferFrom(uToken, o.maker, address(this), principalFilled);

        IMarketPlace mPlace = IMarketPlace(marketPlace);
        address cTokenAddr = mPlace.cTokenAddress(
            o.protocol,
            o.underlying,
            o.maturity
        );

        // perform the actual deposit type transaction, specific to a protocol
        if (!deposit(o.protocol, o.underlying, cTokenAddr, principalFilled)) {
            revert Exception(6, 0, 0, address(0), address(0));
        }

        // alert marketplace
        if (
            !mPlace.custodialInitiate(
                o.protocol,
                o.underlying,
                o.maturity,
                o.maker,
                msg.sender,
                principalFilled
            )
        ) {
            revert Exception(8, 0, 0, address(0), address(0));
        }

        // transfer fee in vault notional to swivel (from msg.sender)
        uint256 fee = principalFilled / feenominators[2];
        if (
            !mPlace.transferVaultNotionalFee(
                o.protocol,
                o.underlying,
                o.maturity,
                msg.sender,
                fee
            )
        ) {
            revert Exception(10, 0, 0, address(0), address(0));
        }

        emit Initiate(
            o.key,
            hash,
            o.maker,
            o.vault,
            o.exit,
            msg.sender,
            a,
            principalFilled
        );
    }

    
    
    
    
    
    function initiateZcTokenFillingVaultInitiate(
        Hash.Order calldata o,
        uint256 a,
        Sig.Components calldata c
    ) internal {
        bytes32 hash = validOrderHash(o, c);
        uint256 amount = a + filled[hash];

        if (amount > o.principal) {
            revert Exception(5, amount, o.principal, address(0), address(0));
        }

        filled[hash] = amount;

        IERC20 uToken = IERC20(o.underlying);

        uint256 premiumFilled = (a * o.premium) / o.principal;
        Safe.transferFrom(uToken, o.maker, msg.sender, premiumFilled);

        // transfer principal + fee in underlying to swivel (from sender)
        uint256 fee = premiumFilled / feenominators[0];
        Safe.transferFrom(uToken, msg.sender, address(this), (a + fee));

        IMarketPlace mPlace = IMarketPlace(marketPlace);
        address cTokenAddr = mPlace.cTokenAddress(
            o.protocol,
            o.underlying,
            o.maturity
        );

        // perform the actual deposit type transaction, specific to a protocol
        if (!deposit(o.protocol, o.underlying, cTokenAddr, a)) {
            revert Exception(6, 0, 0, address(0), address(0));
        }

        // alert marketplace
        if (
            !mPlace.custodialInitiate(
                o.protocol,
                o.underlying,
                o.maturity,
                msg.sender,
                o.maker,
                a
            )
        ) {
            revert Exception(8, 0, 0, address(0), address(0));
        }

        emit Initiate(
            o.key,
            hash,
            o.maker,
            o.vault,
            o.exit,
            msg.sender,
            a,
            premiumFilled
        );
    }

    
    
    
    
    
    function initiateZcTokenFillingZcTokenExit(
        Hash.Order calldata o,
        uint256 a,
        Sig.Components calldata c
    ) internal {
        bytes32 hash = validOrderHash(o, c);
        uint256 amount = a + filled[hash];

        if (amount > o.principal) {
            revert Exception(5, amount, o.principal, address(0), address(0));
        }

        filled[hash] = amount;

        uint256 premiumFilled = (a * o.premium) / o.principal;

        IERC20 uToken = IERC20(o.underlying);
        // transfer underlying tokens, then take fee
        Safe.transferFrom(uToken, msg.sender, o.maker, a - premiumFilled);

        uint256 fee = premiumFilled / feenominators[0];
        Safe.transferFrom(uToken, msg.sender, address(this), fee);

        // alert marketplace
        if (
            !IMarketPlace(marketPlace).p2pZcTokenExchange(
                o.protocol,
                o.underlying,
                o.maturity,
                o.maker,
                msg.sender,
                a
            )
        ) {
            revert Exception(11, 0, 0, address(0), address(0));
        }

        emit Initiate(
            o.key,
            hash,
            o.maker,
            o.vault,
            o.exit,
            msg.sender,
            a,
            premiumFilled
        );
    }

    
    
    
    
    
    function initiateVaultFillingVaultExit(
        Hash.Order calldata o,
        uint256 a,
        Sig.Components calldata c
    ) internal {
        bytes32 hash = validOrderHash(o, c);
        uint256 amount = a + filled[hash];

        if (amount > o.premium) {
            revert Exception(5, amount, o.premium, address(0), address(0));
        }

        filled[hash] = amount;

        Safe.transferFrom(IERC20(o.underlying), msg.sender, o.maker, a);

        IMarketPlace mPlace = IMarketPlace(marketPlace);
        uint256 principalFilled = (a * o.principal) / o.premium;
        // alert marketplace
        if (
            !mPlace.p2pVaultExchange(
                o.protocol,
                o.underlying,
                o.maturity,
                o.maker,
                msg.sender,
                principalFilled
            )
        ) {
            revert Exception(12, 0, 0, address(0), address(0));
        }

        // transfer fee (in vault notional) to swivel
        uint256 fee = principalFilled / feenominators[2];
        if (
            !mPlace.transferVaultNotionalFee(
                o.protocol,
                o.underlying,
                o.maturity,
                msg.sender,
                fee
            )
        ) {
            revert Exception(10, 0, 0, address(0), address(0));
        }

        emit Initiate(
            o.key,
            hash,
            o.maker,
            o.vault,
            o.exit,
            msg.sender,
            a,
            principalFilled
        );
    }

    // ********* EXITING ***************

    
    
    
    
    function exit(
        Hash.Order[] calldata o,
        uint256[] calldata a,
        Sig.Components[] calldata c
    ) external returns (bool) {
        // for each order filled, routes the order to the right interaction depending on its params
        for (uint256 i; i != o.length; ) {
            // if the order being filled is not an exit
            if (!o[i].exit) {
                // if the order being filled is a vault initiate or a zcToken initiate
                if (!o[i].vault) {
                    // if filling a zcToken initiate with an exit, one is exiting zcTokens
                    exitZcTokenFillingZcTokenInitiate(o[i], a[i], c[i]);
                } else {
                    // if filling a vault initiate with an exit, one is exiting vault notional
                    exitVaultFillingVaultInitiate(o[i], a[i], c[i]);
                }
            } else {
                // if the order being filled is a vault exit or a zcToken exit
                if (!o[i].vault) {
                    // if filling a zcToken exit with an exit, one is exiting vault
                    exitVaultFillingZcTokenExit(o[i], a[i], c[i]);
                } else {
                    // if filling a vault exit with an exit, one is exiting zcTokens
                    exitZcTokenFillingVaultExit(o[i], a[i], c[i]);
                }
            }

            unchecked {
                ++i;
            }
        }

        return true;
    }

    
    
    
    
    
    function exitZcTokenFillingZcTokenInitiate(
        Hash.Order calldata o,
        uint256 a,
        Sig.Components calldata c
    ) internal {
        bytes32 hash = validOrderHash(o, c);
        uint256 amount = a + filled[hash];

        if (amount > o.premium) {
            revert Exception(5, amount, o.premium, address(0), address(0));
        }

        filled[hash] = amount;

        IERC20 uToken = IERC20(o.underlying);

        uint256 principalFilled = (a * o.principal) / o.premium;
        // transfer underlying from initiating party to exiting party, minus the price the exit party pays for the exit (premium), and the fee.
        Safe.transferFrom(uToken, o.maker, msg.sender, principalFilled - a);

        // transfer fee in underlying to swivel
        uint256 fee = principalFilled / feenominators[1];

        Safe.transferFrom(uToken, msg.sender, address(this), fee);

        // alert marketplace
        if (
            !IMarketPlace(marketPlace).p2pZcTokenExchange(
                o.protocol,
                o.underlying,
                o.maturity,
                msg.sender,
                o.maker,
                principalFilled
            )
        ) {
            revert Exception(11, 0, 0, address(0), address(0));
        }

        emit Exit(
            o.key,
            hash,
            o.maker,
            o.vault,
            o.exit,
            msg.sender,
            a,
            principalFilled
        );
    }

    
    
    
    
    
    function exitVaultFillingVaultInitiate(
        Hash.Order calldata o,
        uint256 a,
        Sig.Components calldata c
    ) internal {
        bytes32 hash = validOrderHash(o, c);
        uint256 amount = a + filled[hash];

        if (amount > o.principal) {
            revert Exception(5, amount, o.principal, address(0), address(0));
        }

        filled[hash] = amount;

        IERC20 uToken = IERC20(o.underlying);

        // transfer premium from maker to sender
        uint256 premiumFilled = (a * o.premium) / o.principal;
        Safe.transferFrom(uToken, o.maker, msg.sender, premiumFilled);

        uint256 fee = premiumFilled / feenominators[3];
        // transfer fee in underlying to swivel from sender
        Safe.transferFrom(uToken, msg.sender, address(this), fee);

        // transfer <a> notional from sender to maker
        if (
            !IMarketPlace(marketPlace).p2pVaultExchange(
                o.protocol,
                o.underlying,
                o.maturity,
                msg.sender,
                o.maker,
                a
            )
        ) {
            revert Exception(12, 0, 0, address(0), address(0));
        }

        emit Exit(
            o.key,
            hash,
            o.maker,
            o.vault,
            o.exit,
            msg.sender,
            a,
            premiumFilled
        );
    }

    
    
    
    
    
    function exitVaultFillingZcTokenExit(
        Hash.Order calldata o,
        uint256 a,
        Sig.Components calldata c
    ) internal {
        bytes32 hash = validOrderHash(o, c);
        uint256 amount = a + filled[hash];

        if (amount > o.principal) {
            revert Exception(5, amount, o.principal, address(0), address(0));
        }

        filled[hash] = amount;

        // redeem underlying on Compound and burn cTokens
        IMarketPlace mPlace = IMarketPlace(marketPlace);
        address cTokenAddr = mPlace.cTokenAddress(
            o.protocol,
            o.underlying,
            o.maturity
        );

        if (!withdraw(o.protocol, o.underlying, cTokenAddr, a)) {
            revert Exception(7, 0, 0, address(0), address(0));
        }

        IERC20 uToken = IERC20(o.underlying);
        // transfer principal-premium  back to fixed exit party now that the interest coupon and zcb have been redeemed
        uint256 premiumFilled = (a * o.premium) / o.principal;
        Safe.transfer(uToken, o.maker, a - premiumFilled);

        // transfer premium-fee to floating exit party
        uint256 fee = premiumFilled / feenominators[3];
        Safe.transfer(uToken, msg.sender, premiumFilled - fee);

        // burn zcTokens + nTokens from o.maker and msg.sender respectively
        if (
            !mPlace.custodialExit(
                o.protocol,
                o.underlying,
                o.maturity,
                o.maker,
                msg.sender,
                a
            )
        ) {
            revert Exception(9, 0, 0, address(0), address(0));
        }

        emit Exit(
            o.key,
            hash,
            o.maker,
            o.vault,
            o.exit,
            msg.sender,
            a,
            premiumFilled
        );
    }

    
    
    
    
    
    function exitZcTokenFillingVaultExit(
        Hash.Order calldata o,
        uint256 a,
        Sig.Components calldata c
    ) internal {
        bytes32 hash = validOrderHash(o, c);
        uint256 amount = a + filled[hash];

        if (amount > o.premium) {
            revert Exception(5, amount, o.premium, address(0), address(0));
        }

        filled[hash] = amount;

        // redeem underlying on Compound and burn cTokens
        IMarketPlace mPlace = IMarketPlace(marketPlace);
        address cTokenAddr = mPlace.cTokenAddress(
            o.protocol,
            o.underlying,
            o.maturity
        );
        uint256 principalFilled = (a * o.principal) / o.premium;

        if (!withdraw(o.protocol, o.underlying, cTokenAddr, principalFilled)) {
            revert Exception(7, 0, 0, address(0), address(0));
        }

        IERC20 uToken = IERC20(o.underlying);
        // transfer principal-premium-fee back to fixed exit party now that the interest coupon and zcb have been redeemed
        uint256 fee = principalFilled / feenominators[1];
        Safe.transfer(uToken, msg.sender, principalFilled - a - fee);
        Safe.transfer(uToken, o.maker, a);

        // burn <principalFilled> zcTokens + nTokens from msg.sender and o.maker respectively
        if (
            !mPlace.custodialExit(
                o.protocol,
                o.underlying,
                o.maturity,
                msg.sender,
                o.maker,
                principalFilled
            )
        ) {
            revert Exception(9, 0, 0, address(0), address(0));
        }

        emit Exit(
            o.key,
            hash,
            o.maker,
            o.vault,
            o.exit,
            msg.sender,
            a,
            principalFilled
        );
    }

    
    
    function cancel(Hash.Order[] calldata o) external returns (bool) {
        for (uint256 i; i != o.length; ) {
            if (msg.sender != o[i].maker) {
                revert Exception(15, 0, 0, msg.sender, o[i].maker);
            }

            bytes32 hash = Hash.order(o[i]);
            cancelled[hash] = true;

            emit Cancel(o[i].key, hash);

            unchecked {
                ++i;
            }
        }

        return true;
    }

    // ********* ADMINISTRATIVE ***************

    
    function setAdmin(address a) external authorized(admin) returns (bool) {
        admin = a;

        emit SetAdmin(a);

        return true;
    }

    
    
    function scheduleWithdrawal(address e)
        external
        authorized(admin)
        returns (bool)
    {
        uint256 when = block.timestamp + HOLD;
        withdrawals[e] = when;

        emit ScheduleWithdrawal(e, when);

        return true;
    }

    
    
    function scheduleApproval(address e)
        external
        authorized(admin)
        returns (bool)
    {
        uint256 when = block.timestamp + HOLD;
        approvals[e] = when;

        emit ScheduleApproval(e, when);

        return true;
    }

    
    
    function scheduleFeeChange(uint16[4] calldata f)
        external
        authorized(admin)
        returns (bool)
    {
        uint256 when = block.timestamp + HOLD;
        feeChange = when;

        emit ScheduleFeeChange(f, when);

        return true;
    }

    
    
    function blockWithdrawal(address e)
        external
        authorized(admin)
        returns (bool)
    {
        delete withdrawals[e];

        emit BlockWithdrawal(e);

        return true;
    }

    
    
    function blockApproval(address e)
        external
        authorized(admin)
        returns (bool)
    {
        delete approvals[e];

        emit BlockApproval(e);

        return true;
    }

    
    function blockFeeChange() external authorized(admin) returns (bool) {
        delete feeChange;

        emit BlockFeeChange();

        return true;
    }

    
    
    function withdraw(address e) external authorized(admin) returns (bool) {
        uint256 when = withdrawals[e];

        if (when == 0) {
            revert Exception(16, 0, 0, address(0), address(0));
        }

        if (block.timestamp < when) {
            revert Exception(17, block.timestamp, when, address(0), address(0));
        }

        delete withdrawals[e];

        IERC20 token = IERC20(e);
        Safe.transfer(token, admin, token.balanceOf(address(this)));

        return true;
    }

    
    
    
    function changeFee(uint16[4] calldata f)
        external
        authorized(admin)
        returns (bool)
    {
        if (feeChange == 0) {
            revert Exception(35, 0, 0, address(0), address(0));
        }

        if (block.timestamp < feeChange) {
            revert Exception(
                36,
                block.timestamp,
                feeChange,
                address(0),
                address(0)
            );
        }

        for (uint256 i; i != 4; ) {
            if (f[i] < MIN_FEENOMINATOR) {
                revert Exception(
                    18,
                    f[i],
                    MIN_FEENOMINATOR,
                    address(0),
                    address(0)
                );
            }

            // as stated, only set a value different than what exists
            if (f[i] != feenominators[i]) {
                feenominators[i] = f[i];
                emit ChangeFee(i, f[i]);
            }

            unchecked {
                ++i;
            }
        }

        delete feeChange;

        return true;
    }

    
    /// providing the holding period has been observed
    
    
    function approveUnderlying(address[] calldata u, address[] calldata c)
        external
        authorized(admin)
        returns (bool)
    {
        if (u.length != c.length) {
            revert Exception(19, u.length, c.length, address(0), address(0));
        }

        uint256 max = type(uint256).max;

        for (uint256 i; i != u.length; ) {
            uint256 when = approvals[u[i]];

            if (when == 0) {
                revert Exception(38, 0, 0, address(0), address(0));
            }

            if (block.timestamp < when) {
                revert Exception(
                    39,
                    block.timestamp,
                    when,
                    address(0),
                    address(0)
                );
            }

            delete approvals[u[i]];
            IERC20 uToken = IERC20(u[i]);
            Safe.approve(uToken, c[i], max);

            unchecked {
                ++i;
            }
        }

        return true;
    }

    // ********* PROTOCOL UTILITY ***************

    
    /// zcTokens and vault notional. Calls mPlace.mintZcTokenAddingNotional
    
    
    
    
    function splitUnderlying(
        uint8 p,
        address u,
        uint256 m,
        uint256 a
    ) external returns (bool) {
        IERC20 uToken = IERC20(u);
        Safe.transferFrom(uToken, msg.sender, address(this), a);

        IMarketPlace mPlace = IMarketPlace(marketPlace);

        // the underlying deposit is directed to the appropriate abstraction
        if (!deposit(p, u, mPlace.cTokenAddress(p, u, m), a)) {
            revert Exception(6, 0, 0, address(0), address(0));
        }

        if (!mPlace.mintZcTokenAddingNotional(p, u, m, msg.sender, a)) {
            revert Exception(13, 0, 0, address(0), address(0));
        }

        return true;
    }

    
    /// in the process "combining" the two, and redeeming underlying. Calls mPlace.burnZcTokenRemovingNotional.
    
    
    
    
    function combineTokens(
        uint8 p,
        address u,
        uint256 m,
        uint256 a
    ) external returns (bool) {
        IMarketPlace mPlace = IMarketPlace(marketPlace);

        if (!mPlace.burnZcTokenRemovingNotional(p, u, m, msg.sender, a)) {
            revert Exception(14, 0, 0, address(0), address(0));
        }

        if (!withdraw(p, u, mPlace.cTokenAddress(p, u, m), a)) {
            revert Exception(7, 0, 0, address(0), address(0));
        }

        Safe.transfer(IERC20(u), msg.sender, a);

        return true;
    }

    
    
    
    
    
    
    
    function authRedeem(
        uint8 p,
        address u,
        address c,
        address t,
        uint256 a
    ) external authorized(marketPlace) returns (bool) {
        // redeem underlying from compounding
        if (!withdraw(p, u, c, a)) {
            revert Exception(7, 0, 0, address(0), address(0));
        }
        // transfer underlying back to msg.sender
        Safe.transfer(IERC20(u), t, a);

        return true;
    }

    
    
    
    
    
    function redeemZcToken(
        uint8 p,
        address u,
        uint256 m,
        uint256 a
    ) external returns (bool) {
        IMarketPlace mPlace = IMarketPlace(marketPlace);
        // call marketplace to determine the amount redeemed
        uint256 redeemed = mPlace.redeemZcToken(p, u, m, msg.sender, a);
        // redeem underlying from compounding
        if (!withdraw(p, u, mPlace.cTokenAddress(p, u, m), redeemed)) {
            revert Exception(7, 0, 0, address(0), address(0));
        }

        // transfer underlying back to msg.sender
        Safe.transfer(IERC20(u), msg.sender, redeemed);

        return true;
    }

    
    
    
    
    function redeemVaultInterest(
        uint8 p,
        address u,
        uint256 m
    ) external returns (bool) {
        IMarketPlace mPlace = IMarketPlace(marketPlace);
        // call marketplace to determine the amount redeemed
        uint256 redeemed = mPlace.redeemVaultInterest(p, u, m, msg.sender);
        // redeem underlying from compounding
        address cTokenAddr = mPlace.cTokenAddress(p, u, m);

        if (!withdraw(p, u, cTokenAddr, redeemed)) {
            revert Exception(7, 0, 0, address(0), address(0));
        }

        // transfer underlying back to msg.sender
        Safe.transfer(IERC20(u), msg.sender, redeemed);

        return true;
    }

    
    
    
    
    function redeemSwivelVaultInterest(
        uint8 p,
        address u,
        uint256 m
    ) external returns (bool) {
        IMarketPlace mPlace = IMarketPlace(marketPlace);
        // call marketplace to determine the amount redeemed
        uint256 redeemed = mPlace.redeemVaultInterest(p, u, m, address(this));
        // redeem underlying from compounding
        if (!withdraw(p, u, mPlace.cTokenAddress(p, u, m), redeemed)) {
            revert Exception(7, 0, 0, address(0), address(0));
        }

        // NOTE: for swivel redeem there is no transfer out as there is in redeemVaultInterest

        return true;
    }

    
    
    
    
    function validOrderHash(Hash.Order calldata o, Sig.Components calldata c)
        internal
        view
        returns (bytes32)
    {
        bytes32 hash = Hash.order(o);

        if (cancelled[hash]) {
            revert Exception(2, 0, 0, address(0), address(0));
        }

        if (o.expiry < block.timestamp) {
            revert Exception(
                3,
                o.expiry,
                block.timestamp,
                address(0),
                address(0)
            );
        }

        address recovered = Sig.recover(Hash.message(domain, hash), c);

        if (o.maker != recovered) {
            revert Exception(4, 0, 0, o.maker, recovered);
        }

        return hash;
    }

    
    
    
    
    
    
    function deposit(
        uint8 p,
        address u,
        address c,
        uint256 a
    ) internal returns (bool) {
        if (p == uint8(Protocols.Compound) || p == uint8(Protocols.Rari)) {
            return ICompound(c).mint(a) == 0;
        } else if (p == uint8(Protocols.Yearn)) {
            // yearn vault api states that deposit returns shares as uint256
            return IYearn(c).deposit(a) >= 0;
        } else if (p == uint8(Protocols.Aave)) {
            // Aave deposit is void. NOTE the change in pattern here where our interface is not wrapping a compounding token directly, but
            // a specified protocol contract whose address we have set
            IAave(aaveAddr).deposit(u, a, address(this), 0);
            return true;
        } else if (p == uint8(Protocols.Euler)) {
            // Euler deposit is void.
            IEuler(c).deposit(0, a);
            return true;
        } else if (p == uint8(Protocols.Lido)) {
            return ILido(c).wrap(a) >= 0;
        } else {
            // we will allow protocol[0] to also function as a catchall for ERC4626
            // NOTE: deposit, as per the spec, returns 'shares' but it is unknown if 0 would revert, thus we'll check for 0 or greater
            return IERC4626(c).deposit(a, address(this)) >= 0;
        }
    }

    
    
    /// Note that while there is an external method `withdraw` also on this contract the unique method signatures (and visibility)
    /// exclude any possible clashing
    
    
    
    
    function withdraw(
        uint8 p,
        address u,
        address c,
        uint256 a
    ) internal returns (bool) {
        if (p == uint8(Protocols.Compound) || p == uint8(Protocols.Rari)) {
            return ICompound(c).redeemUnderlying(a) == 0;
        } else if (p == uint8(Protocols.Yearn)) {
            // yearn vault api states that withdraw returns uint256
            // NOTE that we must use the price-per-share in Yearn to determine the correct number of underlying assets
            IYearn vault = IYearn(c);
            return vault.withdraw(a / vault.pricePerShare()) >= 0;
        } else if (p == uint8(Protocols.Aave)) {
            // Aave v2 docs state that withdraw returns uint256
            return IAave(aaveAddr).withdraw(u, a, address(this)) >= 0;
        } else if (p == uint8(Protocols.Euler)) {
            // Euler withdraw is void
            IEuler(c).withdraw(0, a);
            return true;
        } else if (p == uint8(Protocols.Lido)) {
            ILido wstEth = ILido(c);
            return wstEth.unwrap(wstEth.getWstETHByStETH(a)) >= 0;
        } else {
            // we will allow protocol[0] to also function as a catchall for ERC4626
            return IERC4626(c).withdraw(a, address(this), address(this)) >= 0;
        }
    }

    modifier authorized(address a) {
        if (msg.sender != a) {
            revert Exception(0, 0, 0, msg.sender, a);
        }
        _;
    }
}

// 

pragma solidity ^0.8.13;

enum Protocols {
    Erc4626,
    Compound,
    Rari,
    Yearn,
    Aave,
    Euler,
    Lido
}

// 

pragma solidity ^0.8.13;

/**
  @notice Encapsulation of the logic to produce EIP712 hashed domain and messages.
  Also to produce / verify hashed and signed Orders.
  See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md
  See/attribute https://github.com/0xProject/0x-monorepo/blob/development/contracts/utils/contracts/src/LibEIP712.sol
*/

library Hash {
    
    struct Order {
        bytes32 key;
        uint8 protocol;
        address maker;
        address underlying;
        bool vault;
        bool exit;
        uint256 principal;
        uint256 premium;
        uint256 maturity;
        uint256 expiry;
    }

    // EIP712 Domain Separator typeHash
    // keccak256(abi.encodePacked(
    //     'EIP712Domain(',
    //     'string name,',
    //     'string version,',
    //     'uint256 chainId,',
    //     'address verifyingContract',
    //     ')'
    // ));
    bytes32 internal constant DOMAIN_TYPEHASH =
        0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    // EIP712 typeHash of an Order
    // keccak256(abi.encodePacked(
    //     'Order(',
    //     'bytes32 key,',
    //     'uint8 protocol,',
    //     'address maker,',
    //     'address underlying,',
    //     'bool vault,',
    //     'bool exit,',
    //     'uint256 principal,',
    //     'uint256 premium,',
    //     'uint256 maturity,',
    //     'uint256 expiry',
    //     ')'
    // ));
    bytes32 internal constant ORDER_TYPEHASH =
        0xbc200cfe92556575f801f821f26e6d54f6421fa132e4b2d65319cac1c687d8e6;

    
    
    
    
    function domain(
        string memory n,
        string memory version,
        uint256 i,
        address verifier
    ) internal pure returns (bytes32) {
        bytes32 hash;

        assembly {
            let nameHash := keccak256(add(n, 32), mload(n))
            let versionHash := keccak256(add(version, 32), mload(version))
            let pointer := mload(64)
            mstore(pointer, DOMAIN_TYPEHASH)
            mstore(add(pointer, 32), nameHash)
            mstore(add(pointer, 64), versionHash)
            mstore(add(pointer, 96), i)
            mstore(add(pointer, 128), verifier)
            hash := keccak256(pointer, 160)
        }

        return hash;
    }

    
    
    function message(bytes32 d, bytes32 h) internal pure returns (bytes32) {
        bytes32 hash;

        assembly {
            let pointer := mload(64)
            mstore(
                pointer,
                0x1901000000000000000000000000000000000000000000000000000000000000
            )
            mstore(add(pointer, 2), d)
            mstore(add(pointer, 34), h)
            hash := keccak256(pointer, 66)
        }

        return hash;
    }

    
    function order(Order calldata o) internal pure returns (bytes32) {
        // TODO assembly
        return
            keccak256(
                abi.encode(
                    ORDER_TYPEHASH,
                    o.key,
                    o.protocol,
                    o.maker,
                    o.underlying,
                    o.vault,
                    o.exit,
                    o.principal,
                    o.premium,
                    o.maturity,
                    o.expiry
                )
            );
    }
}

// 

pragma solidity ^0.8.13;

library Sig {
    
    struct Components {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    error S();
    error V();
    error Length();
    error ZeroAddress();

    
    
    
    function recover(bytes32 h, Components calldata c)
        internal
        pure
        returns (address)
    {
        // EIP-2 and malleable signatures...
        // see https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/cryptography/ECDSA.sol
        if (
            uint256(c.s) >
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
        ) {
            revert S();
        }

        if (c.v != 27 && c.v != 28) {
            revert V();
        }

        address recovered = ecrecover(h, c.v, c.r, c.s);

        if (recovered == address(0)) {
            revert ZeroAddress();
        }

        return recovered;
    }

    
    
    
    
    function split(bytes memory sig)
        internal
        pure
        returns (
            uint8,
            bytes32,
            bytes32
        )
    {
        if (sig.length != 65) {
            revert Length();
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }
}

// 
// Adapted from: https://github.com/Rari-Capital/solmate/blob/main/src/utils/SafeTransferLib.sol
pragma solidity ^0.8.13;






library Safe {
    /*//////////////////////////////////////////////////////////////
                              CUSTOM ERRORS
    //////////////////////////////////////////////////////////////*/

    error ETHTransferFailed();

    error TransferFailed();

    error TransferFromFailed();

    error ApproveFailed();

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function transferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // We'll write our calldata to this slot below, but restore it later.
            let memPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(
                0,
                0x23b872dd00000000000000000000000000000000000000000000000000000000
            )
            mstore(4, from) // Append the "from" argument.
            mstore(36, to) // Append the "to" argument.
            mstore(68, amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                // We use 100 because that's the total length of our calldata (4 + 32 * 3)
                // Counterintuitively, this call() must be positioned after the or() in the
                // surrounding and() because and() evaluates its arguments from right to left.
                call(gas(), token, 0, 0, 100, 0, 32)
            )

            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, memPointer) // Restore the memPointer.
        }

        if (!success) {
            revert TransferFromFailed();
        }
    }

    function transfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // We'll write our calldata to this slot below, but restore it later.
            let memPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(
                0,
                0xa9059cbb00000000000000000000000000000000000000000000000000000000
            )
            mstore(4, to) // Append the "to" argument.
            mstore(36, amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                // We use 68 because that's the total length of our calldata (4 + 32 * 2)
                // Counterintuitively, this call() must be positioned after the or() in the
                // surrounding and() because and() evaluates its arguments from right to left.
                call(gas(), token, 0, 0, 68, 0, 32)
            )

            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, memPointer) // Restore the memPointer.
        }

        if (!success) {
            revert TransferFailed();
        }
    }

    function approve(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // We'll write our calldata to this slot below, but restore it later.
            let memPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(
                0,
                0x095ea7b300000000000000000000000000000000000000000000000000000000
            )
            mstore(4, to) // Append the "to" argument.
            mstore(36, amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                // We use 68 because that's the total length of our calldata (4 + 32 * 2)
                // Counterintuitively, this call() must be positioned after the or() in the
                // surrounding and() because and() evaluates its arguments from right to left.
                call(gas(), token, 0, 0, 68, 0, 32)
            )

            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, memPointer) // Restore the memPointer.
        }

        if (!success) {
            revert ApproveFailed();
        }
    }
}

// 

pragma solidity ^0.8.13;

// methods requried on other contracts which are expected to, at least, implement the following:
interface IERC20 {
    function approve(address, uint256) external returns (bool);

    function transfer(address, uint256) external returns (bool);

    function balanceOf(address) external returns (uint256);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);
}

// 

pragma solidity ^0.8.13;

interface IERC4626 {
    function deposit(uint256, address) external returns (uint256);

    function withdraw(
        uint256,
        address,
        address
    ) external returns (uint256);

    
    function convertToAssets(uint256) external view returns (uint256);

    
    function asset() external view returns (address);
}

// 

pragma solidity ^0.8.13;

interface IMarketPlace {
    function setSwivel(address) external returns (bool);

    function setAdmin(address) external returns (bool);

    function createMarket(
        uint8,
        uint256,
        address,
        string memory,
        string memory
    ) external returns (bool);

    function matureMarket(
        uint8,
        address,
        uint256
    ) external returns (bool);

    function authRedeem(
        uint8,
        address,
        uint256,
        address,
        address,
        uint256
    ) external returns (uint256);

    function exchangeRate(uint8, address) external returns (uint256);

    function rates(
        uint8,
        address,
        uint256
    ) external returns (uint256, uint256);

    function transferVaultNotional(
        uint8,
        address,
        uint256,
        address,
        uint256
    ) external returns (bool);

    // adds notional and mints zctokens
    function mintZcTokenAddingNotional(
        uint8,
        address,
        uint256,
        address,
        uint256
    ) external returns (bool);

    // removes notional and burns zctokens
    function burnZcTokenRemovingNotional(
        uint8,
        address,
        uint256,
        address,
        uint256
    ) external returns (bool);

    // returns the amount of underlying principal to send
    function redeemZcToken(
        uint8,
        address,
        uint256,
        address,
        uint256
    ) external returns (uint256);

    // returns the amount of underlying interest to send
    function redeemVaultInterest(
        uint8,
        address,
        uint256,
        address
    ) external returns (uint256);

    // returns the cToken address for a given market
    function cTokenAddress(
        uint8,
        address,
        uint256
    ) external returns (address);

    // EVFZE FF EZFVE call this which would then burn zctoken and remove notional
    function custodialExit(
        uint8,
        address,
        uint256,
        address,
        address,
        uint256
    ) external returns (bool);

    // IVFZI && IZFVI call this which would then mint zctoken and add notional
    function custodialInitiate(
        uint8,
        address,
        uint256,
        address,
        address,
        uint256
    ) external returns (bool);

    // IZFZE && EZFZI call this, tranferring zctoken from one party to another
    function p2pZcTokenExchange(
        uint8,
        address,
        uint256,
        address,
        address,
        uint256
    ) external returns (bool);

    // IVFVE && EVFVI call this, removing notional from one party and adding to the other
    function p2pVaultExchange(
        uint8,
        address,
        uint256,
        address,
        address,
        uint256
    ) external returns (bool);

    // IVFZI && IVFVE call this which then transfers notional from msg.sender (taker) to swivel
    function transferVaultNotionalFee(
        uint8,
        address,
        uint256,
        address,
        uint256
    ) external returns (bool);
}

// 

pragma solidity ^0.8.13;

interface IAave {
    function deposit(
        address,
        uint256,
        address,
        uint16
    ) external; // void

    function withdraw(
        address,
        uint256,
        address
    ) external returns (uint256);
}

// 

pragma solidity ^0.8.13;

interface ICompound {
    function mint(uint256) external returns (uint256);

    function redeemUnderlying(uint256) external returns (uint256);
}

// 

pragma solidity ^0.8.13;

interface IEuler {
    function deposit(uint256, uint256) external; // void

    function withdraw(uint256, uint256) external; // void
}

// 

pragma solidity ^0.8.13;

interface ILido {
    function wrap(uint256) external returns (uint256);

    function unwrap(uint256) external returns (uint256);

    function getWstETHByStETH(uint256) external returns (uint256);
}

// 

pragma solidity ^0.8.13;

interface IYearn {
    function deposit(uint256) external returns (uint256);

    function withdraw(uint256) external returns (uint256);

    function pricePerShare() external returns (uint256);
}