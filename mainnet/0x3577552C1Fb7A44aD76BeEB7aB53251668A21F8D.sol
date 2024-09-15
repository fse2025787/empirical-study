// SPDX-License-Identifier: Apache-2.0
pragma experimental ABIEncoderV2;


// 
/*

  Copyright 2021 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;





interface IBridgeAdapter {

    struct BridgeOrder {
        // Upper 16 bytes: uint128 protocol ID (right-aligned)
        // Lower 16 bytes: ASCII source name (left-aligned)
        bytes32 source;
        uint256 takerTokenAmount;
        uint256 makerTokenAmount;
        bytes bridgeData;
    }

    
    
    ///        encodes the (right-aligned) uint128 protocol ID and the
    ///        lower 16 bytes encodes an ASCII source name.
    
    
    
    
    event BridgeFill(
        bytes32 source,
        IERC20TokenV06 inputToken,
        IERC20TokenV06 outputToken,
        uint256 inputTokenAmount,
        uint256 outputTokenAmount
    );

    function trade(
        BridgeOrder calldata order,
        IERC20TokenV06 sellToken,
        IERC20TokenV06 buyToken,
        uint256 sellAmount
    )
        external
        returns (uint256 boughtAmount);
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


interface IERC20TokenV06 {

    // solhint-disable no-simple-event-func-name
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    
    
    
    
    function transfer(address to, uint256 value)
        external
        returns (bool);

    
    
    
    
    
    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        external
        returns (bool);

    
    
    
    
    function approve(address spender, uint256 value)
        external
        returns (bool);

    
    
    function totalSupply()
        external
        view
        returns (uint256);

    
    
    
    function balanceOf(address owner)
        external
        view
        returns (uint256);

    
    
    
    
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    
    function decimals()
        external
        view
        returns (uint8);
}

contract MixinBalancer {

    using LibERC20TokenV06 for IERC20TokenV06;

    function _tradeBalancer(
        IERC20TokenV06 sellToken,
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        internal
        returns (uint256 boughtAmount)
    {
        // Decode the bridge data.
        (IBalancerPool pool) = abi.decode(
            bridgeData,
            (IBalancerPool)
        );
        sellToken.approveIfBelow(
            address(pool),
            sellAmount
        );
        // Sell all of this contract's `sellToken` token balance.
        (boughtAmount,) = pool.swapExactAmountIn(
            sellToken,  // tokenIn
            sellAmount, // tokenAmountIn
            buyToken,   // tokenOut
            1,          // minAmountOut
            uint256(-1) // maxPrice
        );
        return boughtAmount;
    }
}

contract MixinBalancerV2 {

    using LibERC20TokenV06 for IERC20TokenV06;

    struct BalancerV2BridgeData {
        IBalancerV2Vault vault;
        bytes32 poolId;
    }

    function _tradeBalancerV2(
        IERC20TokenV06 sellToken,
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        internal
        returns (uint256 boughtAmount)
    {
        // Decode the bridge data.
        BalancerV2BridgeData memory data = abi.decode(bridgeData, (BalancerV2BridgeData));

        // Grant an allowance to the exchange to spend `fromTokenAddress` token.
        sellToken.approveIfBelow(address(data.vault), sellAmount);

        // Sell the entire sellAmount
        IBalancerV2Vault.SingleSwap memory request = IBalancerV2Vault.SingleSwap({
            poolId: data.poolId,
            kind: IBalancerV2Vault.SwapKind.GIVEN_IN,
            assetIn: sellToken,
            assetOut: buyToken,
            amount: sellAmount, // amount in
            userData: ""
        });

        IBalancerV2Vault.FundManagement memory funds = IBalancerV2Vault.FundManagement({
            sender: address(this),
            fromInternalBalance: false,
            recipient: payable(address(this)),
            toInternalBalance: false
        });

        boughtAmount = data.vault.swap(
            request,
            funds,
            1, // min amount out
            block.timestamp // expires after this block
        );
        return boughtAmount;
    }
}


contract MixinBancor {

    
    IERC20TokenV06 constant public BANCOR_ETH_ADDRESS =
        IERC20TokenV06(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    IEtherTokenV06 private immutable WETH;

    constructor(IEtherTokenV06 weth)
        public
    {
        WETH = weth;
    }

    function _tradeBancor(
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        internal
        returns (uint256 boughtAmount)
    {
        // Decode the bridge data.
        IBancorNetwork bancorNetworkAddress;
        IERC20TokenV06[] memory path;
        {
            address[] memory _path;
            (
                bancorNetworkAddress,
                _path
            ) = abi.decode(bridgeData, (IBancorNetwork, address[]));
            // To get around `abi.decode()` not supporting interface array types.
            assembly { path := _path }
        }

        require(path.length >= 2, "MixinBancor/PATH_LENGTH_MUST_BE_AT_LEAST_TWO");
        require(
            path[path.length - 1] == buyToken ||
            (path[path.length - 1] == BANCOR_ETH_ADDRESS && buyToken == WETH),
            "MixinBancor/LAST_ELEMENT_OF_PATH_MUST_MATCH_OUTPUT_TOKEN"
        );

        uint256 payableAmount = 0;
        // If it's ETH in the path then withdraw from WETH
        // The Bancor path will have ETH as the 0xeee address
        // Bancor expects to be paid in ETH not WETH
        if (path[0] == BANCOR_ETH_ADDRESS) {
            WETH.withdraw(sellAmount);
            payableAmount = sellAmount;
        } else {
            // Grant an allowance to the Bancor Network.
            LibERC20TokenV06.approveIfBelow(
                path[0],
                address(bancorNetworkAddress),
                sellAmount
            );
        }

        // Convert the tokens
        boughtAmount = bancorNetworkAddress.convertByPath{value: payableAmount}(
            path, // path originating with source token and terminating in destination token
            sellAmount, // amount of source token to trade
            1, // minimum amount of destination token expected to receive
            address(this), // beneficiary
            address(0), // affiliateAccount; no fee paid
            0 // affiliateFee; no fee paid
        );
        if (path[path.length - 1] == BANCOR_ETH_ADDRESS) {
            WETH.deposit{value: boughtAmount}();
        }

        return boughtAmount;
    }
}

contract MixinCoFiX {

    using LibERC20TokenV06 for IERC20TokenV06;

    function _tradeCoFiX(
        IERC20TokenV06 sellToken,
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        internal
        returns (uint256 boughtAmount)
    {
        (uint256 fee, ICoFiXPair pool) = abi.decode(bridgeData, (uint256, ICoFiXPair));
        // Transfer tokens into the pool
        LibERC20TokenV06.compatTransfer(
            sellToken,
            address(pool),
            sellAmount
        );
        // Call the swap exact with the tokens now in the pool
        // pay the NEST Oracle fee with ETH
        (/* In */, boughtAmount, , ) = pool.swapWithExact{value: fee}(
            address(buyToken),
            address(this)
        );

        return boughtAmount;
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;








contract MixinCurve {

    using LibERC20TokenV06 for IERC20TokenV06;
    using LibSafeMathV06 for uint256;
    using LibRichErrorsV06 for bytes;

    
    IEtherTokenV06 private immutable WETH;

    constructor(IEtherTokenV06 weth)
        public
    {
        WETH = weth;
    }


    struct CurveBridgeData {
        address curveAddress;
        bytes4 exchangeFunctionSelector;
        int128 fromCoinIdx;
        int128 toCoinIdx;
    }

    function _tradeCurve(
        IERC20TokenV06 sellToken,
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        internal
        returns (uint256 boughtAmount)
    {
        // Decode the bridge data to get the Curve metadata.
        CurveBridgeData memory data = abi.decode(bridgeData, (CurveBridgeData));
        uint256 payableAmount;
        if (sellToken == WETH) {
            payableAmount = sellAmount;
            WETH.withdraw(sellAmount);
        } else {
            sellToken.approveIfBelow(data.curveAddress, sellAmount);
        }

        uint256 beforeBalance = buyToken.balanceOf(address(this));
        (bool success, bytes memory resultData) =
            data.curveAddress.call{value: payableAmount}(abi.encodeWithSelector(
                data.exchangeFunctionSelector,
                data.fromCoinIdx,
                data.toCoinIdx,
                // dx
                sellAmount,
                // min dy
                1
            ));
        if (!success) {
            resultData.rrevert();
        }

        if (buyToken == WETH) {
            boughtAmount = address(this).balance;
            WETH.deposit{ value: boughtAmount }();
        }

        return buyToken.balanceOf(address(this)).safeSub(beforeBalance);
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;








contract MixinCurveV2 {

    using LibERC20TokenV06 for IERC20TokenV06;
    using LibSafeMathV06 for uint256;
    using LibRichErrorsV06 for bytes;

    struct CurveBridgeDataV2 {
        address curveAddress;
        bytes4 exchangeFunctionSelector;
        int128 fromCoinIdx;
        int128 toCoinIdx;
    }

    function _tradeCurveV2(
        IERC20TokenV06 sellToken,
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        internal
        returns (uint256 boughtAmount)
    {
        // Decode the bridge data to get the Curve metadata.
        CurveBridgeDataV2 memory data = abi.decode(bridgeData, (CurveBridgeDataV2));
        sellToken.approveIfBelow(data.curveAddress, sellAmount);

        uint256 beforeBalance = buyToken.balanceOf(address(this));
        (bool success, bytes memory resultData) =
            data.curveAddress.call(abi.encodeWithSelector(
                data.exchangeFunctionSelector,
                data.fromCoinIdx,
                data.toCoinIdx,
                // dx
                sellAmount,
                // min dy
                1
            ));
        if (!success) {
            resultData.rrevert();
        }

        return buyToken.balanceOf(address(this)).safeSub(beforeBalance);
    }
}

// 

/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;






contract MixinCryptoCom
{
    using LibERC20TokenV06 for IERC20TokenV06;

    function _tradeCryptoCom(
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        internal
        returns (uint256 boughtAmount)
    {
        IUniswapV2Router02 router;
        IERC20TokenV06[] memory path;
        {
            address[] memory _path;
            (router, _path) = abi.decode(bridgeData, (IUniswapV2Router02, address[]));
            // To get around `abi.decode()` not supporting interface array types.
            assembly { path := _path }
        }

        require(path.length >= 2, "MixinCryptoCom/PATH_LENGTH_MUST_BE_AT_LEAST_TWO");
        require(
            path[path.length - 1] == buyToken,
            "MixinCryptoCom/LAST_ELEMENT_OF_PATH_MUST_MATCH_OUTPUT_TOKEN"
        );
        // Grant the CryptoCom router an allowance to sell the first token.
        path[0].approveIfBelow(address(router), sellAmount);

        uint[] memory amounts = router.swapExactTokensForTokens(
             // Sell all tokens we hold.
            sellAmount,
             // Minimum buy amount.
            1,
            // Convert to `buyToken` along this path.
            path,
            // Recipient is `this`.
            address(this),
            // Expires after this block.
            block.timestamp
        );
        return amounts[amounts.length-1];
    }
}

contract MixinUniswapV2 {

    using LibERC20TokenV06 for IERC20TokenV06;

    function _tradeUniswapV2(
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        internal
        returns (uint256 boughtAmount)
    {
        IUniswapV2Router02 router;
        IERC20TokenV06[] memory path;
        {
            address[] memory _path;
            (router, _path) = abi.decode(bridgeData, (IUniswapV2Router02, address[]));
            // To get around `abi.decode()` not supporting interface array types.
            assembly { path := _path }
        }

        require(path.length >= 2, "MixinUniswapV2/PATH_LENGTH_MUST_BE_AT_LEAST_TWO");
        require(
            path[path.length - 1] == buyToken,
            "MixinUniswapV2/LAST_ELEMENT_OF_PATH_MUST_MATCH_OUTPUT_TOKEN"
        );
        // Grant the Uniswap router an allowance to sell the first token.
        path[0].approveIfBelow(address(router), sellAmount);

        uint[] memory amounts = router.swapExactTokensForTokens(
             // Sell all tokens we hold.
            sellAmount,
             // Minimum buy amount.
            1,
            // Convert to `buyToken` along this path.
            path,
            // Recipient is `this`.
            address(this),
            // Expires after this block.
            block.timestamp
        );
        return amounts[amounts.length-1];
    }
}


contract MixinDodo {

    using LibERC20TokenV06 for IERC20TokenV06;

    function _tradeDodo(
        IERC20TokenV06 sellToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        internal
        returns (uint256 boughtAmount)
    {
        (IDODOHelper helper, IDODO pool, bool isSellBase) =
            abi.decode(bridgeData, (IDODOHelper, IDODO, bool));

        // Grant the Dodo pool contract an allowance to sell the first token.
        sellToken.approveIfBelow(address(pool), sellAmount);

        if (isSellBase) {
            // Sell the Base token directly against the contract
            boughtAmount = pool.sellBaseToken(
                // amount to sell
                sellAmount,
                // min receive amount
                1,
                new bytes(0)
            );
        } else {
            // Need to re-calculate the sell quote amount into buyBase
            boughtAmount = helper.querySellQuoteToken(
                pool,
                sellAmount
            );
            pool.buyBaseToken(
                // amount to buy
                boughtAmount,
                // max pay amount
                sellAmount,
                new bytes(0)
            );
        }

        return boughtAmount;
    }
}


contract MixinDodoV2 {

    using LibERC20TokenV06 for IERC20TokenV06;

    function _tradeDodoV2(
        IERC20TokenV06 sellToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        internal
        returns (uint256 boughtAmount)
    {
        (IDODOV2 pool, bool isSellBase) =
            abi.decode(bridgeData, (IDODOV2, bool));

        // Transfer the tokens into the pool
        sellToken.compatTransfer(address(pool), sellAmount);

        boughtAmount = isSellBase ?
            pool.sellBase(address(this))
            : pool.sellQuote(address(this));
    }
}

contract MixinKyber {

    using LibERC20TokenV06 for IERC20TokenV06;

    
    IERC20TokenV06 private immutable KYBER_ETH_ADDRESS =
        IERC20TokenV06(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    
    IEtherTokenV06 private immutable WETH;

    constructor(IEtherTokenV06 weth)
        public
    {
        WETH = weth;
    }

    function _tradeKyber(
        IERC20TokenV06 sellToken,
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        internal
        returns (uint256 boughtAmount)
    {
        (IKyberNetworkProxy kyber, bytes memory hint) =
            abi.decode(bridgeData, (IKyberNetworkProxy, bytes));

        uint256 payableAmount = 0;
        if (sellToken != WETH) {
            // If the input token is not WETH, grant an allowance to the exchange
            // to spend them.
            sellToken.approveIfBelow(
                address(kyber),
                sellAmount
            );
        } else {
            // If the input token is WETH, unwrap it and attach it to the call.
            payableAmount = sellAmount;
            WETH.withdraw(payableAmount);
        }

        // Try to sell all of this contract's input token balance through
        // `KyberNetworkProxy.trade()`.
        boughtAmount = kyber.tradeWithHint{ value: payableAmount }(
            // Input token.
            sellToken == WETH ? KYBER_ETH_ADDRESS : sellToken,
            // Sell amount.
            sellAmount,
            // Output token.
            buyToken == WETH ? KYBER_ETH_ADDRESS : buyToken,
            // Transfer to this contract
            address(uint160(address(this))),
            // Buy as much as possible.
            uint256(-1),
            // Lowest minimum conversion rate
            1,
            // No affiliate address.
            address(0),
            hint
        );
        // If receving ETH, wrap it to WETH.
        if (buyToken == WETH) {
            WETH.deposit{ value: boughtAmount }();
        }
        return boughtAmount;
    }
}

contract MixinKyberDmm {

    using LibERC20TokenV06 for IERC20TokenV06;

    function _tradeKyberDmm(
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        internal
        returns (uint256 boughtAmount)
    {
        address router;
        address[] memory pools;
        address[] memory path;
        (router, pools, path) = abi.decode(bridgeData, (address, address[], address[]));

        require(pools.length >= 1, "MixinKyberDmm/POOLS_LENGTH_MUST_BE_AT_LEAST_ONE");
        require(path.length == pools.length + 1, "MixinKyberDmm/ARRAY_LENGTH_MISMATCH");
         require(
             path[path.length - 1] == address(buyToken),
             "MixinKyberDmm/LAST_ELEMENT_OF_PATH_MUST_MATCH_OUTPUT_TOKEN"
         );
        // Grant the KyberDmm router an allowance to sell the first token.
        IERC20TokenV06(path[0]).approveIfBelow(address(router), sellAmount);

        uint[] memory amounts = IKyberDmmRouter(router).swapExactTokensForTokens(
             // Sell all tokens we hold.
            sellAmount,
             // Minimum buy amount.
            1,
            pools,
            // Convert to `buyToken` along this path.
            path,
            // Recipient is `this`.
            address(this),
            // Expires after this block.
            block.timestamp
        );
        return amounts[amounts.length-1];
    }
}

contract MixinMakerPSM {

    using LibERC20TokenV06 for IERC20TokenV06;
    using LibSafeMathV06 for uint256;

    struct MakerPsmBridgeData {
        address psmAddress;
        address gemTokenAddres;
    }

    // Maker units
    // wad: fixed point decimal with 18 decimals (for basic quantities, e.g. balances)
    uint256 constant private WAD = 10 ** 18;
    // ray: fixed point decimal with 27 decimals (for precise quantites, e.g. ratios)
    uint256 constant private RAY = 10 ** 27;
    // rad: fixed point decimal with 45 decimals (result of integer multiplication with a wad and a ray)
    uint256 constant private RAD = 10 ** 45;
    // See https://github.com/makerdao/dss/blob/master/DEVELOPING.md

    function _tradeMakerPsm(
        IERC20TokenV06 sellToken,
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        internal
        returns (uint256 boughtAmount)
    {
        // Decode the bridge data.
        MakerPsmBridgeData memory data = abi.decode(bridgeData, (MakerPsmBridgeData));
        uint256 beforeBalance = buyToken.balanceOf(address(this));

        IPSM psm = IPSM(data.psmAddress);

        if (address(sellToken) == data.gemTokenAddres) {
            sellToken.approveIfBelow(
                psm.gemJoin(),
                sellAmount
            );

            psm.sellGem(address(this), sellAmount);
        } else if (address(buyToken) == data.gemTokenAddres) {
            uint256 feeDivisor = WAD.safeAdd(psm.tout()); // eg. 1.001 * 10 ** 18 with 0.1% fee [tout is in wad];
            uint256 buyTokenBaseUnit = uint256(10) ** uint256(buyToken.decimals());
            uint256 gemAmount =  sellAmount.safeMul(buyTokenBaseUnit).safeDiv(feeDivisor);

            sellToken.approveIfBelow(
                data.psmAddress,
                sellAmount
            );
            psm.buyGem(address(this), gemAmount);
        }

        return buyToken.balanceOf(address(this)).safeSub(beforeBalance);
    }
}


contract MixinMooniswap {

    using LibERC20TokenV06 for IERC20TokenV06;
    using LibERC20TokenV06 for IEtherTokenV06;

    
    IEtherTokenV06 private immutable WETH;

    constructor(IEtherTokenV06 weth)
        public
    {
        WETH = weth;
    }

    function _tradeMooniswap(
        IERC20TokenV06 sellToken,
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        internal
        returns (uint256 boughtAmount)
    {
        (IMooniswapPool pool) = abi.decode(bridgeData, (IMooniswapPool));

        // Convert WETH to ETH.
        uint256 ethValue = 0;
        if (sellToken == WETH) {
            WETH.withdraw(sellAmount);
            ethValue = sellAmount;
        } else {
            // Grant the pool an allowance.
            sellToken.approveIfBelow(
                address(pool),
                sellAmount
            );
        }

        boughtAmount = pool.swap{value: ethValue}(
            sellToken == WETH ? IERC20TokenV06(0) : sellToken,
            buyToken == WETH ? IERC20TokenV06(0) : buyToken,
            sellAmount,
            1,
            address(0)
        );

        // Wrap ETH to WETH.
        if (buyToken == WETH) {
            WETH.deposit{value:boughtAmount}();
        }
    }
}

contract MixinMStable {

    using LibERC20TokenV06 for IERC20TokenV06;

    function _tradeMStable(
        IERC20TokenV06 sellToken,
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        internal
        returns (uint256 boughtAmount)
    {
        (IMStable mstable) = abi.decode(bridgeData, (IMStable));

        // Grant an allowance to the exchange to spend `sellToken` token.
        sellToken.approveIfBelow(address(mstable), sellAmount);

        boughtAmount = mstable.swap(
            sellToken,
            buyToken,
            sellAmount,
            // Minimum buy amount.
            1,
            address(this)
        );
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;







contract MixinNerve {

    using LibERC20TokenV06 for IERC20TokenV06;
    using LibSafeMathV06 for uint256;
    using LibRichErrorsV06 for bytes;


    struct NerveBridgeData {
        address pool;
        bytes4 exchangeFunctionSelector;
        int128 fromCoinIdx;
        int128 toCoinIdx;
    }

    function _tradeNerve(
        IERC20TokenV06 sellToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        internal
        returns (uint256 boughtAmount)
    {
        // Basically a Curve fork but the swap option has a deadline

        // Decode the bridge data to get the Curve metadata.
        NerveBridgeData memory data = abi.decode(bridgeData, (NerveBridgeData));
        sellToken.approveIfBelow(data.pool, sellAmount);
        (bool success, bytes memory resultData) =
            data.pool.call(abi.encodeWithSelector(
                data.exchangeFunctionSelector,
                data.fromCoinIdx,
                data.toCoinIdx,
                // dx
                sellAmount,
                // min dy
                1,
                // deadline
                block.timestamp
            ));
        if (!success) {
            resultData.rrevert();
        }
        return abi.decode(resultData, (uint256));
    }
}

contract MixinOasis {

    using LibERC20TokenV06 for IERC20TokenV06;

    function _tradeOasis(
        IERC20TokenV06 sellToken,
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        internal
        returns (uint256 boughtAmount)
    {

        (IOasis oasis) = abi.decode(bridgeData, (IOasis));

        // Grant an allowance to the exchange to spend `sellToken` token.
        sellToken.approveIfBelow(
            address(oasis),
            sellAmount
        );
        // Try to sell all of this contract's `sellToken` token balance.
        boughtAmount = oasis.sellAllAmount(
            sellToken,
            sellAmount,
            buyToken,
            // min fill amount
            1
        );
        return boughtAmount;
    }
}

contract MixinShell {

    using LibERC20TokenV06 for IERC20TokenV06;

    function _tradeShell(
        IERC20TokenV06 sellToken,
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        internal
        returns (uint256 boughtAmount)
    {
        IShell pool = abi.decode(bridgeData, (IShell));

        // Grant the Shell contract an allowance to sell the first token.
        IERC20TokenV06(sellToken).approveIfBelow(
            address(pool),
            sellAmount
        );

        boughtAmount = pool.originSwap(
            sellToken,
            buyToken,
             // Sell all tokens we hold.
            sellAmount,
             // Minimum buy amount.
            1,
            // deadline
            block.timestamp + 1
        );
        return boughtAmount;
    }
}

contract MixinUniswap {

    using LibERC20TokenV06 for IERC20TokenV06;

    
    IEtherTokenV06 private immutable WETH;

    constructor(IEtherTokenV06 weth)
        public
    {
        WETH = weth;
    }

    function _tradeUniswap(
        IERC20TokenV06 sellToken,
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        internal
        returns (uint256 boughtAmount)
    {
        IUniswapExchangeFactory exchangeFactory =
            abi.decode(bridgeData, (IUniswapExchangeFactory));

        // Get the exchange for the token pair.
        IUniswapExchange exchange = _getUniswapExchangeForTokenPair(
            exchangeFactory,
            sellToken,
            buyToken
        );

        // Convert from WETH to a token.
        if (sellToken == WETH) {
            // Unwrap the WETH.
            WETH.withdraw(sellAmount);
            // Buy as much of `buyToken` token with ETH as possible
            boughtAmount = exchange.ethToTokenTransferInput{ value: sellAmount }(
                // Minimum buy amount.
                1,
                // Expires after this block.
                block.timestamp,
                // Recipient is `this`.
                address(this)
            );

        // Convert from a token to WETH.
        } else if (buyToken == WETH) {
            // Grant the exchange an allowance.
            sellToken.approveIfBelow(
                address(exchange),
                sellAmount
            );
            // Buy as much ETH with `sellToken` token as possible.
            boughtAmount = exchange.tokenToEthSwapInput(
                // Sell all tokens we hold.
                sellAmount,
                // Minimum buy amount.
                1,
                // Expires after this block.
                block.timestamp
            );
            // Wrap the ETH.
            WETH.deposit{ value: boughtAmount }();
        // Convert from one token to another.
        } else {
            // Grant the exchange an allowance.
            sellToken.approveIfBelow(
                address(exchange),
                sellAmount
            );
            // Buy as much `buyToken` token with `sellToken` token
            boughtAmount = exchange.tokenToTokenSwapInput(
                // Sell all tokens we hold.
                sellAmount,
                // Minimum buy amount.
                1,
                // Must buy at least 1 intermediate wei of ETH.
                1,
                // Expires after this block.
                block.timestamp,
                // Convert to `buyToken`.
                buyToken
            );
        }

        return boughtAmount;
    }

    
    ///      In the case of a WETH-token exchange, this will be the non-WETH token.
    ///      In th ecase of a token-token exchange, this will be the first token.
    
    
    
    
    function _getUniswapExchangeForTokenPair(
        IUniswapExchangeFactory exchangeFactory,
        IERC20TokenV06 sellToken,
        IERC20TokenV06 buyToken
    )
        private
        view
        returns (IUniswapExchange exchange)
    {
        // Whichever isn't WETH is the exchange token.
        exchange = sellToken == WETH
            ? exchangeFactory.getExchange(buyToken)
            : exchangeFactory.getExchange(sellToken);
        require(address(exchange) != address(0), "MixinUniswap/NO_EXCHANGE");
    }
}

contract MixinUniswapV3 {

    using LibERC20TokenV06 for IERC20TokenV06;

    function _tradeUniswapV3(
        IERC20TokenV06 sellToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        internal
        returns (uint256 boughtAmount)
    {
        (IUniswapV3Router router, bytes memory path) =
            abi.decode(bridgeData, (IUniswapV3Router, bytes));

        // Grant the Uniswap router an allowance to sell the sell token.
        sellToken.approveIfBelow(address(router), sellAmount);

        boughtAmount = router.exactInput(IUniswapV3Router.ExactInputParams({
            path: path,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: sellAmount,
            amountOutMinimum: 1
        }));
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;







contract MixinZeroExBridge {

    using LibERC20TokenV06 for IERC20TokenV06;
    using LibSafeMathV06 for uint256;

    function _tradeZeroExBridge(
        IERC20TokenV06 sellToken,
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        bytes memory bridgeData
    )
        internal
        returns (uint256 boughtAmount)
    {
        (ILiquidityProvider provider, bytes memory lpData) =
            abi.decode(bridgeData, (ILiquidityProvider, bytes));
        // Trade the good old fashioned way
        sellToken.compatTransfer(
            address(provider),
            sellAmount
        );
        boughtAmount = provider.sellTokenForToken(
            sellToken,
            buyToken,
            address(this), // recipient
            1, // minBuyAmount
            lpData
        );
    }
}
// 
/*

  Copyright 2021 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


























contract BridgeAdapter is
    IBridgeAdapter,
    MixinBalancer,
    MixinBalancerV2,
    MixinBancor,
    MixinCoFiX,
    MixinCurve,
    MixinCurveV2,
    MixinCryptoCom,
    MixinDodo,
    MixinDodoV2,
    MixinKyber,
    MixinKyberDmm,
    MixinMakerPSM,
    MixinMooniswap,
    MixinMStable,
    MixinNerve,
    MixinOasis,
    MixinShell,
    MixinUniswap,
    MixinUniswapV2,
    MixinUniswapV3,
    MixinZeroExBridge
{
    constructor(IEtherTokenV06 weth)
        public
        MixinBalancer()
        MixinBalancerV2()
        MixinBancor(weth)
        MixinCoFiX()
        MixinCurve(weth)
        MixinCurveV2()
        MixinCryptoCom()
        MixinDodo()
        MixinDodoV2()
        MixinKyber(weth)
        MixinMakerPSM()
        MixinMooniswap(weth)
        MixinMStable()
        MixinNerve()
        MixinOasis()
        MixinShell()
        MixinUniswap(weth)
        MixinUniswapV2()
        MixinUniswapV3()
        MixinZeroExBridge()
    {}

    function trade(
        BridgeOrder memory order,
        IERC20TokenV06 sellToken,
        IERC20TokenV06 buyToken,
        uint256 sellAmount
    )
        public
        override
        returns (uint256 boughtAmount)
    {
        uint128 protocolId = uint128(uint256(order.source) >> 128);
        if (protocolId == BridgeProtocols.CURVE) {
            boughtAmount = _tradeCurve(
                sellToken,
                buyToken,
                sellAmount,
                order.bridgeData
            );
        } else if (protocolId == BridgeProtocols.CURVEV2) {
            boughtAmount = _tradeCurveV2(
                sellToken,
                buyToken,
                sellAmount,
                order.bridgeData
            );
        } else if (protocolId == BridgeProtocols.UNISWAPV3) {
            boughtAmount = _tradeUniswapV3(
                sellToken,
                sellAmount,
                order.bridgeData
            );
        } else if (protocolId == BridgeProtocols.UNISWAPV2) {
            boughtAmount = _tradeUniswapV2(
                buyToken,
                sellAmount,
                order.bridgeData
            );
        } else if (protocolId == BridgeProtocols.UNISWAP) {
            boughtAmount = _tradeUniswap(
                sellToken,
                buyToken,
                sellAmount,
                order.bridgeData
            );
        } else if (protocolId == BridgeProtocols.BALANCER) {
            boughtAmount = _tradeBalancer(
                sellToken,
                buyToken,
                sellAmount,
                order.bridgeData
            );
        } else if (protocolId == BridgeProtocols.BALANCERV2) {
            boughtAmount = _tradeBalancerV2(
                sellToken,
                buyToken,
                sellAmount,
                order.bridgeData
            );
        } else if (protocolId == BridgeProtocols.KYBER) {
            boughtAmount = _tradeKyber(
                sellToken,
                buyToken,
                sellAmount,
                order.bridgeData
            );
        } else if (protocolId == BridgeProtocols.MAKERPSM) {
            boughtAmount = _tradeMakerPsm(
                sellToken,
                buyToken,
                sellAmount,
                order.bridgeData
            );
        } else if (protocolId == BridgeProtocols.MOONISWAP) {
            boughtAmount = _tradeMooniswap(
                sellToken,
                buyToken,
                sellAmount,
                order.bridgeData
            );
        } else if (protocolId == BridgeProtocols.MSTABLE) {
            boughtAmount = _tradeMStable(
                sellToken,
                buyToken,
                sellAmount,
                order.bridgeData
            );
        } else if (protocolId == BridgeProtocols.OASIS) {
            boughtAmount = _tradeOasis(
                sellToken,
                buyToken,
                sellAmount,
                order.bridgeData
            );
        } else if (protocolId == BridgeProtocols.SHELL) {
            boughtAmount = _tradeShell(
                sellToken,
                buyToken,
                sellAmount,
                order.bridgeData
            );
        } else if (protocolId == BridgeProtocols.DODO) {
            boughtAmount = _tradeDodo(
                sellToken,
                sellAmount,
                order.bridgeData
            );
        } else if (protocolId == BridgeProtocols.DODOV2) {
            boughtAmount = _tradeDodoV2(
                sellToken,
                sellAmount,
                order.bridgeData
            );
        } else if (protocolId == BridgeProtocols.CRYPTOCOM) {
            boughtAmount = _tradeCryptoCom(
                buyToken,
                sellAmount,
                order.bridgeData
            );
        } else if (protocolId == BridgeProtocols.BANCOR) {
            boughtAmount = _tradeBancor(
                buyToken,
                sellAmount,
                order.bridgeData
            );
        } else if (protocolId == BridgeProtocols.COFIX) {
            boughtAmount = _tradeCoFiX(
                sellToken,
                buyToken,
                sellAmount,
                order.bridgeData
            );
        } else if (protocolId == BridgeProtocols.NERVE) {
            boughtAmount = _tradeNerve(
                sellToken,
                sellAmount,
                order.bridgeData
            );
        } else if (protocolId == BridgeProtocols.KYBERDMM) {
            boughtAmount = _tradeKyberDmm(
                buyToken,
                sellAmount,
                order.bridgeData
            );
        } else {
            boughtAmount = _tradeZeroExBridge(
                sellToken,
                buyToken,
                sellAmount,
                order.bridgeData
            );
        }

        emit BridgeFill(
            order.source,
            sellToken,
            buyToken,
            sellAmount,
            boughtAmount
        );
    }
}

// 
/*

  Copyright 2021 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;





library BridgeProtocols {
    // A incrementally increasing, append-only list of protocol IDs.
    // We don't use an enum so solidity doesn't throw when we pass in a
    // new protocol ID that hasn't been rolled up yet.
    uint128 internal constant UNKNOWN     = 0;
    uint128 internal constant CURVE       = 1;
    uint128 internal constant UNISWAPV2   = 2;
    uint128 internal constant UNISWAP     = 3;
    uint128 internal constant BALANCER    = 4;
    uint128 internal constant KYBER       = 5;
    uint128 internal constant MOONISWAP   = 6;
    uint128 internal constant MSTABLE     = 7;
    uint128 internal constant OASIS       = 8;
    uint128 internal constant SHELL       = 9;
    uint128 internal constant DODO        = 10;
    uint128 internal constant DODOV2      = 11;
    uint128 internal constant CRYPTOCOM   = 12;
    uint128 internal constant BANCOR      = 13;
    uint128 internal constant COFIX       = 14;
    uint128 internal constant NERVE       = 15;
    uint128 internal constant MAKERPSM    = 16;
    uint128 internal constant BALANCERV2  = 17;
    uint128 internal constant UNISWAPV3   = 18;
    uint128 internal constant KYBERDMM    = 19;
    uint128 internal constant CURVEV2     = 20;
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;




interface IBalancerPool {
    
    
    
    
    
    
    
    
    ///         token pair for this pool.
    function swapExactAmountIn(
        IERC20TokenV06 tokenIn,
        uint tokenAmountIn,
        IERC20TokenV06 tokenOut,
        uint minAmountOut,
        uint maxPrice
    ) external returns (uint tokenAmountOut, uint spotPriceAfter);
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;






library LibERC20TokenV06 {
    bytes constant private DECIMALS_CALL_DATA = hex"313ce567";

    
    ///      Reverts if the result fails `isSuccessfulResult()` or the call reverts.
    
    
    
    function compatApprove(
        IERC20TokenV06 token,
        address spender,
        uint256 allowance
    )
        internal
    {
        bytes memory callData = abi.encodeWithSelector(
            token.approve.selector,
            spender,
            allowance
        );
        _callWithOptionalBooleanResult(address(token), callData);
    }

    
    ///      maximum if the current approval is not already >= an amount.
    ///      Reverts if the result fails `isSuccessfulResult()` or the call reverts.
    
    
    
    function approveIfBelow(
        IERC20TokenV06 token,
        address spender,
        uint256 amount
    )
        internal
    {
        if (token.allowance(address(this), spender) < amount) {
            compatApprove(token, spender, uint256(-1));
        }
    }

    
    ///      Reverts if the result fails `isSuccessfulResult()` or the call reverts.
    
    
    
    function compatTransfer(
        IERC20TokenV06 token,
        address to,
        uint256 amount
    )
        internal
    {
        bytes memory callData = abi.encodeWithSelector(
            token.transfer.selector,
            to,
            amount
        );
        _callWithOptionalBooleanResult(address(token), callData);
    }

    
    ///      Reverts if the result fails `isSuccessfulResult()` or the call reverts.
    
    
    
    
    function compatTransferFrom(
        IERC20TokenV06 token,
        address from,
        address to,
        uint256 amount
    )
        internal
    {
        bytes memory callData = abi.encodeWithSelector(
            token.transferFrom.selector,
            from,
            to,
            amount
        );
        _callWithOptionalBooleanResult(address(token), callData);
    }

    
    ///      Returns `18` if the call reverts.
    
    
    function compatDecimals(IERC20TokenV06 token)
        internal
        view
        returns (uint8 tokenDecimals)
    {
        tokenDecimals = 18;
        (bool didSucceed, bytes memory resultData) = address(token).staticcall(DECIMALS_CALL_DATA);
        if (didSucceed && resultData.length >= 32) {
            tokenDecimals = uint8(LibBytesV06.readUint256(resultData, 0));
        }
    }

    
    ///      Returns `0` if the call reverts.
    
    
    
    
    function compatAllowance(IERC20TokenV06 token, address owner, address spender)
        internal
        view
        returns (uint256 allowance_)
    {
        (bool didSucceed, bytes memory resultData) = address(token).staticcall(
            abi.encodeWithSelector(
                token.allowance.selector,
                owner,
                spender
            )
        );
        if (didSucceed && resultData.length >= 32) {
            allowance_ = LibBytesV06.readUint256(resultData, 0);
        }
    }

    
    ///      Returns `0` if the call reverts.
    
    
    
    function compatBalanceOf(IERC20TokenV06 token, address owner)
        internal
        view
        returns (uint256 balance)
    {
        (bool didSucceed, bytes memory resultData) = address(token).staticcall(
            abi.encodeWithSelector(
                token.balanceOf.selector,
                owner
            )
        );
        if (didSucceed && resultData.length >= 32) {
            balance = LibBytesV06.readUint256(resultData, 0);
        }
    }

    
    ///      is a successful result. Supported functions are `transfer()`,
    ///      `transferFrom()`, and `approve()`.
    
    
    function isSuccessfulResult(bytes memory resultData)
        internal
        pure
        returns (bool isSuccessful)
    {
        if (resultData.length == 0) {
            return true;
        }
        if (resultData.length >= 32) {
            uint256 result = LibBytesV06.readUint256(resultData, 0);
            if (result == 1) {
                return true;
            }
        }
    }

    
    ///      and asserts that either nothing was returned or a single boolean
    ///      was returned equal to `true`.
    
    
    function _callWithOptionalBooleanResult(
        address target,
        bytes memory callData
    )
        private
    {
        (bool didSucceed, bytes memory resultData) = target.call(callData);
        if (didSucceed && isSuccessfulResult(resultData)) {
            return;
        }
        LibRichErrorsV06.rrevert(resultData);
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


library LibRichErrorsV06 {

    // bytes4(keccak256("Error(string)"))
    bytes4 internal constant STANDARD_ERROR_SELECTOR = 0x08c379a0;

    // solhint-disable func-name-mixedcase
    
    ///      This is the same payload that would be included by a `revert(string)`
    ///      solidity statement. It has the function signature `Error(string)`.
    
    
    function StandardError(string memory message)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            STANDARD_ERROR_SELECTOR,
            bytes(message)
        );
    }
    // solhint-enable func-name-mixedcase

    
    
    function rrevert(bytes memory errorData)
        internal
        pure
    {
        assembly {
            revert(add(errorData, 0x20), mload(errorData))
        }
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;





library LibBytesV06 {

    using LibBytesV06 for bytes;

    
    
    
    ///         points to the header of the byte array which contains
    ///         the length.
    function rawAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := input
        }
        return memoryAddress;
    }

    
    
    
    function contentAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := add(input, 32)
        }
        return memoryAddress;
    }

    
    
    
    
    function memCopy(
        uint256 dest,
        uint256 source,
        uint256 length
    )
        internal
        pure
    {
        if (length < 32) {
            // Handle a partial word by reading destination and masking
            // off the bits we are interested in.
            // This correctly handles overlap, zero lengths and source == dest
            assembly {
                let mask := sub(exp(256, sub(32, length)), 1)
                let s := and(mload(source), not(mask))
                let d := and(mload(dest), mask)
                mstore(dest, or(s, d))
            }
        } else {
            // Skip the O(length) loop when source == dest.
            if (source == dest) {
                return;
            }

            // For large copies we copy whole words at a time. The final
            // word is aligned to the end of the range (instead of after the
            // previous) to handle partial words. So a copy will look like this:
            //
            //  ####
            //      ####
            //          ####
            //            ####
            //
            // We handle overlap in the source and destination range by
            // changing the copying direction. This prevents us from
            // overwriting parts of source that we still need to copy.
            //
            // This correctly handles source == dest
            //
            if (source > dest) {
                assembly {
                    // We subtract 32 from `sEnd` and `dEnd` because it
                    // is easier to compare with in the loop, and these
                    // are also the addresses we need for copying the
                    // last bytes.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    // Remember the last 32 bytes of source
                    // This needs to be done here and not after the loop
                    // because we may have overwritten the last bytes in
                    // source already due to overlap.
                    let last := mload(sEnd)

                    // Copy whole words front to back
                    // Note: the first check is always true,
                    // this could have been a do-while loop.
                    // solhint-disable-next-line no-empty-blocks
                    for {} lt(source, sEnd) {} {
                        mstore(dest, mload(source))
                        source := add(source, 32)
                        dest := add(dest, 32)
                    }

                    // Write the last 32 bytes
                    mstore(dEnd, last)
                }
            } else {
                assembly {
                    // We subtract 32 from `sEnd` and `dEnd` because those
                    // are the starting points when copying a word at the end.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    // Remember the first 32 bytes of source
                    // This needs to be done here and not after the loop
                    // because we may have overwritten the first bytes in
                    // source already due to overlap.
                    let first := mload(source)

                    // Copy whole words back to front
                    // We use a signed comparisson here to allow dEnd to become
                    // negative (happens when source and dest < 32). Valid
                    // addresses in local memory will never be larger than
                    // 2**255, so they can be safely re-interpreted as signed.
                    // Note: the first check is always true,
                    // this could have been a do-while loop.
                    // solhint-disable-next-line no-empty-blocks
                    for {} slt(dest, dEnd) {} {
                        mstore(dEnd, mload(sEnd))
                        sEnd := sub(sEnd, 32)
                        dEnd := sub(dEnd, 32)
                    }

                    // Write the first 32 bytes
                    mstore(dest, first)
                }
            }
        }
    }

    
    
    
    
    
    function slice(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        // Ensure that the from and to positions are valid positions for a slice within
        // the byte array that is being used.
        if (from > to) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                from,
                to
            ));
        }
        if (to > b.length) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                to,
                b.length
            ));
        }

        // Create a new bytes structure and copy contents
        result = new bytes(to - from);
        memCopy(
            result.contentAddress(),
            b.contentAddress() + from,
            result.length
        );
        return result;
    }

    
    ///      When `from == 0`, the original array will match the slice.
    ///      In other cases its state will be corrupted.
    
    
    
    
    function sliceDestructive(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        // Ensure that the from and to positions are valid positions for a slice within
        // the byte array that is being used.
        if (from > to) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                from,
                to
            ));
        }
        if (to > b.length) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                to,
                b.length
            ));
        }

        // Create a new bytes structure around [from, to) in-place.
        assembly {
            result := add(b, from)
            mstore(result, sub(to, from))
        }
        return result;
    }

    
    
    
    function popLastByte(bytes memory b)
        internal
        pure
        returns (bytes1 result)
    {
        if (b.length == 0) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanZeroRequired,
                b.length,
                0
            ));
        }

        // Store last byte.
        result = b[b.length - 1];

        assembly {
            // Decrement length of byte array.
            let newLen := sub(mload(b), 1)
            mstore(b, newLen)
        }
        return result;
    }

    
    
    
    
    function equals(
        bytes memory lhs,
        bytes memory rhs
    )
        internal
        pure
        returns (bool equal)
    {
        // Keccak gas cost is 30 + numWords * 6. This is a cheap way to compare.
        // We early exit on unequal lengths, but keccak would also correctly
        // handle this.
        return lhs.length == rhs.length && keccak256(lhs) == keccak256(rhs);
    }

    
    
    
    
    function readAddress(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (address result)
    {
        if (b.length < index + 20) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                b.length,
                index + 20 // 20 is length of address
            ));
        }

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Read address from array memory
        assembly {
            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 20-byte mask to obtain address
            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    
    
    
    
    function writeAddress(
        bytes memory b,
        uint256 index,
        address input
    )
        internal
        pure
    {
        if (b.length < index + 20) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                b.length,
                index + 20 // 20 is length of address
            ));
        }

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Store address into array memory
        assembly {
            // The address occupies 20 bytes and mstore stores 32 bytes.
            // First fetch the 32-byte word where we'll be storing the address, then
            // apply a mask so we have only the bytes in the word that the address will not occupy.
            // Then combine these bytes with the address and store the 32 bytes back to memory with mstore.

            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 12-byte mask to obtain extra bytes occupying word of memory where we'll store the address
            let neighbors := and(
                mload(add(b, index)),
                0xffffffffffffffffffffffff0000000000000000000000000000000000000000
            )

            // Make sure input address is clean.
            // (Solidity does not guarantee this)
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffff)

            // Store the neighbors and address into memory
            mstore(add(b, index), xor(input, neighbors))
        }
    }

    
    
    
    
    function readBytes32(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes32 result)
    {
        if (b.length < index + 32) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                b.length,
                index + 32
            ));
        }

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

    
    
    
    
    function writeBytes32(
        bytes memory b,
        uint256 index,
        bytes32 input
    )
        internal
        pure
    {
        if (b.length < index + 32) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                b.length,
                index + 32
            ));
        }

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            mstore(add(b, index), input)
        }
    }

    
    
    
    
    function readUint256(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (uint256 result)
    {
        result = uint256(readBytes32(b, index));
        return result;
    }

    
    
    
    
    function writeUint256(
        bytes memory b,
        uint256 index,
        uint256 input
    )
        internal
        pure
    {
        writeBytes32(b, index, bytes32(input));
    }

    
    
    
    
    function readBytes4(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes4 result)
    {
        if (b.length < index + 4) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsFourRequired,
                b.length,
                index + 4
            ));
        }

        // Arrays are prefixed by a 32 byte length field
        index += 32;

        // Read the bytes4 from array memory
        assembly {
            result := mload(add(b, index))
            // Solidity does not require us to clean the trailing bytes.
            // We do it anyway
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }

    
    ///      Decreasing length will lead to removing the corresponding lower order bytes from the byte array.
    ///      Increasing length may lead to appending adjacent in-memory bytes to the end of the byte array.
    
    
    function writeLength(bytes memory b, uint256 length)
        internal
        pure
    {
        assembly {
            mstore(b, length)
        }
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


library LibBytesRichErrorsV06 {

    enum InvalidByteOperationErrorCodes {
        FromLessThanOrEqualsToRequired,
        ToLessThanOrEqualsLengthRequired,
        LengthGreaterThanZeroRequired,
        LengthGreaterThanOrEqualsFourRequired,
        LengthGreaterThanOrEqualsTwentyRequired,
        LengthGreaterThanOrEqualsThirtyTwoRequired,
        LengthGreaterThanOrEqualsNestedBytesLengthRequired,
        DestinationLengthGreaterThanOrEqualSourceLengthRequired
    }

    // bytes4(keccak256("InvalidByteOperationError(uint8,uint256,uint256)"))
    bytes4 internal constant INVALID_BYTE_OPERATION_ERROR_SELECTOR =
        0x28006595;

    // solhint-disable func-name-mixedcase
    function InvalidByteOperationError(
        InvalidByteOperationErrorCodes errorCode,
        uint256 offset,
        uint256 required
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            INVALID_BYTE_OPERATION_ERROR_SELECTOR,
            errorCode,
            offset,
            required
        );
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;






interface IBalancerV2Vault {

    enum SwapKind { GIVEN_IN, GIVEN_OUT }
    /**
     * @dev Performs a swap with a single Pool.
     *
     * If the swap is given in (the number of tokens to send to the Pool is known), returns the amount of tokens
     * taken from the Pool, which must be greater than or equal to `limit`.
     *
     * If the swap is given out (the number of tokens to take from the Pool is known), returns the amount of
     * tokens sent to the Pool, which must be less than or equal to `limit`.
     *
     * Internal Balance usage and the recipient are determined by the `funds` struct.
     *
     * Emits a `Swap` event.
     * For full documentation see https://github.com/balancer-labs/balancer-core-v2/blob/master/contracts/vault/interfaces/IVault.sol
     */
    function swap(
        SingleSwap calldata request,
        FundManagement calldata funds,
        uint256 limit,
        uint256 deadline
    ) external payable returns (uint256);

    struct SingleSwap {
        bytes32 poolId;
        SwapKind kind;
        IERC20TokenV06 assetIn;
        IERC20TokenV06 assetOut;
        uint256 amount;
        bytes userData;
    }

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }
}

// 

/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;








interface IBancorNetwork {
    function convertByPath(
        IERC20TokenV06[] calldata _path,
        uint256 _amount,
        uint256 _minReturn,
        address _beneficiary,
        address _affiliateAccount,
        uint256 _affiliateFee
    )
        external
        payable
        returns (uint256);
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;




interface IEtherTokenV06 is
    IERC20TokenV06
{
    
    function deposit() external payable;

    
    function withdraw(uint256 amount) external;
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;







interface ICoFiXRouter {
    // msg.value = fee
    function swapExactTokensForETH(
        address token,
        uint amountIn,
        uint amountOutMin,
        address to,
        address rewardTo,
        uint deadline
    ) external payable returns (uint _amountIn, uint _amountOut);

    // msg.value = amountIn + fee
    function swapExactETHForTokens(
        address token,
        uint amountIn,
        uint amountOutMin,
        address to,
        address rewardTo,
        uint deadline
    ) external payable returns (uint _amountIn, uint _amountOut);
}

interface ICoFiXPair {

    function swapWithExact(address outToken, address to)
        external
        payable
        returns (
            uint amountIn,
            uint amountOut,
            uint oracleFeeChange,
            uint256[4] memory tradeInfo
        );
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;





library LibSafeMathV06 {

    function safeMul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        if (c / a != b) {
            LibRichErrorsV06.rrevert(LibSafeMathRichErrorsV06.Uint256BinOpError(
                LibSafeMathRichErrorsV06.BinOpErrorCodes.MULTIPLICATION_OVERFLOW,
                a,
                b
            ));
        }
        return c;
    }

    function safeDiv(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        if (b == 0) {
            LibRichErrorsV06.rrevert(LibSafeMathRichErrorsV06.Uint256BinOpError(
                LibSafeMathRichErrorsV06.BinOpErrorCodes.DIVISION_BY_ZERO,
                a,
                b
            ));
        }
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        if (b > a) {
            LibRichErrorsV06.rrevert(LibSafeMathRichErrorsV06.Uint256BinOpError(
                LibSafeMathRichErrorsV06.BinOpErrorCodes.SUBTRACTION_UNDERFLOW,
                a,
                b
            ));
        }
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = a + b;
        if (c < a) {
            LibRichErrorsV06.rrevert(LibSafeMathRichErrorsV06.Uint256BinOpError(
                LibSafeMathRichErrorsV06.BinOpErrorCodes.ADDITION_OVERFLOW,
                a,
                b
            ));
        }
        return c;
    }

    function max256(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a < b ? a : b;
    }

    function safeMul128(uint128 a, uint128 b)
        internal
        pure
        returns (uint128)
    {
        if (a == 0) {
            return 0;
        }
        uint128 c = a * b;
        if (c / a != b) {
            LibRichErrorsV06.rrevert(LibSafeMathRichErrorsV06.Uint256BinOpError(
                LibSafeMathRichErrorsV06.BinOpErrorCodes.MULTIPLICATION_OVERFLOW,
                a,
                b
            ));
        }
        return c;
    }

    function safeDiv128(uint128 a, uint128 b)
        internal
        pure
        returns (uint128)
    {
        if (b == 0) {
            LibRichErrorsV06.rrevert(LibSafeMathRichErrorsV06.Uint256BinOpError(
                LibSafeMathRichErrorsV06.BinOpErrorCodes.DIVISION_BY_ZERO,
                a,
                b
            ));
        }
        uint128 c = a / b;
        return c;
    }

    function safeSub128(uint128 a, uint128 b)
        internal
        pure
        returns (uint128)
    {
        if (b > a) {
            LibRichErrorsV06.rrevert(LibSafeMathRichErrorsV06.Uint256BinOpError(
                LibSafeMathRichErrorsV06.BinOpErrorCodes.SUBTRACTION_UNDERFLOW,
                a,
                b
            ));
        }
        return a - b;
    }

    function safeAdd128(uint128 a, uint128 b)
        internal
        pure
        returns (uint128)
    {
        uint128 c = a + b;
        if (c < a) {
            LibRichErrorsV06.rrevert(LibSafeMathRichErrorsV06.Uint256BinOpError(
                LibSafeMathRichErrorsV06.BinOpErrorCodes.ADDITION_OVERFLOW,
                a,
                b
            ));
        }
        return c;
    }

    function max128(uint128 a, uint128 b)
        internal
        pure
        returns (uint128)
    {
        return a >= b ? a : b;
    }

    function min128(uint128 a, uint128 b)
        internal
        pure
        returns (uint128)
    {
        return a < b ? a : b;
    }

    function safeDowncastToUint128(uint256 a)
        internal
        pure
        returns (uint128)
    {
        if (a > type(uint128).max) {
            LibRichErrorsV06.rrevert(LibSafeMathRichErrorsV06.Uint256DowncastError(
                LibSafeMathRichErrorsV06.DowncastErrorCodes.VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT128,
                a
            ));
        }
        return uint128(a);
    }
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


library LibSafeMathRichErrorsV06 {

    // bytes4(keccak256("Uint256BinOpError(uint8,uint256,uint256)"))
    bytes4 internal constant UINT256_BINOP_ERROR_SELECTOR =
        0xe946c1bb;

    // bytes4(keccak256("Uint256DowncastError(uint8,uint256)"))
    bytes4 internal constant UINT256_DOWNCAST_ERROR_SELECTOR =
        0xc996af7b;

    enum BinOpErrorCodes {
        ADDITION_OVERFLOW,
        MULTIPLICATION_OVERFLOW,
        SUBTRACTION_UNDERFLOW,
        DIVISION_BY_ZERO
    }

    enum DowncastErrorCodes {
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT32,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT64,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT96,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT128
    }

    // solhint-disable func-name-mixedcase
    function Uint256BinOpError(
        BinOpErrorCodes errorCode,
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            UINT256_BINOP_ERROR_SELECTOR,
            errorCode,
            a,
            b
        );
    }

    function Uint256DowncastError(
        DowncastErrorCodes errorCode,
        uint256 a
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            UINT256_DOWNCAST_ERROR_SELECTOR,
            errorCode,
            a
        );
    }
}

// 

/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;






/*
    UniswapV2
*/
interface IUniswapV2Router02 {

    
    ///      The first element of path is the input token, the last is the output token, and any intermediate elements represent
    ///      intermediate pairs to trade through (if, for example, a direct pair does not exist).
    
    
    
    
    
    
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        IERC20TokenV06[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

// 

/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;







interface IDODO {
    function sellBaseToken(
        uint256 amount,
        uint256 minReceiveQuote,
        bytes calldata data
    )
        external
        returns (uint256);

    function buyBaseToken(
        uint256 amount,
        uint256 maxPayQuote,
        bytes calldata data
    )
        external
        returns (uint256);
}


interface IDODOHelper {
    function querySellQuoteToken(
        IDODO dodo,
        uint256 amount
    )
        external
        view
        returns (uint256);
}

// 

/*

  Copyright 2021 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;







interface IDODOV2 {
    function sellBase(address recipient)
        external
        returns (uint256);

    function sellQuote(address recipient)
        external
        returns (uint256);
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;







interface IKyberNetworkProxy {

    
    /// using a hint for the reserve.
    
    
    
    
    
    
    ///        is lower, trade is canceled.
    
    
    
    function tradeWithHint(
        IERC20TokenV06 sellToken,
        uint256 sellAmount,
        IERC20TokenV06 buyToken,
        address payable recipientAddress,
        uint256 maxBuyTokenAmount,
        uint256 minConversionRate,
        address payable walletId,
        bytes calldata hint
    )
        external
        payable
        returns (uint256 boughtAmount);
}

// 

/*

  Copyright 2021 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;






/*
    KyberDmm Router
*/
interface IKyberDmmRouter {

    
    ///      The first element of path is the input token, the last is the output token, and any intermediate elements represent
    ///      intermediate pairs to trade through (if, for example, a direct pair does not exist).
    
    
    
    
    
    
    
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata pools,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

// 
/*

  Copyright 2021 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;






interface IPSM {
    // @dev Get the fee for selling USDC to DAI in PSM
    // @return tin toll in [wad]
    function tin() external view returns (uint256);
    // @dev Get the fee for selling DAI to USDC in PSM
    // @return tout toll out [wad]
    function tout() external view returns (uint256);

    // @dev Get the address of the PSM state Vat
    // @return address of the Vat
    function vat() external view returns (address);

    // @dev Get the address of the underlying vault powering PSM
    // @return address of gemJoin contract
    function gemJoin() external view returns (address);

    // @dev Sell USDC for DAI
    // @param usr The address of the account trading USDC for DAI.
    // @param gemAmt The amount of USDC to sell in USDC base units
    function sellGem(
        address usr,
        uint256 gemAmt
    ) external;
    // @dev Buy USDC for DAI
    // @param usr The address of the account trading DAI for USDC
    // @param gemAmt The amount of USDC to buy in USDC base units
    function buyGem(
        address usr,
        uint256 gemAmt
    ) external;
}

// 

/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;









interface IMooniswapPool {

    function swap(
        IERC20TokenV06 sellToken,
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        uint256 minBoughtAmount,
        address referrer
    )
        external
        payable
        returns (uint256 boughtAmount);
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;







interface IMStable {

    function swap(
        IERC20TokenV06 sellToken,
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        uint256 minBoughtAmount,
        address recipient
    )
        external
        returns (uint256 boughtAmount);
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;






interface IOasis {

    
    
    
    
    
    
    function sellAllAmount(
        IERC20TokenV06 sellToken,
        uint256 sellAmount,
        IERC20TokenV06 buyToken,
        uint256 minBoughtAmount
    )
        external
        returns (uint256 boughtAmount);
}

// 

/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;





interface IShell {

    function originSwap(
        IERC20TokenV06 from,
        IERC20TokenV06 to,
        uint256 fromAmount,
        uint256 minTargetAmount,
        uint256 deadline
    )
        external
        returns (uint256 toAmount);
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;







interface IUniswapExchangeFactory {

    
    
    function getExchange(IERC20TokenV06 token)
        external
        view
        returns (IUniswapExchange exchange);
}

interface IUniswapExchange {

    
    ///      to `recipient`.
    
    
    
    
    function ethToTokenTransferInput(
        uint256 minTokensBought,
        uint256 deadline,
        address recipient
    )
        external
        payable
        returns (uint256 tokensBought);

    
    
    
    
    
    function tokenToEthSwapInput(
        uint256 tokensSold,
        uint256 minEthBought,
        uint256 deadline
    )
        external
        returns (uint256 ethBought);

    
    ///      and transfer them to `recipient`.
    
    
    
    
    
    
    
    function tokenToTokenTransferInput(
        uint256 tokensSold,
        uint256 minTokensBought,
        uint256 minEthBought,
        uint256 deadline,
        address recipient,
        IERC20TokenV06 buyToken
    )
        external
        returns (uint256 tokensBought);

    
    
    
    
    
    
    
    function tokenToTokenSwapInput(
        uint256 tokensSold,
        uint256 minTokensBought,
        uint256 minEthBought,
        uint256 deadline,
        IERC20TokenV06 buyToken
    )
        external
        returns (uint256 tokensBought);
}

// 

/*

  Copyright 2021 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;






interface IUniswapV3Router {

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams memory params)
        external
        payable
        returns (uint256 amountOut);
}

// 
/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;




interface ILiquidityProvider {

    
    
    
    
    
    
    
    
    
    
    
    event LiquidityProviderFill(
        IERC20TokenV06 inputToken,
        IERC20TokenV06 outputToken,
        uint256 inputTokenAmount,
        uint256 outputTokenAmount,
        bytes32 sourceId,
        address sourceAddress,
        address sender,
        address recipient
    );

    
    ///      to sell must be transferred to the contract prior to calling this
    ///      function to trigger the trade.
    
    
    
    
    
    
    function sellTokenForToken(
        IERC20TokenV06 inputToken,
        IERC20TokenV06 outputToken,
        address recipient,
        uint256 minBuyAmount,
        bytes calldata auxiliaryData
    )
        external
        returns (uint256 boughtAmount);

    
    ///      call or sent to the contract prior to calling this function to
    ///      trigger the trade.
    
    
    
    
    
    function sellEthForToken(
        IERC20TokenV06 outputToken,
        address recipient,
        uint256 minBuyAmount,
        bytes calldata auxiliaryData
    )
        external
        payable
        returns (uint256 boughtAmount);

    
    ///      to calling this function to trigger the trade.
    
    
    
    
    
    function sellTokenForEth(
        IERC20TokenV06 inputToken,
        address payable recipient,
        uint256 minBuyAmount,
        bytes calldata auxiliaryData
    )
        external
        returns (uint256 boughtAmount);

    
    ///      selling `sellAmount` of `inputToken`.
    
    ///        the wETH address if selling ETH.
    
    ///        the wETH address if buying ETH.
    
    
    function getSellQuote(
        IERC20TokenV06 inputToken,
        IERC20TokenV06 outputToken,
        uint256 sellAmount
    )
        external
        view
        returns (uint256 outputTokenAmount);
}
