
/**
 *Submitted for verification at Etherscan.io on 2021-07-22
*/

pragma solidity 0.6.7;

/// GebProxyActions.sol

// Copyright (C) 2018-2020 Maker Ecosystem Growth Holdings, INC.

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

abstract contract CollateralLike {
    function approve(address, uint) virtual public;
    function transfer(address, uint) virtual public;
    function transferFrom(address, address, uint) virtual public;
    function deposit() virtual public payable;
    function withdraw(uint) virtual public;
}

abstract contract ManagerLike {
    function safeCan(address, uint, address) virtual public view returns (uint);
    function collateralTypes(uint) virtual public view returns (bytes32);
    function ownsSAFE(uint) virtual public view returns (address);
    function safes(uint) virtual public view returns (address);
    function safeEngine() virtual public view returns (address);
    function openSAFE(bytes32, address) virtual public returns (uint);
    function transferSAFEOwnership(uint, address) virtual public;
    function allowSAFE(uint, address, uint) virtual public;
    function allowHandler(address, uint) virtual public;
    function modifySAFECollateralization(uint, int, int) virtual public;
    function transferCollateral(uint, address, uint) virtual public;
    function transferInternalCoins(uint, address, uint) virtual public;
    function quitSystem(uint, address) virtual public;
    function enterSystem(address, uint) virtual public;
    function moveSAFE(uint, uint) virtual public;
    function protectSAFE(uint, address, address) virtual public;
}

abstract contract SAFEEngineLike {
    function canModifySAFE(address, address) virtual public view returns (uint);
    function collateralTypes(bytes32) virtual public view returns (uint, uint, uint, uint, uint);
    function coinBalance(address) virtual public view returns (uint);
    function safes(bytes32, address) virtual public view returns (uint, uint);
    function modifySAFECollateralization(bytes32, address, address, address, int, int) virtual public;
    function approveSAFEModification(address) virtual public;
    function transferInternalCoins(address, address, uint) virtual public;
}

abstract contract CollateralJoinLike {
    function decimals() virtual public returns (uint);
    function collateral() virtual public returns (CollateralLike);
    function join(address, uint) virtual public payable;
    function exit(address, uint) virtual public;
}

abstract contract GNTJoinLike {
    function bags(address) virtual public view returns (address);
    function make(address) virtual public returns (address);
}

abstract contract DSTokenLike {
    function balanceOf(address) virtual public view returns (uint);
    function approve(address, uint) virtual public;
    function transfer(address, uint) virtual public returns (bool);
    function transferFrom(address, address, uint) virtual public returns (bool);
}

abstract contract WethLike {
    function balanceOf(address) virtual public view returns (uint);
    function approve(address, uint) virtual public;
    function transfer(address, uint) virtual public;
    function transferFrom(address, address, uint) virtual public;
    function deposit() virtual public payable;
    function withdraw(uint) virtual public;
}

abstract contract CoinJoinLike {
    function safeEngine() virtual public returns (SAFEEngineLike);
    function systemCoin() virtual public returns (DSTokenLike);
    function join(address, uint) virtual public payable;
    function exit(address, uint) virtual public;
}

abstract contract ApproveSAFEModificationLike {
    function approveSAFEModification(address) virtual public;
    function denySAFEModification(address) virtual public;
}

abstract contract GlobalSettlementLike {
    function collateralCashPrice(bytes32) virtual public view returns (uint);
    function redeemCollateral(bytes32, uint) virtual public;
    function freeCollateral(bytes32) virtual public;
    function prepareCoinsForRedeeming(uint) virtual public;
    function processSAFE(bytes32, address) virtual public;
}

abstract contract TaxCollectorLike {
    function taxSingle(bytes32) virtual public returns (uint);
}

abstract contract CoinSavingsAccountLike {
    function savings(address) virtual public view returns (uint);
    function updateAccumulatedRate() virtual public returns (uint);
    function deposit(uint) virtual public;
    function withdraw(uint) virtual public;
}

abstract contract ProxyRegistryLike {
    function proxies(address) virtual public view returns (address);
    function build(address) virtual public returns (address);
}

abstract contract ProxyLike {
    function owner() virtual public view returns (address);
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// WARNING: These functions meant to be used as a a library for a DSProxy. Some are unsafe if you call them directly.
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

contract Common {
    uint256 constant RAY = 10 ** 27;

    // Internal functions
    function multiply(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "mul-overflow");
    }

    function _coinJoin_join(address apt, address safeHandler, uint wad) internal {
        // Approves adapter to take the COIN amount
        CoinJoinLike(apt).systemCoin().approve(apt, wad);
        // Joins COIN into the safeEngine
        CoinJoinLike(apt).join(safeHandler, wad);
    }

    // Public functions
    function coinJoin_join(address apt, address safeHandler, uint wad) public {
        // Gets COIN from the user's wallet
        CoinJoinLike(apt).systemCoin().transferFrom(msg.sender, address(this), wad);

        _coinJoin_join(apt, safeHandler, wad);
    }
}

contract BasicActions is Common {
    // Internal functions

    
    
    function subtract(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "sub-overflow");
    }

    
    
    function toInt(uint x) internal pure returns (int y) {
        y = int(x);
        require(y >= 0, "int-overflow");
    }

    
    function toRad(uint wad) internal pure returns (uint rad) {
        rad = multiply(wad, 10 ** 27);
    }

    function convertTo18(address collateralJoin, uint256 amt) internal returns (uint256 wad) {
        // For those collaterals that have other than 18 decimals precision we need to do the conversion before passing to modifySAFECollateralization function
        // Adapters will automatically handle the difference of precision
        uint decimals = CollateralJoinLike(collateralJoin).decimals();
        wad = amt;
        if (decimals < 18) {
          wad = multiply(
              amt,
              10 ** (18 - decimals)
          );
        } else if (decimals > 18) {
          wad = amt / 10 ** (decimals - 18);
        }
    }

    
    
    
    
    
    
    function _getGeneratedDeltaDebt(
        address safeEngine,
        address taxCollector,
        address safeHandler,
        bytes32 collateralType,
        uint wad
    ) internal returns (int deltaDebt) {
        // Updates stability fee rate
        uint rate = TaxCollectorLike(taxCollector).taxSingle(collateralType);
        require(rate > 0, "invalid-collateral-type");

        // Gets COIN balance of the handler in the safeEngine
        uint coin = SAFEEngineLike(safeEngine).coinBalance(safeHandler);

        // If there was already enough COIN in the safeEngine balance, just exits it without adding more debt
        if (coin < multiply(wad, RAY)) {
            // Calculates the needed deltaDebt so together with the existing coins in the safeEngine is enough to exit wad amount of COIN tokens
            deltaDebt = toInt(subtract(multiply(wad, RAY), coin) / rate);
            // This is neeeded due lack of precision. It might need to sum an extra deltaDebt wei (for the given COIN wad amount)
            deltaDebt = multiply(uint(deltaDebt), rate) < multiply(wad, RAY) ? deltaDebt + 1 : deltaDebt;
        }
    }

    
    
    
    
    
        
    function _getRepaidDeltaDebt(
        address safeEngine,
        uint coin,
        address safe,
        bytes32 collateralType
    ) internal view returns (int deltaDebt) {
        // Gets actual rate from the safeEngine
        (, uint rate,,,) = SAFEEngineLike(safeEngine).collateralTypes(collateralType);
        require(rate > 0, "invalid-collateral-type");

        // Gets actual generatedDebt value of the safe
        (, uint generatedDebt) = SAFEEngineLike(safeEngine).safes(collateralType, safe);

        // Uses the whole coin balance in the safeEngine to reduce the debt
        deltaDebt = toInt(coin / rate);
        // Checks the calculated deltaDebt is not higher than safe.generatedDebt (total debt), otherwise uses its value
        deltaDebt = uint(deltaDebt) <= generatedDebt ? - deltaDebt : - toInt(generatedDebt);
    }

    
    
    
    
    
    
    function _getRepaidAlDebt(
        address safeEngine,
        address usr,
        address safe,
        bytes32 collateralType
    ) internal view returns (uint wad) {
        // Gets actual rate from the safeEngine
        (, uint rate,,,) = SAFEEngineLike(safeEngine).collateralTypes(collateralType);
        // Gets actual generatedDebt value of the safe
        (, uint generatedDebt) = SAFEEngineLike(safeEngine).safes(collateralType, safe);
        // Gets actual coin amount in the safe
        uint coin = SAFEEngineLike(safeEngine).coinBalance(usr);

        uint rad = subtract(multiply(generatedDebt, rate), coin);
        wad = rad / RAY;

        // If the rad precision has some dust, it will need to request for 1 extra wad wei
        wad = multiply(wad, RAY) < rad ? wad + 1 : wad;
    }

    
    
    
    
    
    
    
    function _generateDebt(address manager, address taxCollector, address coinJoin, uint safe, uint wad, address to) internal {
        address safeHandler = ManagerLike(manager).safes(safe);
        address safeEngine = ManagerLike(manager).safeEngine();
        bytes32 collateralType = ManagerLike(manager).collateralTypes(safe);
        // Generates debt in the SAFE
        modifySAFECollateralization(manager, safe, 0, _getGeneratedDeltaDebt(safeEngine, taxCollector, safeHandler, collateralType, wad));
        // Moves the COIN amount (balance in the safeEngine in rad) to proxy's address
        transferInternalCoins(manager, safe, address(this), toRad(wad));
        // Allows adapter to access to proxy's COIN balance in the safeEngine
        if (SAFEEngineLike(safeEngine).canModifySAFE(address(this), address(coinJoin)) == 0) {
            SAFEEngineLike(safeEngine).approveSAFEModification(coinJoin);
        }
        // Exits COIN to this contract
        CoinJoinLike(coinJoin).exit(to, wad);
    }

    
    
    
    
    
    
    function _lockETH(
        address manager,
        address ethJoin,
        uint safe,
        uint value
    ) internal {
        // Receives ETH amount, converts it to WETH and joins it into the safeEngine
        ethJoin_join(ethJoin, address(this), value);
        // Locks WETH amount into the SAFE
        SAFEEngineLike(ManagerLike(manager).safeEngine()).modifySAFECollateralization(
            ManagerLike(manager).collateralTypes(safe),
            ManagerLike(manager).safes(safe),
            address(this),
            address(this),
            toInt(value),
            0
        );
    }

    
    
    
    
    
    function _repayDebt(
        address manager,
        address coinJoin,
        uint safe,
        uint wad,
        bool transferFromCaller
    ) internal {
        address safeEngine = ManagerLike(manager).safeEngine();
        address safeHandler = ManagerLike(manager).safes(safe);
        bytes32 collateralType = ManagerLike(manager).collateralTypes(safe);

        address own = ManagerLike(manager).ownsSAFE(safe);
        if (own == address(this) || ManagerLike(manager).safeCan(own, safe, address(this)) == 1) {
            // Joins COIN amount into the safeEngine
            if (transferFromCaller) coinJoin_join(coinJoin, safeHandler, wad);
            else _coinJoin_join(coinJoin, safeHandler, wad);
            // // Paybacks debt to the SAFE
            modifySAFECollateralization(manager, safe, 0, _getRepaidDeltaDebt(safeEngine, SAFEEngineLike(safeEngine).coinBalance(safeHandler), safeHandler, collateralType));
        } else {
             // Joins COIN amount into the safeEngine
            if (transferFromCaller) coinJoin_join(coinJoin, address(this), wad);
            else _coinJoin_join(coinJoin, address(this), wad);
            // Paybacks debt to the SAFE
            SAFEEngineLike(safeEngine).modifySAFECollateralization(
                collateralType,
                safeHandler,
                address(this),
                address(this),
                0,
                _getRepaidDeltaDebt(safeEngine, wad * RAY, safeHandler, collateralType)
            );
        }
    }

    
    
    
    
    
    
    
    
    function _repayDebtAndFreeETH(
        address manager,
        address ethJoin,
        address coinJoin,
        uint safe,
        uint collateralWad,
        uint deltaWad,
        bool transferFromCaller
    ) internal {
        address safeHandler = ManagerLike(manager).safes(safe);
        // Joins COIN amount into the safeEngine
        if (transferFromCaller) coinJoin_join(coinJoin, safeHandler, deltaWad);
        else _coinJoin_join(coinJoin, safeHandler, deltaWad);
        // Paybacks debt to the SAFE and unlocks WETH amount from it
        modifySAFECollateralization(
            manager,
            safe,
            -toInt(collateralWad),
            _getRepaidDeltaDebt(ManagerLike(manager).safeEngine(), SAFEEngineLike(ManagerLike(manager).safeEngine()).coinBalance(safeHandler), safeHandler, ManagerLike(manager).collateralTypes(safe))
        );
        // Moves the amount from the SAFE handler to proxy's address
        transferCollateral(manager, safe, address(this), collateralWad);
        // Exits WETH amount to proxy address as a token
        CollateralJoinLike(ethJoin).exit(address(this), collateralWad);
        // Converts WETH to ETH
        CollateralJoinLike(ethJoin).collateral().withdraw(collateralWad);
    }

    // Public functions

    
    
    
    
    function transfer(address collateral, address dst, uint amt) external {
        CollateralLike(collateral).transfer(dst, amt);
    }

    
    
    
    function ethJoin_join(address apt, address safe) external payable {
        ethJoin_join(apt, safe, msg.value);
    }

    
    
    
    
    function ethJoin_join(address apt, address safe, uint value) public payable {
        // Wraps ETH in WETH
        CollateralJoinLike(apt).collateral().deposit{value: value}();
        // Approves adapter to take the WETH amount
        CollateralJoinLike(apt).collateral().approve(address(apt), value);
        // Joins WETH collateral into the safeEngine
        CollateralJoinLike(apt).join(safe, value);
    }

    
    
    
    function approveSAFEModification(
        address safeEngine,
        address usr
    ) external {
        ApproveSAFEModificationLike(safeEngine).approveSAFEModification(usr);
    }

    
    
    
    function denySAFEModification(
        address safeEngine,
        address usr
    ) external {
        ApproveSAFEModificationLike(safeEngine).denySAFEModification(usr);
    }

    
    
    
    
    function openSAFE(
        address manager,
        bytes32 collateralType,
        address usr
    ) public returns (uint safe) {
        safe = ManagerLike(manager).openSAFE(collateralType, usr);
    }

    
    
    
    
    function transferSAFEOwnership(
        address manager,
        uint safe,
        address usr
    ) public {
        ManagerLike(manager).transferSAFEOwnership(safe, usr);
    }

    
    
    
    
    
    function transferSAFEOwnershipToProxy(
        address proxyRegistry,
        address manager,
        uint safe,
        address dst
    ) external {
        // Gets actual proxy address
        address proxy = ProxyRegistryLike(proxyRegistry).proxies(dst);
        // Checks if the proxy address already existed and dst address is still the owner
        if (proxy == address(0) || ProxyLike(proxy).owner() != dst) {
            uint csize;
            assembly {
                csize := extcodesize(dst)
            }
            // We want to avoid creating a proxy for a contract address that might not be able to handle proxies, then losing the SAFE
            require(csize == 0, "dst-is-a-contract");
            // Creates the proxy for the dst address
            proxy = ProxyRegistryLike(proxyRegistry).build(dst);
        }
        // Transfers SAFE to the dst proxy
        transferSAFEOwnership(manager, safe, proxy);
    }

    
    
    
    
    /// uint ok - 1 for allowed
    function allowSAFE(
        address manager,
        uint safe,
        address usr,
        uint ok
    ) external {
        ManagerLike(manager).allowSAFE(safe, usr, ok);
    }

    
    
    
    /// uint ok - 1 for allowed
    function allowHandler(
        address manager,
        address usr,
        uint ok
    ) external {
        ManagerLike(manager).allowHandler(usr, ok);
    }

    
    
    
    
    /// uint wad - amount
    function transferCollateral(
        address manager,
        uint safe,
        address dst,
        uint wad
    ) public {
        ManagerLike(manager).transferCollateral(safe, dst, wad);
    }

    
    
    
    
    /// uint rad - amount
    function transferInternalCoins(
        address manager,
        uint safe,
        address dst,
        uint rad
    ) public {
        ManagerLike(manager).transferInternalCoins(safe, dst, rad);
    }


    
    
    
    
    
    function modifySAFECollateralization(
        address manager,
        uint safe,
        int deltaCollateral,
        int deltaDebt
    ) public {
        ManagerLike(manager).modifySAFECollateralization(safe, deltaCollateral, deltaDebt);
    }

    
    
    
    
    function quitSystem(
        address manager,
        uint safe,
        address dst
    ) external {
        ManagerLike(manager).quitSystem(safe, dst);
    }

    
    
    
    
    function enterSystem(
        address manager,
        address src,
        uint safe
    ) external {
        ManagerLike(manager).enterSystem(src, safe);
    }

    
    
    
    
    function moveSAFE(
        address manager,
        uint safeSrc,
        uint safeDst
    ) external {
        ManagerLike(manager).moveSAFE(safeSrc, safeDst);
    }

    
    
    
    
    function lockETH(
        address manager,
        address ethJoin,
        uint safe
    ) public payable {
        _lockETH(manager, ethJoin, safe, msg.value);
    }

    
    
    
    
    
    function freeETH(
        address manager,
        address ethJoin,
        uint safe,
        uint wad
    ) public {
        // Unlocks WETH amount from the SAFE
        modifySAFECollateralization(manager, safe, -toInt(wad), 0);
        // Moves the amount from the SAFE handler to proxy's address
        transferCollateral(manager, safe, address(this), wad);
        // Exits WETH amount to proxy address as a token
        CollateralJoinLike(ethJoin).exit(address(this), wad);
        // Converts WETH to ETH
        CollateralJoinLike(ethJoin).collateral().withdraw(wad);
        // Sends ETH back to the user's wallet
        msg.sender.transfer(wad);
    }


    
    
    
    
    
    function exitETH(
        address manager,
        address ethJoin,
        uint safe,
        uint wad
    ) external {
        // Moves the amount from the SAFE handler to proxy's address
        transferCollateral(manager, safe, address(this), wad);
        // Exits WETH amount to proxy address as a token
        CollateralJoinLike(ethJoin).exit(address(this), wad);
        // Converts WETH to ETH
        CollateralJoinLike(ethJoin).collateral().withdraw(wad);
        // Sends ETH back to the user's wallet
        msg.sender.transfer(wad);
    }

    
    
    
    
    
    
    function generateDebt(
        address manager,
        address taxCollector,
        address coinJoin,
        uint safe,
        uint wad
    ) public {
        _generateDebt(manager, taxCollector, coinJoin, safe, wad, msg.sender);
    }

    
    
    
    
    
    function repayDebt(
        address manager,
        address coinJoin,
        uint safe,
        uint wad
    ) public {
        _repayDebt(manager, coinJoin, safe, wad, true);
    }

    
    
    
    
    
    
    
    function lockETHAndGenerateDebt(
        address manager,
        address taxCollector,
        address ethJoin,
        address coinJoin,
        uint safe,
        uint deltaWad
    ) public payable {
        _lockETH(manager, ethJoin, safe, msg.value);
        _generateDebt(manager, taxCollector, coinJoin, safe, deltaWad, msg.sender);
    }

    
    
    
    
    
    
    function openLockETHAndGenerateDebt(
        address manager,
        address taxCollector,
        address ethJoin,
        address coinJoin,
        bytes32 collateralType,
        uint deltaWad
    ) external payable returns (uint safe) {
        safe = openSAFE(manager, collateralType, address(this));
        lockETHAndGenerateDebt(manager, taxCollector, ethJoin, coinJoin, safe, deltaWad);
    }

    
    
    
    
    
    
    
    function repayDebtAndFreeETH(
        address manager,
        address ethJoin,
        address coinJoin,
        uint safe,
        uint collateralWad,
        uint deltaWad
    ) external {
        _repayDebtAndFreeETH(manager, ethJoin, coinJoin, safe, collateralWad, deltaWad, true);
        // Sends ETH back to the user's wallet
        msg.sender.transfer(collateralWad);
    }    
}

/// GebProxyAuctionActions.sol

// Copyright (C) 2018-2020 Maker Ecosystem Growth Holdings, INC.

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// WARNING: These functions meant to be used as a a library for a DSProxy. Some are unsafe if you call them directly.
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

abstract contract AccountingEngineLike {
    function debtAuctionHouse() external virtual returns (address);
    function surplusAuctionHouse() external virtual returns (address);
    function auctionDebt() external virtual returns (uint256);
    function auctionSurplus() external virtual returns (uint256);
}

abstract contract DebtAuctionHouseLike {
    function bids(uint) external virtual returns (uint, uint, address, uint48, uint48);
    function decreaseSoldAmount(uint256, uint256, uint256) external virtual;
    function restartAuction(uint256) external virtual;
    function settleAuction(uint256) external virtual;
    function protocolToken() external virtual returns (address);
}

abstract contract SurplusAuctionHouseLike {
    function bids(uint) external virtual returns (uint, uint, address, uint48, uint48);
    function increaseBidSize(uint256 id, uint256 amountToBuy, uint256 bid) external virtual;
    function restartAuction(uint256) external virtual;
    function settleAuction(uint256) external virtual;
    function protocolToken() external virtual returns (address);
}

contract AuctionCommon {

    
    
    function claimProxyFunds(address tokenAddress) public {
        DSTokenLike token = DSTokenLike(tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    
    
    function claimProxyFunds(address[] memory tokenAddresses) public {
        for (uint i = 0; i < tokenAddresses.length; i++)
            claimProxyFunds(tokenAddresses[i]);
    }

    // --- Utils ---
    function both(bool x, bool y) internal pure returns (bool z) {
        assembly{ z := and(x, y)}
    }

    function toWad(uint rad) internal pure returns (uint wad) {
        wad = rad / 10**27;
    }
}

contract GebProxySurplusAuctionActions is Common, AuctionCommon {

    
    
    
    function startAndIncreaseBidSize(address accountingEngineAddress, uint bidSize) public {
        AccountingEngineLike accountingEngine = AccountingEngineLike(accountingEngineAddress);
        SurplusAuctionHouseLike surplusAuctionHouse = SurplusAuctionHouseLike(accountingEngine.surplusAuctionHouse());
        DSTokenLike protocolToken = DSTokenLike(surplusAuctionHouse.protocolToken());

        // Starts auction
        uint auctionId = accountingEngine.auctionSurplus();
        require(protocolToken.transferFrom(msg.sender, address(this), bidSize), "geb-proxy-auction-actions/transfer-from-failed");
        protocolToken.approve(address(surplusAuctionHouse), bidSize);
        (, uint amountToSell,,,) = surplusAuctionHouse.bids(auctionId);
        // Bids
        surplusAuctionHouse.increaseBidSize(auctionId, amountToSell, bidSize);
    }

    
    
    
    
    function increaseBidSize(address auctionHouse, uint auctionId, uint bidSize) public {
        SurplusAuctionHouseLike surplusAuctionHouse = SurplusAuctionHouseLike(auctionHouse);
        DSTokenLike protocolToken = DSTokenLike(surplusAuctionHouse.protocolToken());

        require(protocolToken.transferFrom(msg.sender, address(this), bidSize), "geb-proxy-auction-actions/transfer-from-failed");
        protocolToken.approve(address(surplusAuctionHouse), bidSize);
        // Restarts auction if inactive
        (, uint amountToSell,, uint48 bidExpiry, uint48 auctionDeadline) = surplusAuctionHouse.bids(auctionId);
        if (auctionDeadline < now && bidExpiry == 0 && auctionDeadline > 0) {
            surplusAuctionHouse.restartAuction(auctionId);
        }
        // Bid
        surplusAuctionHouse.increaseBidSize(auctionId, amountToSell, bidSize);
    }

    
    
    
    
    function settleAuction(address coinJoin, address auctionHouse, uint auctionId) public {
        SurplusAuctionHouseLike surplusAuctionHouse = SurplusAuctionHouseLike(auctionHouse);
        SAFEEngineLike safeEngine = SAFEEngineLike(CoinJoinLike(coinJoin).safeEngine());
        (, uint amountToBuy,,,) = surplusAuctionHouse.bids(auctionId);
        // Settle auction
        surplusAuctionHouse.settleAuction(auctionId);
        // Allows coinJoin to access to proxy's COIN balance in the SAFEEngine
        if (safeEngine.canModifySAFE(address(this), address(coinJoin)) == 0) {
            safeEngine.approveSAFEModification(address(coinJoin));
        }
        // Sends system coins and protocol tokens to the owner
        CoinJoinLike(coinJoin).exit(msg.sender, toWad(amountToBuy));
        claimProxyFunds(surplusAuctionHouse.protocolToken());
    }
}